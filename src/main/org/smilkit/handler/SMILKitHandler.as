package org.smilkit.handler
{
	import org.smilkit.w3c.dom.IElement;

	public class SMILKitHandler
	{
		public static var ANIMATION_HANDLER:String = "animation";
		public static var AUDIO_HANDLER:String = "audio";
		public static var IMAGE_HANDLER:String = "img";
		public static var TEXT_HANDLER:String = "text";
		public static var VIDEO_HANDLER:String = "video";
		
		protected var _element:IElement;
		
		public function SMILKitHandler(element:IElement)
		{
			this._element = element;
		}
		
		public function get type():String
		{
			return "";
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
	}
}