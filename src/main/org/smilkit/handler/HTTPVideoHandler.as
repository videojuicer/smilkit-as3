package org.smilkit.handler
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.handler.state.HandlerState;
	import org.smilkit.handler.state.VideoHandlerState;
	import org.smilkit.render.HandlerController;
	import org.smilkit.time.SharedTimer;
	import org.smilkit.util.Metadata;
	import org.smilkit.w3c.dom.IElement;
	import org.utilkit.util.NumberHelper;
	
	public class HTTPVideoHandler extends SMILKitHandler
	{
		protected var _netConnection:NetConnection;
		protected var _netStream:NetStream;
		protected var _video:Video;
		protected var _soundTransformer:SoundTransform;
		protected var _metadata:Metadata;
		protected var _canvas:Sprite;
		
		protected var _resumed:Boolean = false;
		
		protected var _loadReady:Boolean = false;
		
		protected var _volume:uint;
		
		/**
		* If a seek is issued when the handler is not ready to perform it (either before load or when not enough bytes are loaded to perform the seek)
		* the seek offset will be stored here until the seek is available. Once the seek has completed the value will be nulled.
		*/
		protected var _queuedSeek:Boolean = false;
		protected var _queuedSeekTarget:uint;
		
		protected var _seeking:Boolean = false;
		protected var _seekingTarget:uint;
		
		protected var _attachVideoDisplayDelayed:Boolean = false;
		
		public function HTTPVideoHandler(element:IElement)
		{
			super(element);
			
			this._canvas = new Sprite();
			
			//this._canvas.graphics.clear();
			//this._canvas.graphics.beginFill(0xEEEEEE, 0.8);
			//this._canvas.graphics.drawRect(0, 0, 200, 200);
			//this._canvas.graphics.endFill();
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
			return true;
		}
		
		public override function get syncPoints():Vector.<int>
		{
			if (this._metadata == null)
			{
				return super.syncPoints;
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

		public override function get innerDisplayObject():DisplayObject
		{
			return (this._video as DisplayObject);
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
			return new VideoHandlerState(this.element.src, 0, this._netConnection, this._netStream, this._video, this._canvas);	
		}
		
		public override function load():void
		{
			this._resumed = false;
			
			this._netConnection = new NetConnection();
			this._netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.onAsyncErrorEvent);
			this._netConnection.connect(null);
			
			this._soundTransformer = new SoundTransform(0.2, 0);
			
			if(this._volume)
			{
				this.setVolume(this._volume);
			}
			
			this._netStream = new NetStream(this._netConnection);
			
			this._netStream.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatusEvent);
			this._netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.onAsyncErrorEvent);
			this._netStream.addEventListener(IOErrorEvent.IO_ERROR, this.onIOErrorEvent);
			
			this._netStream.checkPolicyFile = true;
			this._netStream.client = this;
			this._netStream.bufferTime = 5;
			this._netStream.soundTransform = this._soundTransformer;
			
			this._netStream.play(this.element.src);
			
			this._startedLoading = true;
			
			this._video = new Video();
			this._video.smoothing = true;
			this._video.deblocking = 1;
			
			if (this.viewportObjectPool != null)
			{
				SharedTimer.unsubscribe(this.onHeartbeatTick); // remove then add to guarantee single binding only
				SharedTimer.subscribe(this.onHeartbeatTick);
			}
			
			this._canvas.addChild(this._video);
			
			this.drawClickShield(this._video);
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
		}
		
		public override function movedToJustInTimeWorkList():void
		{
			if (this.completedLoading)
			{
				SMILKit.logger.debug("HTTPVideoHandler "+this.handlerId+" moved to JIT worker. Will reset play head before calling super", this);
				this.seek(0);
				// were ready since load has finished!
			}
			super.movedToJustInTimeWorkList();
		}
		
		public override function setVolume(volume:uint):void
		{
			this._volume = volume;
			if(this._soundTransformer != null && this._netStream != null)
			{
				SMILKit.logger.debug("Handler volume set to "+volume+".", this);
				this._soundTransformer.volume = volume/100;
				this._netStream.soundTransform = this._soundTransformer;
			}
		}
		
		public override function resume():void
		{
			if (this._netStream != null)
			{
				SMILKit.logger.debug("Resuming playback.", this);
				this._resumed = true;
				this._netStream.resume();
			}
		}
		
		public override function pause():void
		{
			if (this._netStream != null)
			{
				SMILKit.logger.debug("Pausing playback.", this);
				this._resumed = false;
				this._netStream.pause();
			}
		}
		
		/** 
		* Executes or queues a seek operation on this handler. Since seek availability within a progressive HTTP video is 
		* limited by the amount of data currently loaded, the handler first checks the readiness of the requested seek offset
		* and queues the seek operation if the handler is not ready to meet that demand.
		*
		* In the event of a seek being queued, the heartbeat subscriber method will start to check for the availability of
		* the queued seek offset and execute the seek when it becomes available.
		* 
		* Issuing a new seek call to an offset that is available will clear any queued seek operations. Issuing a new seek call
		* to an offset that is not available will overwrite any previously-queued seek operation.
		* 
		* @see org.smilkit.handler.HTTPVideoHandler.onHeartbeatTick
		*/
		public override function seek(seekTo:Number):void
		{
			if(this.readyToPlayAt(seekTo))
			{
				// We're able to seek to that point. Execute the seek right away.
				this.execSeek(seekTo);
			}
			else
			{
				// Stash the seek until we're able to do it.
				SMILKit.logger.debug("Seek to "+seekTo+"ms requested, but not able to seek to that offset. Queueing seek until offset becomes available.");
				
				this._queuedSeek = true;
				this._queuedSeekTarget = seekTo;
			}
		}
		
		/*
		* Executes a seek operation on an offset that is available within this handler, clearing any queued seek operations in the process.
		*/
		protected function execSeek(seekTo:Number):void
		{
			// Cancel queued seek
			this._queuedSeek = false;
			
			//if (!this._seeking || this._seekingTarget != seekTo)
			//{
				this._netStream.resume();
				
				// Execute seek
				var seconds:Number = (seekTo / 1000);
				
				SMILKit.logger.debug("Executing internal seek to "+seekTo+"ms ("+seconds+"s)", this);
				
				this._seeking = true;
				this._seekingTarget = seekTo;
				
				this._netStream.seek(seconds);
			//}
		}
		
		/*
		* Executes a queued seek operation, if one has been queued. If the seek is executed, the queued seek will be cleared.
		*/
		protected function execQueuedSeek():void
		{
			if(this._queuedSeek)
			{
				SMILKit.logger.debug("About to execute a deferred seek operation to "+this._queuedSeekTarget+"ms.", this);
				this.execSeek(this._queuedSeekTarget);
			}
			else
			{
				SMILKit.logger.debug("Asked to execute any queued seek operation, but no seek operation is queued.", this);
			}
		}

		
		public override function merge(handlerState:HandlerState):Boolean
		{
			// cant merge anything with a http video!
			
			return false;
		}
		
		public override function cancel():void
		{
			if (this.viewportObjectPool != null)
			{
				SharedTimer.unsubscribe(this.onHeartbeatTick);
			}
			
			this._resumed = false;
			
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
		
		protected function readyToPlayAt(offset:int):Boolean
		{
			if (this._netStream != null && this._startedLoading)
			{
				var minPercentageForReset:int = 6;
				var percentageLoaded:Number = (this._netStream.bytesLoaded / this._netStream.bytesTotal) * 100;
				var durationLoaded:Number = ((percentageLoaded / 100) * this.duration);
				
				if(durationLoaded >= 0)
				{
					SMILKit.logger.debug("readyToPlayAt("+offset+"): Loaded "+percentageLoaded+"% of file, first "+durationLoaded+"ms available.", this);
					if (offset == 0)
					{
						if (percentageLoaded < minPercentageForReset)
						{
							return false;
						}
					}

					if (offset <= durationLoaded)
					{
						return true;
					}
				}
				else
				{
					if(offset == 0 && percentageLoaded >= minPercentageForReset)
					{
						return true;
					}
					else
					{
						SMILKit.logger.debug("readyToPlayAt("+offset+"): Loaded "+percentageLoaded+"% of file, but duration is unknown.", this);
					}
				}
			}
			
			return false;
		}
		
		/**
		* Executed each time the heartbeat timer ticks, regardless of it's paused/resumed state.
		* Checks the load status of this handler and emits LOAD_READY or LOAD_WAIT events on any state change.
		*/
		protected function onHeartbeatTick(duration:Number, offset:Number):void
		{
			if (this._netStream == null)
			{
				return;
			}
			
			if(this._queuedSeek)
			{
				this.checkQueuedSeekLoadState();
			}
			else
			{
				this.checkPlaybackLoadState();
			}
		}
		
		/**
		* Checks the handler's readiness to perform a deferred seek operation and executes the seek when enough data is available.
		* Acts as a load state checker, and therefore emits LOAD_READY and LOAD_WAIT events.
		*/
		protected function checkQueuedSeekLoadState():void
		{
			if(this.readyToPlayAt(this._queuedSeekTarget))
			{
				SMILKit.logger.debug("checkQueuedSeekLoadState: now ready to seek. About to execute deferred seek.", this);
				
				this.execQueuedSeek();
				
				if(!this._loadReady)
				{
					this._loadReady = true;
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
				}
			}
			else
			{
				SMILKit.logger.debug("checkQueuedSeekLoadState: Not yet ready to seek to target "+this._queuedSeekTarget+"ms.", this);
				
				if(this._loadReady)
				{
					this._loadReady = false;
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
				}
			}
		}
		
		/**
		* Checks the loaded bytes against the known file byte size and determines whether enough data has loaded for playback to continue at the current offset.
		* Called on each heartbeat tick unless a seek operation is queued.
		*/ 
		protected function checkPlaybackLoadState():void
		{
			var percentageLoaded:Number = (this._netStream.bytesLoaded / this._netStream.bytesTotal) * 100;
			var durationLoaded:Number = ((percentageLoaded / 100) * this.duration);
			
			// Update the parent element
			if(this._mediaElement != null)
			{
				this._mediaElement.intrinsicBytesLoaded = this._netStream.bytesLoaded;
				this._mediaElement.intrinsicBytesTotal = this._netStream.bytesTotal;
			}
			
			// if were not already ready, check if we are
			if (!this._loadReady)
			{
				if ((durationLoaded - this.currentOffset) >= (this._netStream.bufferTime * 1000))
				{
					// increase the buffer so we have more ready
					//this._netStream.bufferTime = 30;
					
					this._loadReady = true;
					
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
				}
			}
			// if were ready, check if we need more
			else
			{
				if (!this._completedLoading && ((this.currentOffset) >= durationLoaded))
				{
					// reduce the buffer so we get ready quicker
					//this._netStream.bufferTime = 15;
					
					this._loadReady = false;
					
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
				}
			}
			
			if (percentageLoaded >= 100 && !this._completedLoading && durationLoaded > 0)
			{
				this._completedLoading = true;
				
				SMILKit.logger.debug("Handler has completed loading ("+this._netStream.bytesLoaded+"/"+this._netStream.bytesTotal+" bytes)", this);
				
				this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_COMPLETED, this));
			}
		}
		
		public override function resize():void
		{
			super.resize();
		
			this.drawClickShield(this._video);
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
		
		protected function attachVideoDisplay():void
		{
			SMILKit.logger.error("ATTACHING VIDEO DISPLAY UNIT RIGHT NOW -->");
			
			this._video.attachNetStream(this._netStream as NetStream);
			this._attachVideoDisplayDelayed = false;
			
			this.resize();
		}
		
		protected function clearVideoDisplay():void
		{
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
		
		protected function onNetStatusEvent(e:NetStatusEvent):void
		{
			SMILKit.logger.debug("NetStatus Event on video at internal offset "+this._netStream.time+"s: "+e.info.level+" "+e.info.code);
			
			switch (e.info.code)
			{
				case "NetStream.Buffer.Full":
					//this._netStream.bufferTime = 30; // expand buffer
					
					//this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
					break;
				case "NetStream.Buffer.Empty":
					//this._netStream.bufferTime = 8; // reduce buffer
					
					//this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
					break;
				case "NetStream.Play.Failed":
				case "NetStream.Play.NoSupportedTrackFound":
				case "NetStream.Play.FileStructureInvalid":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
					break;
				case "NetStream.Unpublish.Success":
				case "NetStream.Play.Stop":
					// playback has finished, important for live events (so we can continue)
					this.dispatchEvent(new HandlerEvent(HandlerEvent.STOP_NOTIFY, this));
					break;
				case "NetStream.Pause.Notify":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.PAUSE_NOTIFY, this));
					break;
				case "NetStream.Unpause.Notify":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.RESUME_NOTIFY, this));
					break;
				case "NetStream.Seek.Failed":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_FAILED, this));
					break;
				case "NetStream.Seek.InvalidTime":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_INVALID, this));
					break;
				case "NetStream.Seek.Notify":
					if (!this.seekComplete())
					{
						// need to wait for _netStream.time to update
						SMILKit.logger.debug("Seek complete but NetStream.time still not caught up, waiting before dispatching SEEK_NOTIFY ...");
					
						SharedTimer.every(1, this.onCheckSeekTarget);
					}
					break;
			}
		}
		
		protected function seekComplete():Boolean
		{
			if (NumberHelper.withinTolerance((this._seekingTarget / 1000), this._netStream.time, 2.0))
			{
				this._seeking = false;
				
				if (!this._resumed)
				{
					this._netStream.pause();
				}
				
				this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_NOTIFY, this));
				
				return true;
			}
				
			return false;
		}
		
		protected function onCheckSeekTarget():void
		{
			SMILKit.logger.debug("Checking seek target ("+Math.floor(this._seekingTarget / 1000)+"s) against NetStream.time ("+this._netStream.time+"s)");
			
			if (this.seekComplete())
			{
				SharedTimer.removeEvery(1, this.onCheckSeekTarget);
			}
		}
		
		protected function onIOErrorEvent(e:IOErrorEvent):void
		{
			SMILKit.logger.error("Handler encountered an IO error during load.", this);
			this.cancel();
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function onSecurityErrorEvent(e:SecurityErrorEvent):void
		{
			SMILKit.logger.error("Handler encountered a security error during load.", this);
			this.cancel();			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_UNAUTHORISED, this));
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function onAsyncErrorEvent(e:AsyncErrorEvent):void
		{
			SMILKit.logger.error("Handler encountered an async error during load: "+e.text+", "+e.error.name+", "+e.error.message, this);
		}
		
		public function onCuePoint(info:Object):void
		{
			// ignore
		}
		
		public function onXMPData(info:Object):void
		{
			// ignore
		}
		
		public function onMetaData(info:Object):void
		{	
			if (this._metadata == null)
			{
				this._metadata = new Metadata(info);
				SMILKit.logger.info("Metadata encountered (with "+this.syncPoints.length+" syncPoints): "+this._metadata.toString()+" Source: "+this.element.src);
				if(!this._resumed)
				{
					SMILKit.logger.debug("Found initial metadata while loading/paused. About to reset netstream object to 0 offset and leave paused.", this);
					
					this.seek(0);
					this.pause();
				}
			}
			else
			{
				this._metadata.update(info);
			}

			this.resolved(this._metadata.duration);
			
			if (this._attachVideoDisplayDelayed)
			{
				this.attachVideoDisplay();
			}
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap(['http'], { 'video/flv': [ '.flv', '.f4v' ], 'video/mpeg': [ '.mp4', '.f4v' ] });
		}
	}
}