package org.smilkit.handler
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import org.smilkit.util.RedirectLoader;
	import org.smilkit.w3c.dom.IElement;
	
	public class ImageHandler extends SMILKitHandler
	{
		protected var _bitmap:Bitmap;
		protected var _loader:RedirectLoader;
		
		public function ImageHandler(element:IElement)
		{
			super(element);
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
			
			super.cancel();
		}
		
		protected function onLoaderComplete(e:Event):void
		{
			
		}
		
		protected function onLoaderError(e:IOErrorEvent):void
		{
			
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap(['http', 'https'], { 'image/jpeg': [ '.jpg', '.jpeg' ], 'image/gif': [ '.gif' ], 'image/png': [ '.png' ], 'image/bmp': [ '.bmp' ] });
		}
	}
}