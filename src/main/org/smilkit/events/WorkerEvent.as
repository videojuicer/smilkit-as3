package org.smilkit.events
{
	import flash.events.Event;
		
	public class WorkerEvent extends Event
	{
		public static var WORKER_STARTED:String = "workerStarted";
		public static var WORKER_STOPPED:String = "workerStopped";
		public static var WORKER_IDLE:String = "workerIdling";
		public static var WORKER_RESUMED:String = "workerResumed";
		
		public static var WORK_UNIT_STARTED:String = "workUnitStarted";
		public static var WORK_UNIT_COMPLETED:String = "workUnitCompleted";
		
		public function WorkerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}