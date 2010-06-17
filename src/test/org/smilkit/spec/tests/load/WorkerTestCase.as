package org.smilkit.spec.tests.load
{
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	import flexunit.framework.AsyncTestHelper;
	
	import org.flexunit.async.Async;
	
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.load.LoadScheduler;
	import org.smilkit.load.Worker;
	import org.smilkit.events.WorkerEvent;

	public class WorkerTestCase
	{		
		protected var _priorityWorker:Worker;
		protected var _slaveWorker:Worker;
		
		protected var _handlerPool:Vector.<SMILKitHandler>;
		
		// Mock event names used for testing the event loops
		protected var _dummyResolveEventName:String = "dummyResolveCompleted";
		protected var _dummyCompleteEventName:String = "dummyLoadCompleted";
		protected var _dummyFailedEventName:String = "dummyFailedBecauseHeIsADummy";
		
		[Before]
		public function setUp():void
		{
			// no concurrency limit
			this._priorityWorker = new Worker(this._dummyResolveEventName, this._dummyFailedEventName);
			// set concurrency limit, slaved to priority worker
			this._slaveWorker = new Worker(this._dummyCompleteEventName, this._dummyFailedEventName, 3, this._priorityWorker);
			
			// create a pool of handlers to work with
			
		}
		
		[After]
		public function tearDown():void
		{
			this._priorityWorker = null;
			this._slaveWorker = null;
			this._handlerPool = null;
		}
		
		[Test(description="Tests the start/stop toggle from a stopped state")]
		public function startFunctionsOnlyOnceAndSetsWorkingToTrue():void {
			Assert.assertFalse(this._priorityWorker.working);
			Assert.assertFalse(this._priorityWorker.stop());
			Assert.assertTrue(this._priorityWorker.start());
			Assert.assertTrue(this._priorityWorker.working);
		}

		[Test(description="Tests the start/stop toggle from a started state")]
		public function stopFunctionsOnceOnlyAndSetsWorkingToFalse():void {
			this._priorityWorker.start();
			Assert.assertFalse(this._priorityWorker.start());
			Assert.assertTrue(this._priorityWorker.working);
			Assert.assertTrue(this._priorityWorker.stop());
			Assert.assertFalse(this._priorityWorker.working);
		}
		
		// advancing the queue when stopped does nothing, even when below concurrency limit
		[Test(description="Tests the advance() method to ensure that nothing is advanced when the worker is stopped")]
		public function advanceDoesNotMoveItemsToWorkListWhenStopped():void {
			
		}
		
	}
	
	// Pending tests:
	
	
	
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