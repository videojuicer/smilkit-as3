package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;

	public class ElementTime
	{
		public static var RESTART_ALWAYS:int = 0;
		public static var RESTART_NEVER:int = 1;
		public static var RESTART_WHEN_NOT_ACTIVE:int = 2;
		
		public static var FILL_REMOVE:int = 0;
		public static var FILL_FREEZE:int = 1;
		
		public static function timeAttributeToTimeType(value:String, baseElement:IElementTimeContainer, baseBegin:Boolean):int
		{
			var type:int = Time.SMIL_TIME_SYNC_BASED;
			
			// we only care if the duration is indefinite if were at the end, as the begin node will always
			// follow its parent or previous sibling
			if (baseElement.dur == "indefinite" && !baseBegin)
			{
				type = Time.SMIL_TIME_INDEFINITE;
			}
			
			return type;
		}
	}
}