package org.smilkit.events
{
	import flash.events.Event;
	import org.smilkit.handler.SMILKitHandler;	
	
	public class WorkUnitEvent extends Event
	{
		public static var WORK_UNIT_QUEUED:String = "workUnitQueued";
		public static var WORK_UNIT_LISTED:String = "workUnitListed";
		
		public static var WORK_UNIT_ACTIVE:String = "workUnitStarted";
		public static var WORK_UNIT_COMPLETED:String = "workUnitCompleted";
		public static var WORK_UNIT_FAILED:String = "workUnitFailed";
		
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