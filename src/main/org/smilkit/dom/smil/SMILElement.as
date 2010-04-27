package org.smilkit.dom.smil
{
	import org.smilkit.dom.Element;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.smilkit.w3c.dom.smil.ITimeList;
	
	public class SMILElement extends Element implements ISMILElement
	{
		public function SMILElement(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		protected function parseTimeAttribute(attributeValue:String, baseBegin:Boolean):ITimeList
		{			
			var list:TimeList = new TimeList();
			
			if (attributeValue == null || attributeValue == "")
			{
				// if theres no attribute value we still need a Timelist of each point
				// as the timelist keeps everything in flow
				var time:Time = new Time(Time.SMIL_TIME_SYNC_BASED);
				time.baseElement = this;
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
					parsedTime.baseElement = this;
					parsedTime.baseBegin = baseBegin;
					
					list.add(parsedTime);
				}
			}
			
			return list;
		}
	}
}