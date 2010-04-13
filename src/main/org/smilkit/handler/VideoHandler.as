package org.smilkit.handler
{
	import org.smilkit.w3c.dom.IElement;
	
	public class VideoHandler extends SMILKitHandler
	{
		public function VideoHandler(element:IElement)
		{
			super(element);
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap(['rtmp'], { 'video/flv': [ 'flv', 'f4v' ], 'video/mpeg': [ 'mp4', 'f4v' ] });
		}
	}
}