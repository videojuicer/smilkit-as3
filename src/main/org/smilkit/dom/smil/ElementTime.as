package org.smilkit.dom.smil
{
	import org.smilkit.parsers.SMILTimeParser;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ITimeList;

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
		
		public static function parseTimeAttribute(attributeValue:String, baseElement:INode, baseBegin:Boolean):ITimeList
		{	
			/*
			var list:TimeList = null; //new TimeList();
			
			if (attributeValue == null || attributeValue == "")
			{
				// if theres no attribute value we still need a Timelist of each point
				// as the timelist keeps everything in flow
				var time:Time = new Time(ElementTime.timeAttributeToTimeType(Time.INDEFINITE.toString(), (baseElement as IElementTimeContainer), baseBegin));
				time.baseElement = baseElement;
				time.baseBegin = baseBegin;
				
				list.add(time);
				
				if (!baseElement is ISMILDocument)
				{
					var container:ElementTimeContainer = baseElement as ElementTimeContainer;
					
					if (container != null && container.repeatCount > 0 || container.repeatDur > 0)
					{
						if (container.repeatDur > 0)
						{
							container.repeatCount = container.repeatDur / container.duration;
						}
						
						// make a new time element for reach repeat
						for (var j:int = 0; j < container.repeatCount; j++)
						{
							time = new Time(Time.SMIL_TIME_SYNC_BASED);
							time.baseElement = baseElement;
							time.baseBegin = baseBegin;
						
							list.add(time);
						}
					}
				}
			}
			else
			{
				var values:Array = attributeValue.split(",");
				
				for (var i:int = 0; i < values.length; i++)
				{
					var v:String = values[i];
					
					// should parse v into a milliseconds
					
					var parser:SMILTimeParser = new SMILTimeParser(baseElement, v);
					
					
					var parsedTime:Time = new Time(ElementTime.timeAttributeToTimeType(v, (baseElement as IElementTimeContainer), baseBegin));
					parsedTime.baseElement = baseElement;
					parsedTime.baseBegin = baseBegin;
					parsedTime.baseBeginOffset = parser.milliseconds;
					
					list.add(parsedTime);
				}
			}
			*/
			return null;
		}
	}
}