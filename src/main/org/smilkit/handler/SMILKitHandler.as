package org.smilkit.handler
{
	import org.smilkit.w3c.dom.IElement;

	public class SMILKitHandler
	{
		protected var _element:IElement;
		
		public function SMILKitHandler(element:IElement)
		{
			this._element = element;
		}
		
		public function load():void
		{
			
		}
		
		public function pause():void
		{
			
		}
		
		public function resume():void
		{
			
		}
		
		public function seek(seekTo:Number):void
		{
			
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return null;
			//return new HandlerMap([ "rtmp" ], [ "video/flv" = [ "flv", "f4v" ], "video/mpeg" = [ "mp4", "f4v" ] ]);
		}
	}
}