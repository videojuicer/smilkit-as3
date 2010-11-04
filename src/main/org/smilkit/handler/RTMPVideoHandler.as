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
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.handler.state.HandlerState;
	import org.smilkit.handler.state.VideoHandlerState;
	import org.smilkit.render.RegionContainer;
	import org.smilkit.util.Metadata;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.smil.ISMILRegionElement;
	import org.utilkit.logger.Logger;
	
	public class RTMPVideoHandler extends SMILKitHandler
	{
		protected var _netConnection:NetConnection;
		protected var _netStream:NetStream;
		protected var _video:Video;
		protected var _soundTransformer:SoundTransform;
		protected var _metadata:Metadata;
		protected var _canvas:Sprite;
		protected var _volume:uint;
		
		protected var _playOptions:NetStreamPlayOptions;
		
		public function RTMPVideoHandler(element:IElement)
		{
			super(element);
			
			this._canvas = new Sprite();
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
		
		public override function get preloadable():Boolean
		{
			return false;
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
		
		public function get videoHandlerState():VideoHandlerState
		{
			return (this.handlerState as VideoHandlerState);
		}
		
		public override function load():void
		{
			this._playOptions = new NetStreamPlayOptions();
			
			this._soundTransformer = new SoundTransform(0.2, 0);
			
			if(this._volume)
			{
				this.setVolume(this._volume);
			}
			
			this._netConnection = new NetConnection();
			this._netConnection.client = this;
			
			this._netConnection.addEventListener(NetStatusEvent.NET_STATUS, this.onConnectionNetStatusEvent);
			this._netConnection.addEventListener(IOErrorEvent.IO_ERROR, this.onConnectionIOErrorEvent);
			this._netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.onConnectionAsyncErrorEvent);
			this._netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onConnectionSecurityErrorEvent);
			
			this._startedLoading = true;
			
			this._netConnection.connect(this.videoHandlerState.fmsURL.instanceHostname);
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
		}
		
		public override function merge(handlerState:HandlerState):Boolean
		{
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

				return true;
			}
			
			return false;
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

				this._netStream.resume();
			}
		}
		
		public override function pause():void
		{
			if (this._netStream != null)
			{
				SMILKit.logger.debug("Pausing playback.", this);

				this._netStream.pause();
			}
		}
		
		public override function seek(seekTo:Number):void
		{
			var seconds:Number = (seekTo / 1000);
			SMILKit.logger.debug("Executing internal seek to "+seekTo+"ms ("+seconds+"s)", this);
			
			this._netStream.seek(seconds);
		}
		
		public override function cancel():void
		{
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
			
			this.drawClickShield(this._video);
		}
		
		protected function onConnectionNetStatusEvent(e:NetStatusEvent):void
		{
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
					this._netStream = new NetStream(this._netConnection);
					
					this._netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.onAsyncErrorEvent);
					this._netStream.addEventListener(IOErrorEvent.IO_ERROR, this.onIOErrorEvent);
					this._netStream.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatusEvent);

					this._netStream.client = this;
					
					this._netStream.play(this.videoHandlerState.fmsURL.streamNameWithParameters);
					
					this._video = new Video();
					this._video.smoothing = true;
					this._video.deblocking = 1;
					
					this._video.attachNetStream(this._netStream);
					
					this._canvas.addChild(this._video);
					
					this.drawClickShield(this._video);
					
					break;
			}
		}
		
		public function onBWDone(... rest):void
		{
			SMILKit.logger.debug("Bandwidth received on NetConnection from Flash Media Server", this);	
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
		
		protected function onNetStatusEvent(e:NetStatusEvent):void
		{
			SMILKit.logger.debug("NetStatusEvent: "+e.info.code+" "+e.info.description, e);
			
			switch (e.info.code)
			{
				case "NetStream.Buffer.Full":
					//this._netStream.bufferTime = 30; // expand buffer
					
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
					break;
				case "NetStream.Buffer.Empty":
					//this._netStream.bufferTime = 8; // reduce buffer
					
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
					break;
				case "NetStream.Failed":
				case "NetStream.Play.Failed":
				case "NetStream.Play.NoSupportedTrackFound":
				case "NetStream.Play.FileStructureInvalid":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
					break;
				case "NetStream.Unpublish.Success":
				case "NetStream.Play.Stop":
					// playback has finished, important for live events (so we can continue)
					break;
				case "NetStream.Play.InsufficientBW":
					// show drop down
					break;
				case "NetStream.Pause.Notify":
					break;
				case "NetStream.Unpause.Notify":
					break;
				case "NetStream.Seek.Failed":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_FAILED, this));
					break;
				case "NetStream.Seek.InvalidTime":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_INVALID, this));
					break;
				case "NetStream.Seek.Notify":
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
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		public function onMetaData(info:Object):void
		{
			if (this._metadata == null)
			{
				this._metadata = new Metadata(info);
			}
			else
			{
				this._metadata.update(info);
			}

			SMILKit.logger.info("Metadata recieved: "+this._metadata.toString());
			
			if (isNaN(this._metadata.duration) || this._metadata.duration <= 0)
			{
				this.resolved(Time.INDEFINITE);
			}
			else
			{
				this.resolved(this._metadata.duration);
			}
			
			// were ready as soon as we have the metadata
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
		}	
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap([ 'rtmp', 'rtmpt', 'rtmps', 'rtmpe' ], { 'video/flv': [ '.flv', '.f4v' ], 'video/mpeg': [ '.mp4', '.f4v' ] });
		}
	}
}