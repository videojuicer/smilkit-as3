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
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
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
		
		public function HTTPVideoHandler(element:IElement)
		{
			super(element);
			
			this._canvas = new Sprite();
		}

		public override function get intrinsicWidth():uint
		{
			if (this._metadata == null)
			{
				return super.intrinsicWidth;
			}
			
			return this._metadata.width;
		}
		
		public override function get intrinsicHeight():uint
		{
			if (this._metadata == null)
			{
				return super.intrinsicHeight;
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
		
		public override function get syncable():Boolean
		{
			return true;
		}

		public override function get intrinsicSpatial():Boolean
		{
			return false;
		}
		
		public override function get intrinsicTemporal():Boolean
		{
			return false;
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
		
			this._canvas.addChild(this._video);
			
			this._startedLoading = true;
		}
		
		public override function resume():void
		{
			if (this._netStream != null)
			{
				this._netStream.resume();
			}
		}
		
		public override function pause():void
		{
			if (this._netStream != null)
			{
				this._netStream.pause();
			}
		}
		
		public override function seek(seekTo:Number):void
		{
			if (this._netStream != null)
			{
				this._netStream.seek(seekTo);
			}
		}
		
		public override function merge(handlerState:HandlerState):Boolean
		{
			// cant merge anything with a http video!
			
			return false;
		}
		
		public override function cancel():void
		{
			this._netStream.close();
			this._netConnection.close();
			
			this._netConnection = null;
			this._netStream = null;
			
			super.cancel();
		}
		
		protected function onNetStatusEvent(e:NetStatusEvent):void
		{
			trace("Netstatus: "+e.info.level+" "+e.info.code);
			
			switch (e.info.code)
			{
				case "NetStream.Buffer.Full":
					this._netStream.bufferTime = 30; // expand buffer
					
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
					break;
				case "NetStream.Buffer.Empty":
					this._netStream.bufferTime = 8; // reduce buffer
					
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
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
			
			Logger.info("Metadata recieved: "+this._metadata.toString());
			
			this.resolved(this._metadata.duration);
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap(['http'], { 'video/flv': [ '.flv', '.f4v' ], 'video/mpeg': [ '.mp4', '.f4v' ] });
		}
	}
}