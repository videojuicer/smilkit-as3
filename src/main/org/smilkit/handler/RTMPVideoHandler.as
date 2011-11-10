/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
package org.smilkit.handler
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.handler.state.HandlerState;
	import org.smilkit.handler.state.VideoHandlerState;
	import org.smilkit.render.HandlerController;
	import org.smilkit.time.SharedTimer;
	import org.smilkit.util.Metadata;
	import org.smilkit.view.Viewport;
	import org.smilkit.w3c.dom.IElement;
	import org.utilkit.util.NumberHelper;
	
	public class RTMPVideoHandler extends SMILKitHandler
	{
		public static const INITIAL_BUFFER_TIME:int = 2;
		public static const REDUCED_BUFFER_TIME:int = 4;
		public static const EXPANDED_BUFFER_TIME:int = 30;
		
		protected var _netConnection:NetConnection;
		protected var _netStream:NetStream;
		protected var _video:Video;
		protected var _soundTransformer:SoundTransform;
		protected var _metadata:Metadata;
		protected var _canvas:Sprite;
		protected var _volume:uint;
		
		protected var _resumed:Boolean = false;
		protected var _waiting:Boolean = false;
		protected var _waitingForMetaRefresh:Boolean = false;
		protected var _stopping:Boolean = false;
		protected var _isLive:Boolean = false;
		
		protected var _waitingForFrames:Boolean = false;
		protected var _droppedFrames:uint = 0;
		
		protected var _playOptions:NetStreamPlayOptions;
		
		protected var _attachVideoDisplayDelayed:Boolean = false;

		protected var _resumeOnBufferFull:Boolean = false;
		protected var _readyOnPlayStart:Boolean = false;
		
		public function RTMPVideoHandler(element:IElement)
		{
			super(element);
			
			this._canvas = new Sprite();
			
			this._soundTransformer = new SoundTransform(0.2, 0);
		}
		
		public override function get fileSizeWillResolve():Boolean
		{
			return false;
		}
		
		public override function get width():uint
		{
			if (this._metadata == null)
			{
				return super.width;
			}
			
			return this._metadata.width;
		}
		
		public override function get height():uint
		{
			if (this._metadata == null)
			{
				return super.height;
			}
			
			return this._metadata.height;
		}
		
		public override function get resolvable():Boolean
		{
			return true;
		}
		
		public override function get seekable():Boolean
		{
			return !this._isLive;
		}
		
		public override function get preloadable():Boolean
		{
			return false;
		}
		
		public override function get cuePoints():Vector.<int>
		{
			if (this._metadata == null)
			{
				return super.cuePoints;
			}
			
			return this._metadata.syncPoints;
		}
		
		public override function get spatial():Boolean
		{
			return true;
		}
		
		public override function get temporal():Boolean
		{
			return true;
		}
		
		public override function get displayObject():DisplayObject
		{
			return (this._canvas as DisplayObject);
		}
		
		public override function get currentOffset():int
		{
			if (this._netStream == null)
			{
				return super.currentOffset;
			}
			
			return (this._netStream.time * 1000);
		}
		
		public override function get handlerState():HandlerState
		{
			var source:String = null;
			
			if (this.element != null)
			{
				source = this.element.src;
			}
			
			return new VideoHandlerState(source, 0, this._netConnection, this._netStream, this._video, this._canvas);	
		}
		
		public override function get resumed():Boolean
		{
			return this._resumed;
		}
		
		public function get videoHandlerState():VideoHandlerState
		{
			return (this.handlerState as VideoHandlerState);
		}
		
		public override function load():void
		{
			SMILKit.logger.debug("RTMP -> "+this.handlerState.src+" -> load");
			
			if (this._metadata != null)
			{
				SMILKit.logger.debug("Metadata already loaded for RTMPHandler.");
			}
			
			this._playOptions = new NetStreamPlayOptions();
									
			this._netConnection = new NetConnection();
			this._netConnection.client = this;
			
			this._netConnection.addEventListener(NetStatusEvent.NET_STATUS, this.onConnectionNetStatusEvent);
			this._netConnection.addEventListener(IOErrorEvent.IO_ERROR, this.onConnectionIOErrorEvent);
			this._netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.onConnectionAsyncErrorEvent);
			this._netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onConnectionSecurityErrorEvent);
			
			this._startedLoading = true;
			
			this._netConnection.connect(this.videoHandlerState.fmsURL.instanceHostname);
			
			this.leaveFrozenState();
			
			this.loadWait();
		}
		
		public override function wait(handlers:Vector.<SMILKitHandler>):void
		{
			var selfWaiting:Boolean = (handlers.length == 1 && handlers[0] == this);
			
			if (selfWaiting)
			{
				SMILKit.logger.debug("<zen>Handler ignoring wait call as it would only be waiting for itself</zen>", this);
				this.unwait();
			}
			else
			{
				SMILKit.logger.debug("Handler entering wait cycle as there are other handlers waiting: "+handlers.join(","), this);
				super.wait(handlers);
			}
		}
		
		public override function merge(handlerState:HandlerState):Boolean
		{
			SMILKit.logger.debug("RTMP -> "+this.handlerState.src+" -> merge");
			
			if (super.merge(handlerState))
			{
				// we know we can do this because its of the same type
				var videoHandlerState:VideoHandlerState = (handlerState as VideoHandlerState);
				
				this._netConnection = videoHandlerState.netConnection;
				this._netStream = videoHandlerState.netStream;
				this._video = videoHandlerState.video;
				this._canvas = videoHandlerState.canvas;
				
				this._playOptions.streamName = this.videoHandlerState.fmsURL.streamNameWithParameters;
				this._playOptions.transition = NetStreamPlayTransitions.SWITCH;
				
				this._netStream.play2(this._playOptions);
				
				this.attachVideoDisplay();
				
				this.resize();
				this.resetVolume();

				return true;
			}
			
			return false;
		}
		
		public override function setVolume(volume:uint):void
		{
			this._volume = volume;
			
			if(this._netStream != null)
			{
				SMILKit.logger.debug("Handler volume set to "+volume+" ("+(volume/100)+").", this);
	        
				this._soundTransformer.volume = volume/100;				
				this._netStream.soundTransform = this._soundTransformer;
			}
		}
		
		/** 
		* Resets the volume to the known value. Use whenever a new NetStream object is created.
		*/
		protected function resetVolume():void
		{
			this.setVolume(this._volume);
		}
		
		public override function resume():void
		{
			SMILKit.logger.debug("RTMP -> "+this.handlerState.src+" -> resume");
			
			if (this._netStream != null && !this._resumed)
			{
				SMILKit.logger.debug("Resuming playback.", this);

				this._resumed = true;
				this._waitingForMetaRefresh = true;
				
				this._netStream.resume();
			}
		}
		
		public override function pause():void
		{
			SMILKit.logger.debug("RTMP -> "+this.handlerState.src+" -> pause");
			
			if (this._netStream != null)
			{
				SMILKit.logger.debug("Pausing playback.", this);
				
				this._resumed = false;
				this._waitingForMetaRefresh = false;

				this._netStream.pause();
			}
		}
		
		public override function seek(target:Number, strict:Boolean):void
		{
			if (this._metadata == null)
			{
				SMILKit.logger.debug("RTMP handler deferring seek until metadata encountered", this);
				this.onSeekTo(target);
			}
			else
			{
				SMILKit.logger.debug("RTMP video handler issuing seek immediately", this);
				super.seek(target, strict);
				this.internalSeek(target);	
			}
		}

		protected function clearSeekTo():void
		{
			SMILKit.logger.debug("Handler clearing seek job", this);
			this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_NOTIFY, this));
		}
		
		protected function internalSeek(target:Number):void
		{
			SMILKit.logger.debug("RTMP -> "+this.handlerState.src+" -> seek");
			
			var seconds:Number = (target / 1000);
			SMILKit.logger.debug("Executing internal seek to "+target+"ms ("+seconds+"s)", this);
				
			if(this._netStream != null)
			{
				this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
				this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_WAITING, this));
				this._netStream.seek(seconds);
			}
		}
		
		public override function cancel():void
		{
			SMILKit.logger.debug("RTMP -> "+this.handlerState.src+" -> cancel");
			
			if (this._netStream != null)
			{
				this._netStream.close();
			}
			
			if (this._netConnection != null)
			{
				this._netConnection.close();
			}
			
			this._netConnection = null;
			this._netStream = null;
			
			// Note that the cancel operation does NOT clear the metadata, if any has been loaded. This is to allow resolve jobs to
			// retain their data payload. If the file is reloaded with new metadata, then the metadata object will be updated at that time.
			
			for (var i:int = 0; i < this._canvas.numChildren; i++)
			{
				this._canvas.removeChildAt(i);
			}
			
			this._shield = null;
			
			super.cancel();
		}
		
		public override function resize():void
		{
			super.resize();
			
			if (this._video != null)
			{
				this.attachVideoDisplay();
				
				this.drawClickShield(this._video);
			}
		}
		
		public override function addedToRenderTree(r:HandlerController):void
		{
			if (this._video == null)
			{
				this._attachVideoDisplayDelayed = true;
			}
			else
			{
				this._attachVideoDisplayDelayed = false;
				
				this.attachVideoDisplay();
			}
		}

		protected function loadReady():void
		{
			this._waiting = false;
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
		}

		protected function loadWait():void
		{
			this._waiting = true;
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
		}
		
		protected function attachVideoDisplay():void
		{
			this.resetVolume();
			
			this._video.attachNetStream(this._netStream as NetStream);
		}
		
		protected function clearVideoDisplay():void
		{
			if (this._netStream != null)
			{
				this._soundTransformer.volume = 0;		
				this._netStream.soundTransform = this._soundTransformer;
			}
			
			if (this._video != null)
			{
				this._video.attachNetStream(null);
				this._video.clear();
			}
		}
		
		public override function removedFromRenderTree(r:HandlerController):void
		{
			this.clearVideoDisplay();
			
			this._attachVideoDisplayDelayed = false;
		}
		
		protected function onConnectionNetStatusEvent(e:NetStatusEvent):void
		{
			SMILKit.logger.debug("NetConnection->NetStatusEvent: "+e.info.code+" "+e.info.description, e);
			
			switch (e.info.code)
			{
				case "NetConnection.Connect.Failed":
					SMILKit.logger.fatal("NetConnection to '"+this.videoHandlerState.fmsURL.hostname+"' failed: "+e.info.message, this);
					
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
					break;
				case "NetConnection.Connect.Rejected":
					SMILKit.logger.fatal("NetConnection to '"+this.videoHandlerState.fmsURL.hostname+"' rejected by Flash Media Server", this);
					
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
					break;
				case "NetConnection.Connect.Success":
					SMILKit.logger.debug("NetConnection to "+this.videoHandlerState.fmsURL.hostname+" successful, creating NetStream", this);
				
					this._netConnection.call("checkBandwidth", null);
					
					this._netStream = new NetStream(this._netConnection);
					
					this._netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.onAsyncErrorEvent);
					this._netStream.addEventListener(IOErrorEvent.IO_ERROR, this.onIOErrorEvent);
					this._netStream.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatusEvent);

					this._netStream.checkPolicyFile = true;
					this._netStream.client = this;

					this._video = new Video();
					this._video.smoothing = true;
					this._video.deblocking = 1;
					
					this._canvas.addChild(this._video);

					if (this._attachVideoDisplayDelayed)
					{
						this.attachVideoDisplay();
					}
					
					this._netStream.bufferTime = RTMPVideoHandler.INITIAL_BUFFER_TIME;
					
					this._netStream.play(this.videoHandlerState.fmsURL.streamNameWithParameters);

					this.resize();
					this.resetVolume();
					
					break;
			}
		}
		
		public function onBWCheck(... rest):Number
		{
			return 0;
		}
		
		public function onBWDone(... rest):void
		{
			if (rest.length > 0)
			{
				SMILKit.logger.debug("Bandwidth received on NetConnection from Flash Media Server, result: "+rest[0]+"Kbps with a latency of: "+rest[3]+"ms.", this);
			}
		}
		
		protected function onConnectionIOErrorEvent(e:IOErrorEvent):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function onConnectionSecurityErrorEvent(e:SecurityErrorEvent):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_UNAUTHORISED, this));
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function onConnectionAsyncErrorEvent(e:AsyncErrorEvent):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function checkCondition():void
		{
			if (this._netStream != null && this._netStream.info != null)
			{
				var recentDrops:uint = (this._netStream.info.droppedFrames - this._droppedFrames);
				var recentCount:uint = this._netStream.currentFPS;
				
				SMILKit.logger.debug("RTMP.checkCondition -> FPS: "+recentCount+", recent dropped frames: "+recentDrops+", total dropped: "+this._netStream.info.droppedFrames+", buffer length: "+this._netStream.bufferLength+" filling at: "+NumberHelper.toHumanReadableString(this._netStream.info.maxBytesPerSecond / 1024)+"Kbps, playing at: "+NumberHelper.toHumanReadableString(this._netStream.info.playbackBytesPerSecond / 1024)+"Kbps, video rate at: "+NumberHelper.toHumanReadableString(this._netStream.info.videoBytesPerSecond / 1024)+"Kbps");
				
				if (recentDrops > (recentCount / 2))
				{
					SMILKit.logger.warn("WARNING: RTMP stream dropped more than half of the frames: "+recentDrops+", target: "+recentCount);
				}
				
				if (recentCount == 0)
				{
					SMILKit.logger.warn("WARNING: RTMP stream is not playing any frames.");
					
					this._waitingForFrames = true;
					
					//this.loadWait();
				}
				else
				{
					if (this._waitingForFrames)
					{
						//this.loadReady();
					}
					
					this._waitingForFrames = false;
				}
				
				this._droppedFrames = this._netStream.info.droppedFrames;
			}
		}
		
		protected function onNetStatusEvent(e:NetStatusEvent):void
		{
			SMILKit.logger.debug("NetStatusEvent: "+e.info.code+" "+e.info.description, e);
			
			switch (e.info.code)
			{
				case "NetStream.Buffer.Full":
					if (this._netStream.bufferTime != RTMPVideoHandler.EXPANDED_BUFFER_TIME)
					{
						this._netStream.bufferTime = RTMPVideoHandler.EXPANDED_BUFFER_TIME;
					}
					
					if (this._metadata != null)
					{
						// Clear wait
						this.loadReady();
												
						// dispatch some events for resume + seek
						if (this._resumeOnBufferFull)
						{
							this._resumeOnBufferFull = false;
							
							this.dispatchEvent(new HandlerEvent(HandlerEvent.RESUME_NOTIFY, this));
						}
					}
					break;
				case "NetStream.Buffer.Empty":
					this._netStream.bufferTime = RTMPVideoHandler.REDUCED_BUFFER_TIME;
					
					if(this._resumed)
					{
						this.loadWait();
					}
					else
					{
						SMILKit.logger.debug("Ignored NetStream.Buffer.Empty event as this handler is not currently playing", this);
					}
					break;
				case "NetStream.Buffer.Flush":
					if (this._stopping)
					{
						this._stopping = false;
						
						this.enterFrozenState();
						
						this.dispatchEvent(new HandlerEvent(HandlerEvent.STOP_NOTIFY, this));
					}
					else
					{
						//this.loadWait();
					}
					break;
				case "NetStream.Failed":
				case "NetStream.Play.Failed":
				case "NetStream.Play.NoSupportedTrackFound":
				case "NetStream.Play.FileStructureInvalid":
					SMILKit.logger.debug("Failed to play NetStream: "+this.videoHandlerState.fmsURL.streamNameWithParameters+" - "+this.videoHandlerState.fmsURL.hostname);
					
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
					break;
				case "NetStream.Play.Stop":
					this._stopping = true;
					break;
				case "NetStream.Play.PublishNotify":
					// Live stream requested but not in progress...
					SMILKit.logger.warn("RTMP Stream appears to be offline", this);
					this.loadReady();
					break;
				case "NetStream.Unpublish.Success":
					// playback has finished, important for live events (so we can continue)
					this.pause(); // Throw handler into paused state - we do not have a special "stopped" state
					this.dispatchEvent(new HandlerEvent(HandlerEvent.STOP_NOTIFY, this));
					break;
				case "NetStream.Play.Start":
					//this._netStream.bufferTime = RTMPVideoHandler.EXPANDED_BUFFER_TIME;
					if (this._readyOnPlayStart)
					{
						// Seeking emits a Seek.Notify->Play.Start: no Buffer.Full event.
						this._readyOnPlayStart = false;
						this.loadReady();
					}
					break;
				case "NetStream.Pause.Notify":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.PAUSE_NOTIFY, this));
					
					SharedTimer.removeEvery(5, this.checkCondition);
					break;
				case "NetStream.Unpause.Notify":
					SharedTimer.every(5, this.checkCondition);
					
					if (!this._waitingForMetaRefresh)
					{
						this._resumeOnBufferFull = true;
						this.loadWait();
					}
					break;
				case "NetStream.Seek.Failed":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_FAILED, this));
					break;
				case "NetStream.Seek.InvalidTime":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_INVALID, this));
					break;
				case "NetStream.Seek.Notify":
					if (!this._resumed)
					{
						this._netStream.pause();
					}
					
					if (!this._stopping && this._seekingTo)
					{
						this._readyOnPlayStart = true;
						this.loadWait();
					}

					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_NOTIFY, this)); 
					break;
			}
		}
		
		protected function onIOErrorEvent(e:IOErrorEvent):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function onSecurityErrorEvent(e:SecurityErrorEvent):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_UNAUTHORISED, this));
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function onAsyncErrorEvent(e:AsyncErrorEvent):void
		{
			SMILKit.logger.debug("Handler encountered an async error during load: "+e.text+", "+e.error.name+", "+e.error.message, this);
		}
		
		public function onCuePoint(info:Object):void
		{
			// ignore
		}
		
		public function onXMPData(info:Object):void
		{
			// ignore
		}

		public function onPlayStatus(info:Object):void
		{
			SMILKit.logger.debug("RTMP->onPlayStatus -> "+info);
			
			switch (info)
			{
				case "NetStream.Play.Complete":
					this._stopping = true;
					break;
			}
		}
		
		public function onMetaData(info:Object):void
		{
			if (this._metadata == null)
			{
				this._metadata = new Metadata(info);
				
				if(!this._resumed)
				{
					var deferredSeekTarget:Number = (this._seekingTo)? this._seekingToTarget : 0;

					SMILKit.logger.debug("Found initial metadata while loading/paused. Executing seek to "+deferredSeekTarget+".", this);
					
					// TODO: do an internal seek back to ground zero
					this.internalSeek(deferredSeekTarget);
					this.pause();
				}
			}
			else
			{
				this._metadata.update(info);
			}
			
			if (this.viewportObjectPool != null && this.viewportObjectPool.viewport != null && this.viewportObjectPool.viewport.playbackState == Viewport.PLAYBACK_PAUSED) //if(!this._resumed)
			{
				SMILKit.logger.debug("Encountered metadata while loading or paused. About to pause netstream object.", this);
				
				this.pause();
			}
			
			SMILKit.logger.info("Metadata recieved: "+this._metadata.toString());
			
			if (isNaN(this._metadata.duration) || this._metadata.duration <= 0)
			{
				this.resolved(Time.INDEFINITE);
				
				SMILKit.logger.debug("Resolved duration as indefinite, must be handling live stream ....");
				
				// were a live stream, so were ready!
				if(!this._isLive)
				{
					// Transitioning to live state, set flag and issue a SEEK_NOTIFY to clear any outstanding seek jobs
					this._isLive = true;
					this.clearSeekTo();		
				}
				this.loadReady();
			}
			else
			{
				this._isLive = false;
				this.resolved(this._metadata.duration);
			}
			
			if (this._waitingForMetaRefresh)
			{
				this.dispatchEvent(new HandlerEvent(HandlerEvent.RESUME_NOTIFY, this));
				
				this._waitingForMetaRefresh = false;
			}
		}
		
		/**
		 * Callback routine, not really close!!!!!!!
		 */
		protected function close():void
		{
			// playback has finished, important for live events (so we can continue)
			this.pause(); // Throw handler into paused state - we do not have a special "stopped" state
			this.dispatchEvent(new HandlerEvent(HandlerEvent.STOP_NOTIFY, this));
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap([ 'rtmp', 'rtmpt', 'rtmps', 'rtmpe' ], { 'video/flv': [ '.flv', '.f4v', '*' ], 'video/mpeg': [ '.mp4', '.f4v' ] });
		}
	}
}