package org.smilkit.handler
{
	import org.smilkit.w3c.dom.IElement;
	
	public class ImageHandler extends SMILKitHandler
	{
		public function ImageHandler(element:IElement)
		{
			super(element);
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return null;
			//return new HandlerMap([ "rtmp" ], [ "video/flv" = [ "flv", "f4v" ], "video/mpeg" = [ "mp4", "f4v" ] ]);
		}
	}
}