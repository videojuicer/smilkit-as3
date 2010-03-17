package org.smilkit.w3c.dom
{
	import flash.events.Event;
	
	public class DOMException extends Event
	{
		public function DOMException(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}