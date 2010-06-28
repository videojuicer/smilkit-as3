package org.smilkit.handler
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.util.RedirectLoader;
	import org.smilkit.w3c.dom.IElement;
	
	public class ImageHandler extends SMILKitHandler
	{
		protected var _bitmap:Bitmap;
		protected var _loader:RedirectLoader;
		
		protected var _intrinsicWidth:Number = 0;
		protected var _intrinsicHeight:Number = 0;
		
		public function ImageHandler(element:IElement)
		{
			super(element);
		}
		
		public override function get intrinsicWidth():uint
		{
			return this._intrinsicWidth;
		}
		
		public override function get intrinsicHeight():uint
		{
			return this._intrinsicHeight;
		}
		
		public override function get resolvable():Boolean
		{
			return false;
		}
		
		public override function get displayObject():DisplayObject
		{
			return (this._bitmap as DisplayObject);
		}
		
		public override function load():void
		{
			this._loader = new RedirectLoader();
			
			this._loader.addEventListener(Event.COMPLETE, this.onLoaderComplete);
			this._loader.addEventListener(IOErrorEvent.IO_ERROR, this.onLoaderError);
			
			this._loader.load(new URLRequest(this.element.src), new LoaderContext(true));
		}
		
		public override function cancel():void
		{
			// only cancel the image if we havent completed loading
			// theres no point throwing away something that is ready for use!
			if (!this.completedLoading)
			{
				if (this._loader != null)
				{
					this._loader.close();
					this._loader = null;
				}
				
				super.cancel();
			}
		}
		
		protected function onLoaderComplete(e:Event):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_COMPLETED, this));
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
			
			
		}
		
		protected function onLoaderError(e:IOErrorEvent):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap(['http', 'https'], { 'image/jpeg': [ '.jpg', '.jpeg' ], 'image/gif': [ '.gif' ], 'image/png': [ '.png' ], 'image/bmp': [ '.bmp' ] });
		}
	}
}