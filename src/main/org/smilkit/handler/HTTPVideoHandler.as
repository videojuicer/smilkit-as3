package org.smilkit.handler
{
	import org.smilkit.w3c.dom.IElement;
	
	public class HTTPVideoHandler extends SMILKitHandler
	{
		public function HTTPVideoHandler(element:IElement)
		{
			super(element);
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap(['http'], { 'video/flv': [ '.flv', '.f4v' ], 'video/mpeg': [ '.mp4', '.f4v' ] });
		}
	}
}