package org.smilkit.handler
{
	import org.smilkit.w3c.dom.IElement;
	
	public class ImageHandler extends SMILKitHandler
	{
		public function ImageHandler(element:IElement)
		{
			super(element);
		}
		
		public override function get type():String
		{
			return SMILKitHandler.IMAGE_HANDLER;
		}
	}
}