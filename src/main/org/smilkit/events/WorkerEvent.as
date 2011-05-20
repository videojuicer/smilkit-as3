package org.smilkit.events
{
	import flash.events.Event;
	
	import org.smilkit.load.Worker;	
	
	public class WorkerEvent extends Event
	{
		public static var WORKER_STARTED:String = "workerStarted";
		public static var WORKER_STOPPED:String = "workerStopped";
		public static var WORKER_IDLE:String = "workerIdling";
		public static var WORKER_RESUMED:String = "workerResumed";
		
		protected var _worker:Worker;
		
		public function WorkerEvent(type:String, worker:Worker, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._worker = worker;
		}
		
		public function get worker():Worker
		{
			return this._worker;
		}
	}
}