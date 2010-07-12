package org.smilkit.render
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	
	import org.smilkit.util.logger.Logger;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.events.RenderTreeEvent;
	import org.smilkit.events.TimingGraphEvent;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.time.TimingGraph;
	import org.smilkit.time.TimingNode;
	import org.smilkit.view.Viewport;
	import org.smilkit.view.ViewportObjectPool;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	
	/**
	 * Class responsible for checking the viewports play position and for requesting the display of certain DOM elements
	 * 
	 */	
	public class RenderTree extends EventDispatcher
	{
		/**
		 * Stored reference to the <code>ViewportObjectPool</code> instance including links to the parent <code>Viewport</code>.
		 */		
		protected var _objectPool:ViewportObjectPool;
		
		protected var _activeElements:Vector.<TimingNode>;
		
		protected var _nextChangeOffset:int = -1;
		protected var _lastChangeOffset:int = -1;
		
		protected var _waitingForDataHandlerList:Vector.<SMILKitHandler>;
		protected var _waitingForData:Boolean = false;
		
		protected var _offsetSyncHandlerList:Vector.<SMILKitHandler>;
		protected var _offsetSyncOffsetList:Vector.<uint>;
		protected var _offsetSyncNextResume:Boolean = false;
		
		protected var _waitingForSync:Boolean = false;
		
		protected var _performOffsetSyncOnNextResume:Boolean = false;
		
		/**
		 * Accepts references to the parent viewport and the timegraph which that parent viewport creates
		 * 
		 * Adds a listener to the heartbeat instance of the parent viewport and listens for when the TimingGraph is redrawn
		 * 
		 * @constructor 
		 * @param viewport - the parent Viewport with which the render tree is associated
		 * @param timeGraph - that has been created by the parent Viewport
		 * 
		 */		
		public function RenderTree(objectPool:ViewportObjectPool)
		{
			this._objectPool = objectPool;
			
			// listener to re-draw for every timing graph rebuild (does a fresh draw of the canvas - incase big things have changed)
			this.timingGraph.addEventListener(TimingGraphEvent.REBUILD, this.onTimeGraphRebuild);

			// listener for every heart beat (so we recheck the timing graph)
			this._objectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.RUNNING_OFFSET_CHANGED, this.onHeartbeatRunningOffsetChanged);
			
			// listener for heartbeat stop/go events
			this._objectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.PAUSED, this.onHeartbeatPaused);
			this._objectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.RESUMED, this.onHeartbeatResumed);
			
			
			// listener to detect playback state changes on the viewport
			this._objectPool.viewport.addEventListener(ViewportEvent.PLAYBACK_STATE_CHANGED, this.onViewportPlaybackStateChanged);
			// listener for changing volume levels
			this._objectPool.viewport.addEventListener(ViewportEvent.AUDIO_VOLUME_CHANGED, this.onViewportAudioVolumeChanged);
			
			this.reset();
		}
		
		public function get elements():Vector.<TimingNode>
		{
			return this._activeElements;
		}
		
		public function get nextChangeOffset():int
		{
			return this._nextChangeOffset;
		}
		
		public function get lastChangeOffset():int
		{
			return this._lastChangeOffset;
		}
		
		public function get timingGraph():TimingGraph
		{
			return this._objectPool.timingGraph;
		}
		
		public function get document():ISMILDocument
		{
			return this._objectPool.document;
		}
		
		public function get hasDocumentAttached():Boolean
		{
			return (this.timingGraph != null && this.document != null);
		}
		
		/** 
		* Higher-order accessor for all the RenderTree's internal wait links and other asynchronous machinery. 
		* @return True if the RenderTree is not waiting for any operations to complete before playback can continue.
		*/
		public function get ready():Boolean
		{
			return (!this._waitingForData && !this._waitingForSync);
		}
		
		/**
		 * Updates the RenderTree for the current point in time (according to the Viewport).
		 */
		public function update():void
		{
			this.updateAt(this._objectPool.viewport.offset);
		}
		
		/**
		 * Redraw draws everythings again on the Canvas, it starts by removing the current
		 * Canvas and then adding all the current selected elements.
		 */
		public function reset():void
		{
			// reset
			this._lastChangeOffset = -1;
			this._nextChangeOffset = -1;
			
			this._activeElements = new Vector.<TimingNode>();
			
			if (this._waitingForDataHandlerList != null && this._waitingForDataHandlerList.length > 0)
			{
				for (var i:int = 0; i < this._waitingForDataHandlerList.length; i++)
				{
					var handler:SMILKitHandler = this._waitingForDataHandlerList[i];
					
					handler.removeEventListener(HandlerEvent.LOAD_WAITING, this.onHandlerLoadWaiting);
					handler.removeEventListener(HandlerEvent.LOAD_READY, this.onHandlerLoadReady);
				}
			}
			
			this._waitingForDataHandlerList = null;
			this._waitingForDataHandlerList = new Vector.<SMILKitHandler>();
			
			// !!!!
			this.update();
		}
		
		/**
		 * Syncs up all the handlers that exist in the <code>RenderTree</code> so they all resume at the same time (or as close as possible).
		 */
		public function syncHandlersToViewportState():void
		{
			
			if (this._objectPool.viewport.heartbeat.running)
			{
				// Sync everything to a running state by resuming playback.
				for (var i:int = 0; i < this.elements.length; i++)
				{
					var node:TimingNode = this.elements[i];
					node.mediaElement.handler.resume();
					node.mediaElement.handler.setVolume(this._objectPool.viewport.volume);
				}
			}
			else
			{
				// Sync to a paused heartbeat state by pausing everything EXCEPT handlers that are waiting for sync.
				for (var j:int = 0; i < this.elements.length; i++)
				{
					var pauseNode:TimingNode = this.elements[j];
					var pauseHandler:SMILKitHandler = pauseNode.mediaElement.handler;
					var inSyncWaitList:Boolean = (this._offsetSyncHandlerList && this._offsetSyncHandlerList.indexOf(pauseHandler) > -1);
					
					// Do not pause handlers that are currently syncing
					if(!inSyncWaitList) pauseHandler.pause();
				}
			}
		}
		
		/**
		* Starts an offset sync operation on all handlers in the <code>RenderTree</code> instance.
		*
		* An offset sync operation provides synchronised playback after a seek operation. Due to oddities with 
		* seeking in compressed video, video assets often have a predefined set of seekable points (usually only
		* keyframes may be used as seek destinations) and so a call to seek to an arbitrary point may actually
		* seek a video to the keyframe *nearest* that arbitrary point. In order to provide proper synchronisation,
		* we run a "sync cycle" any time we resume playback from a seek operation.
		*
		* The sync cycle is limited to handler instances that are known to have a limited set of seekable offsets.
		* Each eligible handler is seeked to the nearest keyframe before the desired offset, and then allowed to play
		* (while muted) to the requested arbitrary offset before being paused. When all eligible handlers have been
		* synced to the desired offset, playback proper may resume.
		* 
		* A sync cycle is a "wait" operation and holds playback in a similar manner to waiting for more data to load.
		* A RenderTreeEvent.READY event will be dispatched when the sync cycle completes, if the render tree is not waiting
		* for data to load.
		*
		* A sync operation may only be cancelled by the need for another sync operation - once sync is in progress,
		* it must complete before playback resume.
		*
		* The only exception to the sync cycle is made for video assets with extremely infrequent keyframes. If a handler's
		* nearest prior seek point is outside of a predefined tolerance range, then we will settle for the nearest forward
		* seek point, compromising sync accuracy for a speedy resume when a video asset is extremely heavily or poorly-compressed.
		*/
		public function syncHandlersToViewportOffset():void
		{
			Logger.debug("RenderTree: Beginning sync operation...");
			
			this._offsetSyncHandlerList = new Vector.<SMILKitHandler>();
			this._offsetSyncOffsetList = new Vector.<uint>();
			
			for (var i:int = 0; i < this.elements.length; i++)
			{
				var node:TimingNode = this.elements[i];
				var offset:uint = (this._objectPool.viewport.offset - node.begin);
				var nearestSyncPoint:Number = node.mediaElement.handler.findNearestSyncPoint(offset);
				
				if (nearestSyncPoint < offset)
				{
					node.mediaElement.handler.seek(nearestSyncPoint);
					
					node.mediaElement.handler.setVolume(0);
					node.mediaElement.handler.resume();
					
					this._offsetSyncHandlerList.push(node.mediaElement.handler);
					this._offsetSyncOffsetList.push(nearestSyncPoint);
				}
				else
				{
					node.mediaElement.handler.seek(offset);
				}
				
				if (this._offsetSyncHandlerList.length > 0)
				{
					Logger.debug("RenderTree: Waiting for sync on "+this._offsetSyncHandlerList.length+" handlers.");
					
					this._waitingForSync = true;
					
					this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.WAITING_FOR_SYNC, null));
				} 
				else
				{
					Logger.debug("RenderTree: No handlers require sync at this time.")
				}
			}
		}
		
		/**
		* Cancels any sync operations that are in progress.
		*/
		protected function cancelOffsetSync():void
		{
			Logger.debug("RenderTree: Cancelling sync operation.");
			
			this._waitingForSync = false;
			this._offsetSyncHandlerList = new Vector.<SMILKitHandler>();
			this._offsetSyncOffsetList = new Vector.<uint>();
			this.syncHandlersToViewportState();
		}
		
		/**
		* Checks the progress of an offset sync operation, if one is in progress. Called each time the heartbeat ticks, 
		* regardless of whether the runningOffset is currently incrementing.
		*
		* During the offset sync, each syncing handler is checked to see if it has reached the internal offset required
		* by the sync operation. If it has, it is removed from the sync wait list. If a sync is running but the sync wait
		* list is empty once checkSyncOperation has run, then the sync operation is considered to be complete.
		*/
		protected function checkSyncOperation():void
		{
			if (this._waitingForSync)
			{
				Logger.debug("RenderTree: Checking sync operation...");
				
				var removeIndexes:Array = new Array();
				
				for (var i:int = 0; i < this._offsetSyncHandlerList.length; i++)
				{
					var waitHandler:SMILKitHandler = this._offsetSyncHandlerList[i];
					var waitOffset:uint = this._offsetSyncOffsetList[i];
					
					if (waitHandler.currentOffset >= this._objectPool.viewport.offset)
					{
						// Sync is complete on this handler.
						
						//
						removeIndexes.push(i);
						// 
						waitHandler.pause();
						
						// add to stage here??
					}
				}
				
				// work backwards to avoid a fuck up with the indexes in mid-loop
				for (var j:uint = removeIndexes.length - 1; j >= 0; j--)
				{
					this._offsetSyncHandlerList.splice(j, 1);
					this._offsetSyncOffsetList.splice(j, 1);
				}
				
				if (this._offsetSyncHandlerList.length < 1)
				{
					this._waitingForSync = false;
					
					if (!this._waitingForData)
					{
						Logger.debug("RenderTree: Sync operation completed. RenderTree now READY.");
						this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.READY, null));
					}
					else
					{
						Logger.debug("RenderTree: Sync operation completed. Waiting for load wait cycle to complete before the RenderTree is READY.");
					}
				}
				else
				{
					Logger.debug("RenderTree: Waiting on "+this._offsetSyncHandlerList.length+" handlers to sync before sync operation complete.");
				}
			}
		}
		
		/**
		* Removes a handler from the sync wait list. Called once the handler has synced to the desired offset.
		*/
		protected function removeHandlerFromWaitingForSyncList(handler:SMILKitHandler):void
		{
			// find handler in the list
			if(this._offsetSyncHandlerList != null) 
			{
				var index:int = this._offsetSyncHandlerList.indexOf(handler);

				if (index >= 0)
				{
					this._offsetSyncHandlerList.splice(index, 1);
					this._offsetSyncOffsetList.splice(index, 1);
					this.checkSyncOperation();
				}
			}
		}
		
		/**
		* Removes a handler from the load wait list. Called once the handler declares that it is ready for playback.
		*/
		protected function removeHandlerFromWaitingForDataList(handler:SMILKitHandler):void
		{
			if(this._waitingForDataHandlerList != null)
			{
				var index:int = this._waitingForDataHandlerList.indexOf(handler);

				if (index >= 0)
				{
					this._waitingForDataHandlerList.splice(index, 1);
					this.checkLoadState();
				}
			}
		}
		
		/**
		 * Checks the current position of the player and requests the stage be redrawn according to timings in the TimingGraph
		 * 
		 * @param offset The offset to set the contents of the <code>RenderTree</code> to.
		 */		
		public function updateAt(offset:Number):void
		{
			// we only need to do a loop if the offset is less than our last change
			// or bigger than our next change
			if (offset < this._lastChangeOffset || offset >= this._nextChangeOffset)
			{
				var elements:Vector.<TimingNode> = this.timingGraph.elements;
				var newActiveElements:Vector.<TimingNode> = new Vector.<TimingNode>();
				
				for (var i:int = 0; i < elements.length; i++)
				{
					var time:TimingNode = elements[i];
					var previousIndex:int = this._activeElements.indexOf(time);
					var alreadyExists:Boolean = (previousIndex != -1);
					var activeNow:Boolean = time.activeAt(offset);
					var handler:SMILKitHandler = (time.element as SMILMediaElement).handler;
					
					if (time.begin != Time.UNRESOLVED && time.begin > offset && (time.begin < this._lastChangeOffset || this._lastChangeOffset == -1))
					{
						this._nextChangeOffset = time.begin;
					}
					
					// remove non active, existing elements
					if (!activeNow && alreadyExists)
					{
						this._lastChangeOffset = offset;
						
						if (handler.hasEventListener(HandlerEvent.LOAD_WAITING))
						{
							handler.removeEventListener(HandlerEvent.LOAD_WAITING, this.onHandlerLoadWaiting);
							handler.removeEventListener(HandlerEvent.LOAD_READY, this.onHandlerLoadReady);
						}
						
						// pause playback, we let the loadScheduler handles cancelling the loading
						handler.pause();
	
						// remove from sync wait list
						this.removeHandlerFromWaitingForSyncList(handler); // checkSyncOperation
						// remove from load wait list
						this.removeHandlerFromWaitingForDataList(handler); // checkLoadState();
						
						// remove from canvas
						this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.ELEMENT_REMOVED, handler));
	
						// dont add to new vector
					}
						// add active, non existant elements
					else if (activeNow)
					{
						// only add to the canvas, when the element hasnt existed before
						if (!alreadyExists)
						{
							this._lastChangeOffset = offset;
							
							// we add our listeners for the dependancy management
							handler.addEventListener(HandlerEvent.LOAD_WAITING, this.onHandlerLoadWaiting);
							handler.addEventListener(HandlerEvent.LOAD_READY, this.onHandlerLoadReady);
							
							// actually draw element to canvas ....
							this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.ELEMENT_ADDED, handler));
						}
							// already exists
						else
						{
							var previousTime:TimingNode = this._activeElements[previousIndex];
							
							if (time === previousTime && time != previousTime)
							{
								this._lastChangeOffset = offset;
								
								this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.ELEMENT_MODIFIED, handler));
							}
						}
						
						// always add to the new active list
						newActiveElements.push(time);
					}
				}
				
				// swap with new list
				this._activeElements = newActiveElements;
			}
		}
		
		/**
		* Called when a handler reports that it needs more data. Throws the <code>RenderTree</code> into a waitingForData state
		* and dispatches the matching event.
		*/
		protected function onHandlerLoadWaiting(e:HandlerEvent):void
		{
			Logger.debug("RenderTree: Handler dispatched LOAD_WAITING, about to enter load wait cycle.");
			// add to waiting list
			this._waitingForDataHandlerList.push(e.handler);
			this.checkLoadState();
		}
		
		/**
		* Called when a handler reports that it has enough data to begin playback.
		*/
		protected function onHandlerLoadReady(e:HandlerEvent):void
		{
			Logger.debug("RenderTree: Handler dispatched LOAD_READY, checking load wait cycle status.");
			// remove from waiting list
			this.removeHandlerFromWaitingForDataList(e.handler);			
			this.checkLoadState();
		}
		
		/**
		 * Runs a waiting / ready state check on the render tree contents and dispatches
		 * an event if the state changes. This method is called whenever a handler throws a waitingForData event,
		 * and whenever a handler declares that it now has enough data.
		 */
		protected function checkLoadState():void
		{
			if (this._waitingForDataHandlerList.length == 0)
			{
				if (this._waitingForData)
				{
					this._waitingForData = false;
					// The list is empty, but we were waiting for data. This means the wait operation has concluded.
					if(!this._waitingForSync)
					{
						Logger.debug("RenderTree: Load wait cycle completed. RenderTree now READY.");
						this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.READY, null));
					}
					else
					{
						Logger.debug("RenderTree: Load wait cycle completed. Still waiting for sync cycle to complete before RenderTree is READY.");
					}
				}
			}
			else
			{
				if (!this._waitingForData)
				{
					Logger.debug("RenderTree: Entering load wait cycle.");
					// The wait list has items, but we are not yet officially waiting for data. 
					// Set the waitingForData flag and dispatch the relevant event.
					this._waitingForData = true;				
					// we have nothing on our plate, so we are ready!
					this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.WAITING_FOR_DATA, null));
				}
				Logger.debug("RenderTree: Load wait cycle waiting for "+this._waitingForDataHandlerList.length+" handlers to dispatch LOAD_READY.");
			}
		}
		
		/**
		 * Function called when the TimingGraph rebuilds itself, this function in turn calls the reset function 
		 * @param e
		 * 
		 */		
		protected function onTimeGraphRebuild(e:TimingGraphEvent):void
		{
			this.reset();
		}
		
		protected function onHeartbeatResumed(e:HeartbeatEvent):void
		{
			this.syncHandlersToViewportState();
		}
		protected function onHeartbeatPaused(e:HeartbeatEvent):void
		{
			this.syncHandlersToViewportState();
		}
		
		/**
		 * Function called when the Viewports heartbeat dispatches a TimerEvent, which then updates the RenderTree 
		 */		
		protected function onHeartbeatRunningOffsetChanged(e:HeartbeatEvent):void
		{
			this.update();
		}
		
		protected function onHeartbeatTick(e:TimerEvent):void
		{
			this.checkSyncOperation();
		}
		
		/**
		* Listens for the playback state changing in order to schedule the next sync cycle.
		* A sync cycle is needed whenever we resume playback after a seek operation, therefore:
		* 1. Every time the viewport enters a seek operation (by changing state to PLAYBACK_SEEKING), we flag that a sync is needed on the next resume operation.
		* 2. Every time the viewport resumes playback (by changing state to PLAYBACK_PLAYING), we perform the sync operation if the <code>_performOffsetSyncOnNextResume</code> flag is set.
		*
		* This method is also the only entity that is allowed to cancel a running sync operation, if one is in progress, and only when
		* replacing it with a new operation.
		*/ 
		protected function onViewportPlaybackStateChanged(e:ViewportEvent):void
		{
			switch (this._objectPool.viewport.playbackState)
			{
				case Viewport.PLAYBACK_SEEKING:
					this.cancelOffsetSync();
					
					this._performOffsetSyncOnNextResume = true;
					break;
				case Viewport.PLAYBACK_PLAYING:
					if (this._performOffsetSyncOnNextResume)
					{
						this.syncHandlersToViewportOffset();
						this._performOffsetSyncOnNextResume = false;
					}
					break;
			}
		}
		
		protected function onViewportAudioVolumeChanged(e:ViewportEvent):void
		{
			this.syncHandlersToViewportState();
		}
	}
}