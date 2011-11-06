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
package org.smilkit.load {
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.events.SMILMutationEvent;
	import org.smilkit.dom.smil.time.SMILTimeInstance;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.events.WorkUnitEvent;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.render.HandlerController;
	import org.smilkit.view.ViewportObjectPool;
	
	/***
	 * An instance of LoadScheduler listens to both the TimingGraph and RenderTree objects for
	 * change/rebuild events and attempts to make the best decisions for prioritising load order.
	 * 
	 * LoadScheduler has multiple priority channels through which handers may be loaded. These channels
	 * are created as instances of the Worker class. Each Worker instance is managed by the LoadScheduler.
	 * 
	 * The highest priority worker is the justInTime instance, attempting to load objects as they are
	 * added to the RenderTree instance. This worker has no concurrency limit; just-in-time load 
	 * events are handled on-demand regardless of concurrency.
	 * 
	 * The next in priority order is the resolve worker. When no justInTime items are being actively 
	 * loaded, the LoadScheduler will look for resolvable handers of unresolved duration to work on. The resolve worker
	 * has a concurrency limit of 1.
	 * 
	 * Lowest priority is the preload worker. When no justInTime items are being worked 
	 * on, and the resolve worker is also idle, the LoadScheduler will attempt 
	 * to opportunistically load data for any preloadable handers in the document 
	 * (e.g. HTTP progressive video, images, text files).
	 * 
	 * The worklist/workqueue behaviour is based on these rules:
	 * 1. A hander is only allowed to exist on one worklist or workqueue at a time. In the case of an hander existing
	 *    on multiple lists/queues, the highest-priority entry will be retained.
	 * 2. handers receive a movedToJustInTimeWorkList call when the load scheduler receives a JIT request from 
	 *    the RenderTree.
	 * 3. handers receive a movedToResolveWorkList call when the scheduler advances the resolve queue.
	 * 4. handers receive a movedToPreloadWorkList call when the scheduler advances the preload queue.
	 * 3. handers receiving a removedFromLoadScheduler call can safely assume that they do not exist on any queues. 
     * 
	 * To avoid producing erroneous removedFromLoadScheduler calls during a worker rebuild, the LoadScheduler will always
	 * move handlers between workers by adding the handler to the new worker BEFORE removing it from the old one.
	*/
	public class LoadScheduler {
		/***
		 * The owning SMILDocument which will generate the events needed to drive the loader.
		 */
		protected var _ownerSMILDocument:SMILDocument;
		
		/***
		 * Used in conditional checks to prevent the scheduler from starting work more than once.
		 */
		protected var _working:Boolean = false;
		
		/**
		 * The justInTime worker, a queue/list pair with no concurrency.
		*/
		protected var _justInTimeWorker:Worker;
		
		/**
		 * A pointer to the master control worker
		*/ 
		protected var _masterWorker:Worker;
		
		/**
		* The resolve worker, a queue/list pair with concurrency of 1 with priority lower than that of the justInTimeWorker
		* but higher than that of the preloadWorker
		*/
		protected var _resolveWorker:Worker;
		protected var _resolveWorkerConcurrencyLimit:uint;
		/**
		* The preload workqueue, a queue/list pair of handers to be fully preloaded. This list is opportunistic in
		* nature and uses the timing graph as a data source.
		*/
		protected var _preloadWorker:Worker;
		protected var _preloadWorkerConcurrencyLimit:uint;
		
		/**
		* A vector of all the workers used by the scheduler.
		*/
		protected var _workers:Vector.<Worker>;
		
		/**
		* A vector of all the opportunistic (i.e. not just-in-time workers) used by the scheduler.
		*/
		protected var _opportunisticWorkers:Vector.<Worker>;

		public function LoadScheduler(document:SMILDocument, resolveConcurrency:uint=1, preloadConcurrency:uint=1) {
			this._ownerSMILDocument = document;
			this._resolveWorkerConcurrencyLimit = resolveConcurrency;
			this._preloadWorkerConcurrencyLimit = preloadConcurrency;
			
			this._justInTimeWorker = new Worker(HandlerEvent.LOAD_COMPLETED, HandlerEvent.LOAD_FAILED, 0);
			this._justInTimeWorker.loggerName = "JustInTime Worker";
			
			this._resolveWorker = new Worker(HandlerEvent.DURATION_RESOLVED, HandlerEvent.LOAD_FAILED, this._resolveWorkerConcurrencyLimit, this._justInTimeWorker);
			this._resolveWorker.loggerName = "Resolve Worker";
			
			this._preloadWorker = new Worker(HandlerEvent.LOAD_COMPLETED, HandlerEvent.LOAD_FAILED, this._preloadWorkerConcurrencyLimit, this._resolveWorker);
			this._preloadWorker.loggerName = "Preload Worker";
			
			this._masterWorker = this._justInTimeWorker;
			
			this._workers = new Vector.<Worker>;
			this._workers.push(this._justInTimeWorker, this._resolveWorker, this._preloadWorker);
			
			this._opportunisticWorkers = new Vector.<Worker>;
			this._opportunisticWorkers.push(this._resolveWorker, this._preloadWorker);
			
			this.bindOpportunisticLoadEvents();
			this.bindWorkUnitEvents();
		}
		
		public function get ownerSMILDocument():SMILDocument
		{
			return this._ownerSMILDocument;
		}
		
		public function start():Boolean {
			if(!this._working) {
				this._working = true;
				this._masterWorker.start();
				return true;
			}
			return false;
		}
		
		public function stop():Boolean {
			if(this._working) {
				this._working = false;
				this._masterWorker.stop();
			}
			return false;
		}
		
		/**
		* Called when any time container is activated by the document scheduler. Takes the following actions:
		* 1. Adds the handler to the JIT worker's queue
		* 2. Removes the handler from the Resolve and Preload workers
		*/
		public function timeContainerActivated(element:ElementTimeContainer):void {
			var mediaElement:SMILMediaElement = element as SMILMediaElement;
			if(mediaElement == null) return;
			if(mediaElement.handler != null)
			{
				this.moveHandlerToWorker(mediaElement.handler, this._justInTimeWorker);
			}
		}
		
		/**
		* Called when a time container is inactivated by the document scheduler. Takes the following actions:
		* 1. Remove the handler from the JIT worker
		* 2. Rebuild the opportunistic workers
		*/
		public function timeContainerDeactivated(element:ElementTimeContainer):void 
		{
			var mediaElement:SMILMediaElement = element as SMILMediaElement;
			if(mediaElement == null) return;
			if(mediaElement.handler != null) {
				this._justInTimeWorker.removeHandler(mediaElement.handler);
				this.rebuildOpportunisticWorkers();
			}
		}

		protected function bindOpportunisticLoadEvents():void 
		{
			this.ownerSMILDocument.addEventListener(SMILMutationEvent.DOM_TIMEGRAPH_MODIFIED, this.onTimingGraphRebuild, false);
			this.rebuildOpportunisticWorkers();
		}
		
		/**
		* Called when the Timing graph is rebuilt in any way. Causes the load scheduler to rebuild the opportunistic workers.
		*/
		protected function onTimingGraphRebuild(event:SMILMutationEvent):void 
		{
			this.rebuildOpportunisticWorkers();
		}
		
		protected function bindWorkUnitEvents():void
		{
			this._justInTimeWorker.addEventListener(WorkUnitEvent.WORK_UNIT_LISTED, this.onHandlerMovedToJustInTimeWorkerWorkList);
			this._resolveWorker.addEventListener(WorkUnitEvent.WORK_UNIT_LISTED, this.onHandlerMovedToResolveWorkerWorkList);
			this._preloadWorker.addEventListener(WorkUnitEvent.WORK_UNIT_LISTED, this.onHandlerMovedToPreloadWorkerWorkList);
			// Bind removal event WORK_UNIT_REMOVED
			this._justInTimeWorker.addEventListener(WorkUnitEvent.WORK_UNIT_REMOVED, this.onHandlerRemovedFromWorker);
			this._resolveWorker.addEventListener(WorkUnitEvent.WORK_UNIT_REMOVED, this.onHandlerRemovedFromWorker);
			this._preloadWorker.addEventListener(WorkUnitEvent.WORK_UNIT_REMOVED, this.onHandlerRemovedFromWorker);
		}

		protected function onHandlerMovedToJustInTimeWorkerWorkList(event:WorkUnitEvent):void 
		{
			if(this._justInTimeWorker.hasHandler(event.handler)) event.handler.movedToJustInTimeWorkList();
		}
		protected function onHandlerMovedToResolveWorkerWorkList(event:WorkUnitEvent):void 
		{
			if(this._resolveWorker.hasHandler(event.handler)) event.handler.movedToResolveWorkList();
		}
		protected function onHandlerMovedToPreloadWorkerWorkList(event:WorkUnitEvent):void 
		{
			if(this._preloadWorker.hasHandler(event.handler)) event.handler.movedToPreloadWorkList();
		}
		protected function onHandlerRemovedFromWorker(event:WorkUnitEvent):void
		{
			var h:SMILKitHandler = event.handler;
			
			if(!this._justInTimeWorker.hasHandler(h) && !this._resolveWorker.hasHandler(h) && !this._preloadWorker.hasHandler(h))
			{
				h.removedFromLoadScheduler();
			}
		}
		
		/** 
		* Rebuilds the work queues for the resolve and preload workers.
		* The timing graph is used as a data source.
		* Workers that are already on the just in time worker are not eligible for inclusion on the opportunistic workers.
		*/
		protected function rebuildOpportunisticWorkers():void {
			// Get timing graph contents
			var timingGraphElements:Vector.<SMILTimeInstance> = this.ownerSMILDocument.timeGraph.mediaElements;
			
			if (timingGraphElements != null)
			{
				// Move timing graph contents onto their correct handlers
				for(var i:uint=0; i<timingGraphElements.length; i++)
				{
					var h:SMILKitHandler = (timingGraphElements[i].element as SMILMediaElement).handler;
					
					// skip if the handler is null, i.e. the media element hasnt started loading yet
					if (h != null)
					{
						// Skip if the handler is on the JIT worker
						if(this._justInTimeWorker.hasHandler(h)) continue;				
						// For each element, determine where it's handler should be.
						var targetWorker:Worker = this.opportunisticWorkerForHandler(h);
						if(targetWorker != null)
						{
							// Move it there.
							this.moveHandlerToWorker(h, targetWorker);
						}
					}
				}
			}
			
			// Purge orphaned handlers from the workers
			this.purgeOrphanedHandlers();
		}
		
		/**
		* Moves the specified handler to the specified worker's work queue by adding and then removing in order.
		*/
		protected function moveHandlerToWorker(handler:SMILKitHandler, targetWorker:Worker):void
		{
			// Do the add
			targetWorker.addHandlerToWorkQueue(handler);
			
			// Remove from any others
			for(var i:uint=0; i<this._workers.length; i++)
			{
				var candidateWorker:Worker = this._workers[i];
				if(candidateWorker != targetWorker) candidateWorker.removeHandler(handler);
			}
		}
		
		/**
		* Removes items from the workers that are not present on the given vector of handlers.
		*/
		protected function purgeOrphanedHandlers():void
		{
			// Build flat list of handlers
			var timingGraphElements:Vector.<SMILTimeInstance> = this.ownerSMILDocument.timeGraph.mediaElements;
			var timingGraphHandlers:Vector.<SMILKitHandler> = new Vector.<SMILKitHandler>();
			
			if (timingGraphElements != null)
			{
				for(var i:uint=0; i<timingGraphElements.length; i++)
				{
					timingGraphHandlers.push((timingGraphElements[i].element as SMILMediaElement).handler);
				}
			}
			
			// Scan workers
			SMILKit.logger.debug("Purging orphaned handlers ("+timingGraphHandlers.length+" exist on the timing graph)", this);
			
			for(var j:uint=0; j<this._workers.length; j++)
			{
				var worker:Worker = this._workers[j];
				var workerHandlers:Vector.<SMILKitHandler> = worker.handlers;
				// Check worker's handlers against the timing graph list
				for(var k:uint=0; k<workerHandlers.length; k++)
				{
					var h:SMILKitHandler = workerHandlers[k];
					if(timingGraphHandlers.indexOf(h) < 0) 
					{
						SMILKit.logger.debug("Purging orphaned handler "+h+" (id: "+h.handlerId+") from "+worker.loggerName, this);
						worker.removeHandler(h);
					}
				}
			}
		}
		
		/**
		* Inspects the given handler and determines which opportunistic worker it belongs on, if any.
		* If the handler is resolvable but not resolved, the resolve worker will be returned.
		* If the handler is ((resolvable and resolved) or (not resolvable)) and also (preloadable but not preloaded) then the preload worker will be returned.
		* If the handler is not suitable for opportunistic loading or opportunistic loading has already taken place, null will be returned.
		* @return a Worker instance or null.
		*/
		protected function opportunisticWorkerForHandler(handler:SMILKitHandler):Worker 
		{
			if(this._justInTimeWorker.hasHandler(handler)) return null;
			if((handler.resolvable && !handler.completedResolving) && (handler.element != null) && !(handler.element as ElementTimeContainer).hasDuration())
			{
				return this._resolveWorker;
			}
			else if(handler.preloadable && !handler.completedLoading)
			{
				return this._preloadWorker;
			}
			else
			{
				return null;
			}
		}
		
	}
	
}