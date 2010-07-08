package org.smilkit.events
{
	import flash.events.Event;
	
	import org.smilkit.handler.SMILKitHandler;

	public class RenderTreeEvent extends Event
	{
		public static var ELEMENT_REMOVED:String = "renderTreeElementRemoved";
		public static var ELEMENT_ADDED:String = "renderTreeElementAdded";
		public static var ELEMENT_REPLACED:String = "renderTreeElementReplaced";
		public static var ELEMENT_MODIFIED:String = "renderTreeElementModified";
		
		public static var READY:String = "renderTreeReady";
		public static var WAITING_FOR_DATA:String = "renderTreeWaitingForData";
		public static var WAITING_FOR_SYNC:String = "renderTreeWaitingForSync";
		
		protected var _handler:SMILKitHandler;
		
		public function RenderTreeEvent(type:String, handler:SMILKitHandler, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this._handler = handler;
		}
		
		public function get handler():SMILKitHandler
		{
			return this._handler;
		}
	}
}