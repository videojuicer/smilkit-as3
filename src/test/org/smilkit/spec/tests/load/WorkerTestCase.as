/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
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
	import org.smilkit.events.WorkUnitEvent;
	
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
		
		// Used to pick up event dispatches during tests
		protected var _onWorkerIdleFlag:Boolean;
		protected var _onWorkerResumedFlag:Boolean;
		
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
			this._priorityWorker.loggerName = "priorityWorker";
			// set concurrency limit, slaved to priority worker
			this._slaveWorker = new Worker(this._dummyCompleteEventName, this._dummyFailedEventName, this._slaveWorkerConcurrency, this._priorityWorker);
			this._slaveWorker.loggerName = "slaveWorker";

			// Reset event flags
			this._onWorkerIdleFlag = false;
			this._onWorkerResumedFlag = false;			
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
		
		[Test(description="Tests the start() method on a populated worker with no concurrency to ensure that the queue is filled to capacity")]
		public function startingWorkerWithNoConcurrencyAdvancesAndFillsTheWorkListToCapacity():void {
			Assert.assertFalse(this._priorityWorker.working);
			// add some items to the queue
			for(var i:uint=0; i<6; i++)
			{
				var h:SMILKitHandler = this._handlerPool[i];
				this._priorityWorker.addHandlerToWorkQueue(h);
			}
			Assert.assertEquals(this._priorityWorker.advanceCapacity(), 6);
			this._priorityWorker.start();
			for(var j:uint=0; j<6; j++)
			{
				var o:SMILKitHandler = this._handlerPool[j];
				Assert.assertTrue(this._priorityWorker.hasHandlerInWorkList(o));
				Assert.assertFalse(this._priorityWorker.hasHandlerInWorkQueue(o));
			}
		}
		
		[Test(description="Tests the start() method on a populated worker with a set concurrency limit to ensure that the queue is filled to capacity")]
		public function startingWorkerWithLimitedConcurrencyAdvancesAndFillsTheWorkListToCapacity():void {
			// add some items to the queue
			for(var i:uint=0; i<6; i++)
			{
				var h:SMILKitHandler = this._handlerPool[i];
				this._slaveWorker.addHandlerToWorkQueue(h);
			}
			Assert.assertEquals(this._slaveWorker.advanceCapacity(), 3);
			this._slaveWorker.start();
			for(var j:uint=0; j<6; j++)
			{
				var o:SMILKitHandler = this._handlerPool[j];
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

		// advancing the queue when nothing is queued or listed fires the IDLE event
		// advancing the queue when things are queued and the worker was idle last advance transmits resume event
		[Test(description="Tests the event dispatcher to ensure that the WORKER_IDLE event is dispatched only when transitioning to the idle state")]
		public function advancingWorkerDispatchesIdleOrResumedEventAppropriately():void {
			// Set up with local event listeners
			Assert.assertFalse(this._onWorkerIdleFlag);
			Assert.assertFalse(this._priorityWorker.working);
			this._priorityWorker.addEventListener(WorkerEvent.WORKER_IDLE, this.onWorkerIdle);
			this._priorityWorker.addEventListener(WorkerEvent.WORKER_RESUMED, this.onWorkerResumed);
			
			// idle event dispatched when working but nothing to do
			this._priorityWorker.start();
			Assert.assertTrue(this._onWorkerIdleFlag);
			Assert.assertFalse(this._onWorkerResumedFlag);

			// idle event does not fire if worker was idle last advance
			this._onWorkerIdleFlag = false;
			this._priorityWorker.advance();
			Assert.assertFalse(this._onWorkerIdleFlag);
			
			// resume event is dispatched when work given
			this._priorityWorker.addHandlerToWorkQueue(this._handlerPool[0]);
			Assert.assertTrue(this._onWorkerResumedFlag);
			
			// resume event does not fire if worker not idle when given more work
			this._onWorkerResumedFlag = false;
			this._priorityWorker.addHandlerToWorkQueue(this._handlerPool[1]);
			Assert.assertFalse(this._onWorkerResumedFlag);
		}
		// Matching private receiver for above test
		protected function onWorkerIdle(event:WorkerEvent):void
		{
			this._onWorkerIdleFlag = true;
		}
		protected function onWorkerResumed(event:WorkerEvent):void
		{
			this._onWorkerResumedFlag = true;
		}
		
		[Test(description="Tests the priority worker event listeners to ensure that right of way is correctly given to the priority worker")]
		public function priorityWorkerEventsAreHandledBySlaveWorker():void
		{
			// Populate priority worker and slave worker
			for(var i:uint=0; i<6; i++)
			{
				this._priorityWorker.addHandlerToWorkQueue(this._handlerPool[i]);
				this._slaveWorker.addHandlerToWorkQueue(this._handlerPool[i+6]);
			}
			
			// Assert starting state
			Assert.assertFalse(this._priorityWorker.working);
			Assert.assertFalse(this._slaveWorker.working);
			
			// stops working onPriorityWorkerStarted
			this._slaveWorker.start();
			Assert.assertTrue(this._slaveWorker.working);
			this._priorityWorker.start();
			Assert.assertFalse(this._slaveWorker.working);
			
			// stops working onPriorityWorkerStopped
			this._priorityWorker.start();
			this._slaveWorker.start();
			Assert.assertTrue(this._slaveWorker.working);
			this._priorityWorker.stop();
			Assert.assertFalse(this._slaveWorker.working);
			
			// starts working onPriorityWorkerIdle
			this._slaveWorker.stop();
			this._priorityWorker.start();
			for(var j:uint=0; j<6; j++)
			{
				// remove handlers from priority worker
				this._priorityWorker.removeHandler(this._handlerPool[j]);
			}
			Assert.assertTrue(this._priorityWorker.idle);
			Assert.assertTrue(this._slaveWorker.working);
			
			// stops working onPriorityWorkerResume
			for(var k:uint=0; k<6; k++)
			{
				// dump more handlers on to the priority worker to make it resume
				this._priorityWorker.addHandlerToWorkQueue(this._handlerPool[k]);
			}
			Assert.assertFalse(this._priorityWorker.idle);
			Assert.assertFalse(this._slaveWorker.working);
		}
		
		[Test(description="Tests worker.allHandlers to ensure that it returns a concatenated vector of all handlers in the list and the queue and does not alter the originals")]
		public function allHandlersReturnsConcatenatedListNonDestructively():void
		{
			var t:uint = 6;
			for(var i:uint=0; i<t; i++)
			{
				this._slaveWorker.addHandlerToWorkQueue(this._handlerPool[i]);
			}
			this._slaveWorker.start();
			var all:Vector.<SMILKitHandler> = this._slaveWorker.handlers;
			Assert.assertEquals(t, all.length);
			Assert.assertEquals(this._slaveWorkerConcurrency, this._slaveWorker.workList.length);
			Assert.assertEquals(t-this._slaveWorkerConcurrency, this._slaveWorker.workQueue.length);
		}
		
	}
	
	// Pending tests:
	
	
	// stopping rewinds the queue
	// rewinding moves all workList items to the front of the workQueue
	
	// addHandlerToWorkQueue: adding a handler returns true and appends to the queue
	// addHandlerToWorkQueue: adding a handler that is already on the worklist returns false and does not alter the queue
	// addHandlerToWorkQueue: adding a handler that is already in the workqueue returns false and does not alter the queue
	
	// removeHandlerFromWorkQueue: removing a handler that is on the workqueue returns true and slices the queue
	// removeHandlerFromWorkQueue: removing a handler that is not present on the workqueue returns false and does not alter the queue.
	
	// receiving the completion event removes the handler from the worker and dispatches WORK_UNIT_COMPLETE and WORK_UNIT_REMOVED
	// receiving the failure event removes the handler from the worker and dispatches WORK_UNIT_FAILED and WORK_UNIT_REMOVED
	
	
}