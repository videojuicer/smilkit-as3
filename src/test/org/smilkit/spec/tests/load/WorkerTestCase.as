package org.smilkit.spec.tests.load
{
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	import flexunit.framework.AsyncTestHelper;
	
	import org.flexunit.async.Async;
	
	import org.smilkit.spec.Fixtures;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.dom.Element;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.load.LoadScheduler;
	import org.smilkit.load.Worker;
	import org.smilkit.events.WorkerEvent;
	
	import org.smilkit.spec.mock.MockHandler;

	public class WorkerTestCase
	{		
		protected var _priorityWorker:Worker;
		protected var _slaveWorker:Worker;
		
		protected var _document:ISMILDocument;
		protected var _handlerPoolSize:uint = 20;
		protected var _elementPool:Vector.<Element>;
		protected var _handlerPool:Vector.<SMILKitHandler>; 
		
		// Mock event names used for testing the event loops
		protected var _dummyResolveEventName:String = "dummyResolveCompleted";
		protected var _dummyCompleteEventName:String = "dummyLoadCompleted";
		protected var _dummyFailedEventName:String = "dummyFailedBecauseHeIsADummy";
		
		protected var _slaveWorkerConcurrency:uint = 3;
		
		[Before]
		public function setUp():void
		{
			// Set up a document, a set of nodes, and some handlers for it
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.MP4_VIDEO_SMIL_XML) as ISMILDocument);
			this._elementPool = new Vector.<Element>;
			this._handlerPool = new Vector.<SMILKitHandler>;
			for(var i:uint=0; i < this._handlerPoolSize; i++)
			{
				// create element and add to elementPool
				var e:Element = new Element(this._document, "mock");
				this._elementPool.push(e);
				
				// create mockhandler and add to handlerPool
				var h:MockHandler = new MockHandler(e);
				this._handlerPool.push(h);
			}
			
			// no concurrency limit
			this._priorityWorker = new Worker(this._dummyResolveEventName, this._dummyFailedEventName);
			// set concurrency limit, slaved to priority worker
			this._slaveWorker = new Worker(this._dummyCompleteEventName, this._dummyFailedEventName, this._slaveWorkerConcurrency, this._priorityWorker);
			
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
		
		[Test(description="Tests the addHandlerToWorkQueue() method to ensure that the queue is not filled when not started")]
		public function advanceDoesNotMoveItemsToWorkListWhenStopped():void {
			Assert.assertFalse(this._priorityWorker.working);
			// add some items to the queue
			for(var i:uint=0; i<6; i++)
			{
				var h:SMILKitHandler = this._handlerPool[i];
				// Put some items on the priority worker, which has no set concurrency
				this._priorityWorker.addHandlerToWorkQueue(h);
				Assert.assertFalse(this._priorityWorker.hasHandlerInWorkList(h));
				Assert.assertTrue(this._priorityWorker.hasHandlerInWorkQueue(h));
				
				// Put some items on the slave worker, which has limited concurrency
				this._slaveWorker.addHandlerToWorkQueue(h);
				Assert.assertFalse(this._slaveWorker.hasHandlerInWorkList(h));
				Assert.assertTrue(this._slaveWorker.hasHandlerInWorkQueue(h));
			}
			
		}
		
		// advancing the queue when active fills the worklist to capacity
		// advancing the queue when worklist filled to capacity moves no items
		[Test(description="Tests the start() method on populated workers to ensure that the queue is filled to capacity")]
		public function startingAdvancesAndFillsTheWorkListToCapacity():void {
			Assert.assertFalse(this._priorityWorker.working);
			// add some items to the queue
			for(var i:uint=0; i<6; i++)
			{
				var h:SMILKitHandler = this._handlerPool[i];
				// Put some items on the priority worker, which has no set concurrency
				this._priorityWorker.addHandlerToWorkQueue(h);
				// Put some items on the slave worker, which has limited concurrency
				this._slaveWorker.addHandlerToWorkQueue(h);
			}
			this._priorityWorker.start();
			this._slaveWorker.start();
			for(var j:uint=0; j<6; j++)
			{
				var o:SMILKitHandler = this._handlerPool[j];
				Assert.assertTrue(this._priorityWorker.hasHandlerInWorkList(o));
				Assert.assertFalse(this._priorityWorker.hasHandlerInWorkQueue(o));
				
				if(j < this._slaveWorkerConcurrency)
				{
					// should have workers up to the concurrency count in the list
					Assert.assertTrue(this._slaveWorker.hasHandlerInWorkList(o));
					Assert.assertFalse(this._slaveWorker.hasHandlerInWorkQueue(o));
				}
				else 
				{
					// everything else should be in the queue
					Assert.assertFalse(this._slaveWorker.hasHandlerInWorkList(o));
					Assert.assertTrue(this._slaveWorker.hasHandlerInWorkQueue(o));
				}
			}
		}
	}
	
	// Pending tests:
	
	
	

	
	// advancing the queue when nothing is queued or listed fires the IDLE event
	// idle event does not fire if worker was idle last advance
	
	// advancing the queue when things are queued and the worker was idle last advance transmits resume event
	// resume event does not fire if worker was not previously idle
	
	// stopping rewinds the queue
	// rewinding moves all workList items to the front of the workQueue
	
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