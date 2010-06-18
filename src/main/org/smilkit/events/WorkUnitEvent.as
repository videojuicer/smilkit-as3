package org.smilkit.events
{
	import flash.events.Event;
	import org.smilkit.handler.SMILKitHandler;	
	
	public class WorkUnitEvent extends Event
	{
		public static var WORK_UNIT_QUEUED:String = "workUnitQueued"; // Dispatched when an item is added to the worker's queue
		public static var WORK_UNIT_LISTED:String = "workUnitListed"; // Dispatched when an item is moved to the worklist
		public static var WORK_UNIT_REMOVED:String = "workUnitRemoved"; // Dispatched when an item is removed from either list by imperative.
		
		public static var WORK_UNIT_COMPLETED:String = "workUnitCompleted"; // Dispatched when the completion event on a handler is received
		public static var WORK_UNIT_FAILED:String = "workUnitFailed"; // Dispatched when the failure event on a handler is received
		
		protected var _handler:SMILKitHandler;
		
		public function WorkUnitEvent(type:String, handler:SMILKitHandler, bubbles:Boolean=false, cancelable:Boolean=false)
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