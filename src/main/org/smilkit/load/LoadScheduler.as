package org.smilkit.load {
	
	import org.smilkit.SMILKit;
	import org.smilkit.view.Viewport;
	import org.smilkit.view.ViewportObjectPool;
	import org.smilkit.time.TimingGraph;
	import org.smilkit.render.RenderTree;
	
	/**
	 * An instance of LoadScheduler listens to both the TimingGraph and RenderTree objects for
	 * change/rebuild events and attempts to make the best decisions for prioritising load order.
	 * 
	 * LoadScheduler has multiple priority channels through which handers may be loaded.
	 * 
	 * The highest priority channel is the justInTime worklist, attempting to load objects as they are
	 * added to the RenderTree instance. This worklist has no concurrency limit; just-in-time load 
	 * events are handled on-demand regardless of concurrency.
	 * 
	 * The next in priority order is the resolve workqueue. When no justInTime items are being actively 
	 * loaded, the LoadScheduler will look for resolvable handers of unresolved duration to work on. The resolve workqueue
	 * has a concurrency limit of 1 and functions as a FIFO.
	 * 
	 * The lowest priority workqueue is the preload workqueue. When no justInTime items are being worked 
	 * on, and no time-unresolved handers remain in the document, the LoadScheduler will attempt 
	 * to opportunistically load data for any preloadable handers in the document 
	 * (e.g. HTTP progressive video, images, text files).
	 * 
	 * The worklist/workqueue behaviour is based on these rules:
	 * 1. A hander is only allowed to exist on one worklist or workqueue at a time. In the case of an hander existing
	 *    on multiple lists/queues, the highest-priority entry will be retained.
	 * 2. handers receive a movedToJustInTimeWorkList call when the load scheduler receives a JIT request from 
	 *    the RenderTree.
	 * 3. handers receive a becameActiveInResolveQueue call when the scheduler advances the resolve queue.
	 * 4. handers receive a becameActiveInPreloadQueue call when the scheduler advances the preload queue.
	 * 3. handers receiving a removedFromLoadScheduler call can safely assume that they do not exist on any queues. 
	 *    This call is only sent when removing an hander from a worklist without adding it to another.
     * 
	 * handers are moved between lists/queues on the following basis:
	 * 1. Moved to the justInTime worklist when receiving a handlerAddedToRenderTree event
	 * 2. Removed from the justInTime worklist when removedFromRenderTree or when load completed.
	 * 
	 * 3. Moved to the resolve queue if resolvable.
	 * 4. Become active in the resolve queue if at index 0 and if the JIT list is empty.
	 * 
	 * 5. Moved to the preload queue if preloadable.
	 * 6. Become active in the preload queue if at index 0 and if both the JIT list and the resolve queue are empty.
	*/
	public class LoadScheduler {
		/**
		 * An instance of ViewportObjectPool is required in order to reference the RenderTree and TimingGraph instances. 
		 */
		protected var _objectPool:ViewportObjectPool;
		
		/**
		 * Used in conditional checks to prevent the scheduler from starting work more than once.
		 */
		protected var _working:Boolean = false;
		
		/*
		 * The justInTime workQueue, a special case. When the LoadScheduler is not yet working, JIT requests
		 * land in this queue. Upon work starting, the entire queue is flushed into the JIT worklist and new
		 * JIT requests are appended directly to the worklist, skipping this queue object.
		*/
		protected var _justInTimeMailbox:Array = [];
		
		/*
		* The justInTime worklist, an n-concurrency list of high-priority handers needed for the current
		* render state. The RenderTree is used as the data source for this list.
		*/
		protected var _justInTimeWorkList:Array = [];
		/*
		* The resolve workqueue, a linear queue of handers to be resolved but not fully preloaded. This list is
		* opportunistic in nature and uses the timing graph as a data source.
		*/
		protected var _resolveWorkQueue:Array = [];
		/*
		* The preload workqueue, a linear queue of handers to be fully preloaded. This list is opportunistic in
		* nature and uses the timing graph as a data source.
		*/
		protected var _preloadWorkQueue:Array = [];
		
		
		public function LoadScheduler(objectPool:ViewportObjectPool) {
			this._objectPool = objectPool;
		}
		
		public function start():Boolean {
			if(!this._working) {
				// move JIT mailbox to JIT worklist
				
				return true;
			}
			return false;
		}
		
		private function handlerAddedToRenderTree():void {}
		private function handlerRemovedFromRenderTree():void {}
		
		private function get timingGraph():TimingGraph {
			return this._objectPool.timingGraph;
		}
		private function get renderTree():RenderTree {
			return this._objectPool.renderTree;
		}
		
		private function bindJustInTimeEvents():void {}
		private function bindWorkQueueEvents():void {}
		
		private function rebuildResolveQueue():void {}
		private function rebuildPreloadQueue():void {}
		private function shouldAdvanceResolveQueue():void {}
		private function shouldAdvancePreloadQueue():void {}
		
	}
	
}