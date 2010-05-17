package org.smilkit.events
{
	import flash.events.Event;

	public class RenderTreeEvent extends Event
	{
		public static var ELEMENT_REMOVED:String = "renderTreeElementRemoved";
		public static var ELEMENT_ADDED:String = "renderTreeElementAdded";
		public static var ELEMENT_REPLACED:String = "renderTreeElementReplaced";
		public static var ELEMENT_MODIFIED:String = "renderTreeElementModified";
		
		public function RenderTreeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}