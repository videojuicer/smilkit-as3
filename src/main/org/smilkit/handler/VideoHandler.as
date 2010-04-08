package org.smilkit.handler
{
	import org.smilkit.w3c.dom.IElement;
	
	public class VideoHandler extends SMILKitHandler
	{
		public function VideoHandler(element:IElement)
		{
			super(element);
		}
		
		public override function get type():String
		{
			return SMILKitHandler.VIDEO_HANDLER;
		}
	}
}