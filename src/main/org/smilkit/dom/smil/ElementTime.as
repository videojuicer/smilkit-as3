package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.smil.ITimeList;

	public class ElementTime
	{
		public static var RESTART_ALWAYS:int = 0;
		public static var RESTART_NEVER:int = 1;
		public static var RESTART_WHEN_NOT_ACTIVE:int = 2;
		
		public static var FILL_REMOVE:int = 0;
		public static var FILL_FREEZE:int = 1;
		
		public static function parseTimeAttribute(attributeValue:String, baseElement:IElement, baseBegin:Boolean):ITimeList
		{			
			var list:TimeList = new TimeList();
			
			if (attributeValue == null || attributeValue == "")
			{
				// if theres no attribute value we still need a Timelist of each point
				// as the timelist keeps everything in flow
				var time:Time = new Time(Time.SMIL_TIME_SYNC_BASED);
				time.baseElement = baseElement;
				time.baseBegin = baseBegin;
				
				list.add(time);
			}
			else
			{
				var values:Array = attributeValue.split(",");
				
				for (var i:int = 0; i < values.length; i++)
				{
					var v:String = values[i];
					
					// work out what v is, wallclock, event, sync based time etc...
					
					var parsedTime:Time = new Time(Time.SMIL_TIME_SYNC_BASED);
					parsedTime.baseElement = baseElement;
					parsedTime.baseBegin = baseBegin;
					
					list.add(parsedTime);
				}
			}
			
			return list;
		}
	}
}