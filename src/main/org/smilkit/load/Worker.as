package org.smilkit.load {
	
	import flash.events.EventDispatcher;
	import org.smilkit.util.logger.Logger;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.events.WorkerEvent;
	import org.smilkit.events.WorkUnitEvent;
	import org.smilkit.events.HandlerEvent;
	/**
	 * An instance of load.Worker deals with queueing and prioritisation of handler load tasks.
	 * Each worker encapsulates a workQueue, which is a linear list of items to be processed,
	 * and a workList of items currently being worked on with a settable concurrency limit.
	 * 
	 * An important feature of the Worker class is right-of-way priority delegation. By passing another
	 * worker instance into the constructor as the priorityWorker argument, you can cause your new worker
	 * to cede right of way to another worker, starting up only when the priorityWorker is idling (i.e. is active
	 * but has no jobs to process.)
	 * When the priority worker is stopped in a defacto fashion by receiving a call to it's stop() method, all 
	 * lower-priority queues are expected to stop work as well.
	 * 
	 * When any worker stops working, any outstanding work units on the workList are allowed to complete before
	 * the worker fully shuts down. In effect, the _working boolean determines whether or not items in the queue
	 * should be advanced to the workList.
	*/
	public class Worker extends EventDispatcher {
		
		/**
		 * Settable concurrency lets you place a limit on the maximum length of the workList. A null value means no concurrency limit.
		*/
		private var _concurrency:uint;
		
		/**
		* The workQueue vector stores all handlers pending action in this worklist.
		*/
		private var _workQueue:Vector.<SMILKitHandler>;
		
		/**
		 * The workList vector stores references to all handlers currently being worked on.
		*/
		private var _workList:Vector.<SMILKitHandler>;
		
		/** 
		 * Boolean flag to indicate whether items in the queue should advance to the workList when space frees up.
		*/
		private var _working:Boolean = false;
		
		/**
		 * The type of HandlerEvent to listen for. When this event is triggered on an asset it will be considered
		 * complete for the purposes of this Worker instance.
		*/
		private var _completionEventType:String;
				
		/**
		 * The type of HandlerEvent to listen for. When this event is triggered on an asset it will be considered
		 * failed for the purposes of this Worker instance and discarded from the queue.
		*/
		private var _failureEventType:String;
		/**
		 * A right-of-way priority delegate to which this worker will cede priority.
		*/
		private var _priorityWorker:Worker;
		
		/**
		 * An optional name to use when logging status messages.
		*/
		public var loggerName:String = "Worker";
		
		/**
		 * An internal flag used to retain state between advances.
		*/
		private var _idleOnLastAdvance:Boolean = false;
		
		/**
		 * Create a new Worker instance.
		 *
		 * @param completionEventType A <code>String</code> referring to a HandlerEvent type used for completion notices on this Worker.
		 * @param failureEventType A <code>String</code> referring to a HandlerEvent type used for failure notices on this Worker.
		 * @param concurrency A <code>uint</code> indicating the concurrency value. A value of 0 will cause the Worker to have no limit.
		 * @param priorityWorker A <code>Worker</code> object to which this Worker will cede priority.
		*/		
		public function Worker(completionEventType:String, failureEventType:String, concurrency:uint=0, priorityWorker:Worker=null) {
			this._workQueue = new Vector.<SMILKitHandler>();
			this._workList = new Vector.<SMILKitHandler>();
			this._completionEventType = completionEventType;
			this._failureEventType = failureEventType;
			this._concurrency = concurrency;
			this._priorityWorker = priorityWorker;
			if(this._priorityWorker) bindPriorityWorkerEvents(this._priorityWorker)
		}
		
		public function get working():Boolean {
			return this._working;
		}
		
		public function rebuild(handlers:Vector.<SMILKitHandler>):void {
			// TODO compare and broadcast removed/added on the appropriate items
		}
		
		public function start():Boolean {
			if(!this.working) 
			{
				this._working = true;
				this.dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_STARTED, this));
				this.advance();
				return true;
			} 
			else 
			{
				return false;
			}
		}
		
		public function stop():Boolean {
			if(this.working) 
			{
				this._working = false;
				this._idleOnLastAdvance = false; // Reset idle event flag
				this.dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_STOPPED, this));
				return true;
			} 
			else 
			{
				return false;
			}
		}
		
		/** 
		 * Adds a handler to the back of the workQueue.
		 * @return A boolean, false if the handler was already on the workList or the workQueue in this worker and true if it was added.
		*/
		public function addHandlerToWorkQueue(handler:SMILKitHandler):Boolean {
			if(this.hasHandler(handler)) return false;
			this._workQueue.push(handler);
			// TODO bind generic "done" listener
			
			// bind specific event listeners
			handler.addEventListener(this._completionEventType, this.onWorkUnitCompleted);
			handler.addEventListener(this._failureEventType, this.onWorkUnitFailed);
			this.dispatchEvent(new WorkUnitEvent(WorkUnitEvent.WORK_UNIT_QUEUED, handler));
			this.advance();
			return true;
		}
		
		/**
		 * Removes a handler from the queue.
		*/		
		public function removeHandler(handler:SMILKitHandler):Boolean {
			var res:Boolean = false;
			if(this.hasHandlerInWorkList(handler)) 
			{
				this._workList.splice(this._workList.indexOf(handler), 1);
				res = true;
			} 
			if(this.hasHandlerInWorkQueue(handler)) 
			{
				this._workQueue.splice(this._workList.indexOf(handler), 1);
				res = true;
			}
			if(res) this.dispatchEvent(new WorkUnitEvent(WorkUnitEvent.WORK_UNIT_REMOVED, handler));
			this.advance();
			return res;
		}
		
		public function hasHandler(handler:SMILKitHandler):Boolean {
		 return (this.hasHandlerInWorkList(handler) || this.hasHandlerInWorkQueue(handler));
		}
		
		public function hasHandlerInWorkList(handler:SMILKitHandler):Boolean {
			return (this._workList.indexOf(handler) != -1);
		}
		
		public function hasHandlerInWorkQueue(handler:SMILKitHandler):Boolean {
			return (this._workQueue.indexOf(handler) != -1);
		}
		
		/**
		 * Returns the number of items from the workQueue that are eligible to be placed
		 * in the workList, taking into account the current concurrency setting and the
		 * lengths of the workList and workQueue.
		 * @return A <code>uint</code> representing the number of steps the worker can advance.
		*/
		public function advanceCapacity():uint {
			if(this._concurrency <= 0) 
			{
				// Unlimited concurrency. Go for broke and punt everything from the queue.
				return this._workQueue.length;
			}
			else 
			{
				var listRemain:uint = this._concurrency - this._workList.length; // Remaining capacity on the list
				var queueRemain:uint = this._workQueue.length; // Remaining items on the queue
				if(listRemain <= 0) return 0; // Full list means no advance capacity
				else return (listRemain > queueRemain)? queueRemain : listRemain; // Return the smaller of the two figures
			}
		}
		
		/**
		 * Refills the workList to capacity and broadcasts WORK_UNIT_LISTED events on all items
		 * newly added to the workList.
		 * @return A <code>uint</code> indicating the number of items that were advanced onto the workList.
		*/
		public function advance():uint {
			if(this.working) 
			{
				var limit:uint = this.advanceCapacity();
				var moved:Vector.<SMILKitHandler> = new Vector.<SMILKitHandler>;
				for(var i:uint=0; i < limit; i++) {
					//throw new Error(this.loggerName+" wQ size: "+this._workQueue.length+" wL size: "+this._workList.length);
					var h:SMILKitHandler = this._workQueue[i];
					// push workqueue item onto worklist and broadcast WORK_UNIT_LISTED
					this._workList.push(h);
					moved.push(h);
				}
				// Splice the moved items from the workQueue
				this._workQueue.splice(0, moved.length);
				// Dispatch LISTED event on moved items
				for(var j:uint=0; j < moved.length; j++)
				{
					var movedHandler:SMILKitHandler = moved[j];
					this.dispatchEvent(new WorkUnitEvent(WorkUnitEvent.WORK_UNIT_LISTED, movedHandler));					
				}
				
				// Check idle state and transmit idle event if transitioning to idle 
				if(this._idleOnLastAdvance && !this.idle) {
					// If it was idle on last advance and isn't idle now, then we're resuming.
					this._idleOnLastAdvance = false;
					this.dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_RESUMED, this));
				} else if(!this._idleOnLastAdvance && this.idle)
				{
					// If it wasn't idle last time and it is idle now, then we're going idle.
					this._idleOnLastAdvance = true;
					this.dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_IDLE, this));
				}
				return limit;
			}
			return 0;
		}
		
		/**
		 * Returns a boolean to indicate whether or not the worker is currently in an idle state
		 * (i.e. is working, and has nothing on either the queue or the list) 
		*/
		public function get idle():Boolean
		{
			return (this.working && (this._workQueue.length <= 0) && (this._workList.length <= 0));
		}
		
		protected function bindPriorityWorkerEvents(priorityWorker:Worker):void {
			priorityWorker.addEventListener(WorkerEvent.WORKER_STARTED, this.onPriorityWorkerStarted);
			priorityWorker.addEventListener(WorkerEvent.WORKER_STOPPED, this.onPriorityWorkerStopped);
			priorityWorker.addEventListener(WorkerEvent.WORKER_IDLE, this.onPriorityWorkerIdle);
			priorityWorker.addEventListener(WorkerEvent.WORKER_RESUMED, this.onPriorityWorkerResumed);
		}
		
		
		
		public function onWorkUnitCompleted(e:HandlerEvent):void {
			// dispatch WORK_UNIT_COMPLETED
			var h:SMILKitHandler = e.handler;
			this.dispatchEvent(new WorkUnitEvent(WorkUnitEvent.WORK_UNIT_COMPLETED, h));
			// removeHandler
			this.removeHandler(h);
		}
		
		public function onWorkUnitFailed(e:HandlerEvent):void {
			// Dispatch WORK_UNIT_FAILED
			var h:SMILKitHandler = e.handler;
			this.dispatchEvent(new WorkUnitEvent(WorkUnitEvent.WORK_UNIT_FAILED, h));
			// removeHandler
			this.removeHandler(h);
		}
		
		public function onPriorityWorkerStarted(e:WorkerEvent):void {
			this.logInfo("Priority worker started up. Ceding priority and shutting down.");
			this.stop();
		}
		
		public function onPriorityWorkerStopped(e:WorkerEvent):void {
			this.logInfo("Priority worker shut down. Shutting down in turn.");
			this.stop();
		}
		
		public function onPriorityWorkerIdle(e:WorkerEvent):void {
			this.logInfo("Priority worker active but sitting idle. Starting up for opportunistic actions.");
			this.start();
		}
		
		public function onPriorityWorkerResumed(e:WorkerEvent):void {
			this.logInfo("Priority worker was idling but has now resumed. Ceding priority and shutting down.");
			this.stop();
		}
		
		public function get workQueue():Vector.<SMILKitHandler>
		{
			return this._workQueue;
		}
		
		public function get workList():Vector.<SMILKitHandler>
		{
			return this._workList;
		}
		
		protected function logInfo(msg:String):void {
			Logger.info("Worker : "+this.loggerName+" "+msg, {"self": this, "priorityWorker": this._priorityWorker});
		}
		
		protected function logDebug(msg:String):void {
			Logger.debug("Worker : "+this.loggerName+" "+msg, {"self": this, "priorityWorker": this._priorityWorker});
		}
		
		
	}
	
}