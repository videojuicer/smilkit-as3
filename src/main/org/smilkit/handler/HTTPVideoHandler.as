package org.smilkit.handler
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
	
	import org.osmf.events.TimeEvent;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.handler.state.HandlerState;
	import org.smilkit.handler.state.VideoHandlerState;
	import org.smilkit.util.Metadata;
	import org.smilkit.util.logger.Logger;
	import org.smilkit.w3c.dom.IElement;
	
	public class HTTPVideoHandler extends SMILKitHandler
	{
		protected var _netConnection:NetConnection;
		protected var _netStream:NetStream;
		protected var _video:Video;
		protected var _soundTransformer:SoundTransform;
		protected var _metadata:Metadata;
		protected var _canvas:Sprite;
		
		protected var _loadReady:Boolean = false;
		
		public function HTTPVideoHandler(element:IElement)
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
		
		public override function get handlerState():HandlerState
		{
			return new VideoHandlerState(this.element.src, 0, this._netConnection, this._netStream, this._video, this._canvas);	
		}
		
		public override function load():void
		{
			this._netConnection = new NetConnection();
			this._netConnection.connect(null);
			
			this._soundTransformer = new SoundTransform(0.2, 0);
			
			this._netStream = new NetStream(this._netConnection);
			
			this._netStream.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatusEvent);
			this._netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.onAsyncErrorEvent);
			this._netStream.addEventListener(IOErrorEvent.IO_ERROR, this.onIOErrorEvent);
			
			this._netStream.client = this;
			this._netStream.bufferTime = 10;
			this._netStream.soundTransform = this._soundTransformer;
			
			this._netStream.play(this.element.src);
			
			this._video = new Video();
			this._video.smoothing = true;
			this._video.deblocking = 1;
			
			this._video.attachNetStream(this._netStream as NetStream);
			
			// dont want to actually play it back right now
			
			this._canvas.addChild(this._video);
			
			this._startedLoading = true;
			
			if (this.viewportObjectPool != null)
			{
				this.viewportObjectPool.viewport.heartbeat.addEventListener(TimerEvent.TIMER, this.onHeartbeatTick);
			}
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
		}
		
		public override function resume():void
		{
			if (this._netStream != null)
			{
				Logger.debug("Resuming playback.", this)
				this._netStream.resume();
			}
		}
		
		public override function pause():void
		{
			if (this._netStream != null)
			{
				Logger.debug("Pausing playback.", this)
				this._netStream.pause();
			}
		}
		
		public override function seek(seekTo:Number):void
		{
			if (this._netStream != null)
			{
				Logger.debug("Seeking internally to "+seekTo+"ms.", this);
				this._netStream.seek(seekTo/1000);
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
				this.viewportObjectPool.viewport.heartbeat.removeEventListener(TimerEvent.TIMER, this.onHeartbeatTick);
			}
			
			this._netStream.close();
			this._netConnection.close();
			
			this._netConnection = null;
			this._netStream = null;
			
			for (var i:int = 0; i < this._canvas.numChildren; i++)
			{
				this._canvas.removeChildAt(i);
			}
			
			super.cancel();
		}
		
		protected function onHeartbeatTick(e:TimerEvent):void
		{
			var percentageLoaded:Number = (this._netStream.bytesLoaded / this._netStream.bytesTotal) * 100;
			var durationLoaded:Number = ((percentageLoaded / 100) * this.duration) * 1000;
			
			// if were not already ready, check if we are
			if (!this._loadReady)
			{
				if (durationLoaded >= (this._netStream.bufferTime * 1000))
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
				if ((this.currentOffset + 5) >= durationLoaded)
				{
					// reduce the buffer so we get ready quicker
					//this._netStream.bufferTime = 15;
					
					this._loadReady = false;
					
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
				}
			}
		}
		
		protected function onNetStatusEvent(e:NetStatusEvent):void
		{
			Logger.debug("NetStatus Event on video: "+e.info.level+" "+e.info.code);
			
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
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_NOTIFY, this));
					break;
			}
		}
		
		protected function onIOErrorEvent(e:IOErrorEvent):void
		{
			this.cancel();
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function onSecurityErrorEvent(e:SecurityErrorEvent):void
		{
			this.cancel();
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_UNAUTHORISED, this));
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function onAsyncErrorEvent(e:AsyncErrorEvent):void
		{
			this.cancel();
			
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
			
			Logger.info("Metadata recieved: "+this._metadata.toString());
				
			this._netStream.pause();
			
			this.resolved(this._metadata.duration);
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap(['http'], { 'video/flv': [ '.flv', '.f4v' ], 'video/mpeg': [ '.mp4', '.f4v' ] });
		}
	}
}