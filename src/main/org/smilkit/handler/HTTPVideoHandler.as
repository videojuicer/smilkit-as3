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
	
	import org.smilkit.util.Metadata;
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
		
		public override function get intrinsicDuration():uint
		{
			if (this._metadata == null)
			{
				return super.intrinsicDuration;
			}
			
			return this._metadata.duration;
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
		
		public override function load():void
		{
			this._netConnection = new NetConnection();
			this._netConnection.connect(null);
			
			this._soundTransformer = new SoundTransform(0, 0);
			
			this._netStream = new NetStream(this._netConnection);
			
			this._netStream.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatusEvent);
			this._netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.onAsyncErrorEvent);
			this._netStream.addEventListener(IOErrorEvent.IO_ERROR, this.onIOErrorEvent);
			
			this._netStream.client = this;
			this._netStream.soundTransform = this._soundTransformer;
			
			this._netStream.play(this.element.src);
			
			this._video = new Video();
			this._video.smoothing = true;
			this._video.deblocking = 1;
			
			this._video.attachNetStream(this._netStream as NetStream);
		
			this._canvas.addChild(this._video);
		}
		
		public override function resume():void
		{
			this._netStream.resume();
		}
		
		public override function pause():void
		{
			this._netStream.pause();
		}
		
		public override function seek(seekTo:Number):void
		{
			this._netStream.seek(seekTo);
		}
		
		protected function onNetStatusEvent(e:NetStatusEvent):void
		{
			trace("Netstatus: "+e.info.level+" "+e.info.code);
			
			if (e.info.code == "NetStream.Buffer.Full")
			{
				this.resume();
			}
		}
		
		protected function onIOErrorEvent(e:IOErrorEvent):void
		{
			
		}
		
		protected function onSecurityErrorEvent(e:SecurityErrorEvent):void
		{
			
		}
		
		protected function onAsyncErrorEvent(e:AsyncErrorEvent):void
		{
			
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
			
			trace("Metadata recieved: "+this._metadata.toString());
			
			this.resize();
			
			this.resume();
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap(['http'], { 'video/flv': [ '.flv', '.f4v' ], 'video/mpeg': [ '.mp4', '.f4v' ] });
		}
	}
}