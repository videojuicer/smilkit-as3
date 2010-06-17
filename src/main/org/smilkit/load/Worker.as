package org.smilkit.load {
	
	import flash.events.EventDispatcher;
	import org.smilkit.util.logger.Logger;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.events.WorkerEvent;
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
		
		public function set handlers(handlers:Vector.<SMILKitHandler>):void {
			// TODO compare and broadcast removed/added on the appropriate items
		}
		
		public function start():Boolean {
			if(!this.working) 
			{
				this._working = true;
				this.dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_STARTED));
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
				this.dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_STOPPED));
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
			handler.addEventListener(this._completionEventType, this.onWorkUnitCompleted);
			handler.addEventListener(this._failureEventType, this.onWorkUnitFailed);
			return true;
		}
		
		/**
		 * Removes a handler from the queue.
		*/		
		public function removeHandler(handler:SMILKitHandler):Boolean {
			if(this.hasHandlerInWorkList(handler)) 
			{
				// TODO remove from vector
				this.advance();
			} 
			if(this.hasHandlerInWorkQueue(handler)) 
			{
				//TODO remove from vector
			}
			return false;
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
		private function advanceCapacity():uint {
			if(this._concurrency < 1) 
			{
				// Unlimited concurrency. Go for broke and punt everything from the queue.
				return this._workQueue.length;
			}
			else 
			{
				var listRemain:uint = this._concurrency - this._workList.length;
				
			}
		}
		
		private function advance():Boolean {
			if(this.working) 
			{
				var cap:uint = this.advanceCapacity();
				for(var i:uint=0; i < cap; i++) {
					// push workqueue item onto worklist and broadcast WORK_UNIT_STARTED
				}
			}
			return false;
		}
		
		private function bindPriorityWorkerEvents(priorityWorker:Worker):void {
			priorityWorker.addEventListener(WorkerEvent.WORKER_STARTED, this.onPriorityWorkerStarted);
			priorityWorker.addEventListener(WorkerEvent.WORKER_STOPPED, this.onPriorityWorkerStopped);
			priorityWorker.addEventListener(WorkerEvent.WORKER_IDLE, this.onPriorityWorkerIdle);
			priorityWorker.addEventListener(WorkerEvent.WORKER_RESUMED, this.onPriorityWorkerResumed);
		}
		
		
		
		public function onWorkUnitCompleted(e:HandlerEvent):void {
			
		}
		
		public function onWorkUnitFailed(e:HandlerEvent):void {
			
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
		
		private function logInfo(msg:String):void {
			Logger.info("Worker : "+this.loggerName+" "+msg, {"self": this, "priorityWorker": this._priorityWorker});
		}
		
		private function logDebug(msg:String):void {
			Logger.debug("Worker : "+this.loggerName+" "+msg, {"self": this, "priorityWorker": this._priorityWorker});
		}
		
		
	}
	
}