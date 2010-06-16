package org.smilkit.handler
{
	import flash.events.Event;
	
	public class HandlerEvent extends Event
	{
		public static var SEEK_COMPLETED:String = "handlerSeekedCompleted";
		
		public static var LOAD_READY:String = "handlerLoadReady";
		public static var LOAD_WAITING:String = "handlerLoadWaiting";
		public static var LOAD_CANCELLED:String = "handlerLoadCancelled";
		public static var LOAD_COMPLETED:String = "handlerLoadCompleted";
		
		public static var DURATION_RESOLVED:String = "handlerDurationResolved";
		
		protected var _handler:SMILKitHandler;
		
		public function HandlerEvent(type:String, handler:SMILKitHandler, bubbles:Boolean=false, cancelable:Boolean=false)
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