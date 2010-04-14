package org.smilkit.event
{
	import org.smilkit.w3c.dom.DOMException;
	
	public class EventException extends RuntimeException
	{
		public static var UNSPECIFIED_EVENT_TYPE_ERR:int = 0;
		
		public function EventException(type:int, message:String)
		{
			super(type, message);
		}
	}
}