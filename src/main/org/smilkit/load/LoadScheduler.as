package org.smilkit.load {
	
	import org.smilkit.SMILKit;
	import org.smilkit.view.Viewport;
	
	/**
	 * An instance of LoadScheduler listens to both the TimingGraph and RenderTree objects for
	 * change/rebuild events and attempts to make the best decisions for prioritising load order.
	 * 
	 * LoadScheduler has multiple priority channels through which assets may be loaded.
	 * 
	 * The highest priority channel is the justInTime worklist, attempting to load objects as they are
	 * added to the RenderTree instance. This worklist has no concurrency limit; just-in-time load 
	 * events are handled on-demand regardless of concurrency.
	 * 
	 * The next in priority order is the resolve workqueue. When no justInTime items are being actively 
	 * loaded, the LoadScheduler will look for resolvable assets of unresolved duration to work on. The resolve workqueue
	 * has a concurrency limit of 1 and functions as a FIFO.
	 * 
	 * The lowest priority workqueue is the preload workqueue. When no justInTime items are being worked 
	 * on, and no time-unresolved assets remain in the document, the LoadScheduler will attempt 
	 * to opportunistically load data for any preloadable assets in the document 
	 * (e.g. HTTP progressive video, images, text files).
	 * 
	 * The worklist/workqueue behaviour is based on these rules:
	 * 1. An asset is only allowed to exist on one worklist or workqueue at a time. In the case of an asset existing
	 *    on multiple lists/queues, the highest-priority entry will be retained.
	 * 2. Assets receive a movedToJustInTimeWorkList call when the load scheduler receives a JIT request from 
	 *    the RenderTree.
	 * 3. Assets receive a becameActive
	 * 3. Assets receiving a removedFromLoadScheduler call can safely assume that they do not exist on any queues. 
	 *    This call is only sent when removing an asset from a worklist without adding it to another.
     * 
	 * Assets are moved between lists/queues on the following basis:
	 * 1. Moved to the justInTime worklist when receiving a handlerAddedToRenderTree event
	 * 2. Removed from the justInTime worklist when removedFromRenderTree or when load completed.
	 * 
	 * 3. Moved to the resolve queue
	*/
	public class LoadScheduler {
		/**
		 * An instance of Viewport is required in order to reference the RenderTree and TimingGraph instances. 
		 */
		protected var _viewport:Viewport;
		
		/**
		 * An instance of TimingGraph is used to store the timings of the elements that are to be displayed 
		 */
		protected var _working:Boolean = false;
		
		/*
		 * The justInTime workQueue, a special case. When the LoadScheduler is not yet working, JIT requests
		 * land in this queue. Upon work starting, the entire queue is flushed into the JIT worklist and new
		 * JIT requests are appended directly to the worklist, skipping this queue object.
		*/
		protected var _justInTimeMailbox:Array = [];
		
		/*
		* The justInTime worklist, an n-concurrency list of high-priority assets needed for the current
		* render state. The RenderTree is used as the data source for this list.
		*/
		protected var _justInTimeWorkList:Array = [];
		/*
		* The resolve workqueue, a linear queue of assets to be resolved but not fully preloaded. This list is
		* opportunistic in nature and uses the 
		*/
		protected var _resolveWorkQueue:Array = [];
		/*
		* The preload workqueue, a linear queue of assets to be fully preloaded.
		*/
		protected var _preloadWorkQueue:Array = [];
		
		
		public function LoadScheduler() {
			
		}
		
		public function startWorking() {
			
		}
		
		private function get timingGraph():TimingGraph {}
		private function get renderTree():RenderTree {}
		
		private function bindJustInTimeEvents():void {}
		
		private function rebuildResolveQueue():void {}
		private function rebuildPreloadQueue():void {}
		private function shouldAdvanceResolveQueue():Boolean {}
		private function shouldAdvancePreloadQueue():Boolean {}
		
	}
	
}