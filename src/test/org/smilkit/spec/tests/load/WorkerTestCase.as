package org.smilkit.spec.tests.load
{
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	import flexunit.framework.AsyncTestHelper;
	
	import org.flexunit.async.Async;
	
	import org.smilkit.load.LoadScheduler;
	import org.smilkit.load.Worker;
	import org.smilkit.events.WorkerEvent;

	public class WorkerTestCase
	{		
		protected var _scheduler:LoadScheduler;
		protected var _priorityWorker:Worker;
		protected var _slaveWorker:Worker;
		
		[Before]
		public function setUp():void
		{
			
		}
		
		[After]
		public function tearDown():void
		{
			
		}
	}
	
	// Pending tests:
	
	// is not working until start() is called
	// stops working when stop() is called
	
	// advancing the queue when stopped does nothing, even when below concurrency limit
	
	// advancing the queue when active fills the worklist to capacity
	
	// addHandlerToWorkQueue: adding a handler returns true and appends to the queue
	// addHandlerToWorkQueue: adding a handler that is already on the worklist returns false and does not alter the queue
	// addHandlerToWorkQueue: adding a handler that is already in the workqueue returns false and does not alter the queue
	
	// removeHandlerFromWorkQueue: removing a handler that is on the workqueue returns true and slices the queue
	// removeHandlerFromWorkQueue: removing a handler that is not present on the workqueue returns false and does not alter the queue.
	
	// hasHandler returns true if the given handler is in the workqueue
	// hasHandler returns true if the given handler is in the worklist
	// hasHandler returns false if the given handler is in neither list
	
	// stops working onPriorityWorkerStopped
	// stops working onPriorityWorkerResume
	// stops working onPriorityWorkerStarted
	// starts working onPriorityWorkerIdle
	
	
}