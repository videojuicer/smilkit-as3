package org.smilkit.render
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.events.SMILMutationEvent;
	import org.smilkit.dom.smil.time.SMILTimeInstance;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.events.RenderTreeEvent;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.time.SharedTimer;
	import org.smilkit.view.Viewport;
	import org.smilkit.view.ViewportObjectPool;
	
	/**
	 * Class responsible for checking the viewports play position and for requesting the display of certain DOM elements
	 * 
	 */	
	public class HandlerController extends EventDispatcher
	{
		/**
		 * Stored reference to the <code>ViewportObjectPool</code> instance including links to the parent <code>Viewport</code>.
		 */		
		protected var _objectPool:ViewportObjectPool;
		
		protected var _activeTimingNodes:Vector.<SMILTimeInstance>;
		protected var _activeMediaElements:Vector.<SMILMediaElement>;
		
		protected var _nextChangeOffset:int = -1;
		protected var _lastChangeOffset:int = -1;
		
		protected var _waitingForDataHandlerList:Vector.<SMILKitHandler>;
		protected var _waitingForData:Boolean = false;
		
		protected var _offsetSyncHandlerList:Vector.<SMILKitHandler>;
		protected var _offsetSyncOffsetList:Vector.<uint>;
		protected var _offsetSyncNextResume:Boolean = false;
		
		protected var _waitingForSync:Boolean = false;
		
		protected var _performOffsetSyncOnNextResume:Boolean = false;
		
		protected var _performOffsetSyncAfterUpdate:Boolean = false;
		
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
		public function HandlerController(objectPool:ViewportObjectPool)
		{
			this._objectPool = objectPool;
			
			// listener to re-draw for every timing graph rebuild (does a fresh draw of the canvas - incase big things have changed)
			//this.document.addEventListener(SMILMutationEvent.DOM_TIMEGRAPH_MODIFIED, this.onTimeGraphRebuild, false);

			// listener for every heart beat (so we recheck the timing graph)
			//this._objectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.RUNNING_OFFSET_CHANGED, this.onHeartbeatRunningOffsetChanged);
			//this._objectPool.viewport.heartbeat.addEventListener(TimerEvent.TIMER, this.onHeartbeatTick);
			
			// listener for heartbeat stop/go events
			//this._objectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.PAUSED, this.onHeartbeatPaused);
			//this._objectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.RESUMED, this.onHeartbeatResumed);
			
			//
			// listeners
			//
			
			// running offset event
			this.document.scheduler.addEventListener(HeartbeatEvent.RUNNING_OFFSET_CHANGED, this.onHeartbeatRunningOffsetChanged);
			
			// tick tick tick
			SharedTimer.instance.addEventListener(TimerEvent.TIMER, this.onHeartbeatTick);
			
			// pause / resume events
			this.document.scheduler.addEventListener(HeartbeatEvent.PAUSED, this.onHeartbeatPaused);
			this.document.scheduler.addEventListener(HeartbeatEvent.RESUMED, this.onHeartbeatResumed);
			
			// listener to detect playback state changes on the viewport
			this.viewport.addEventListener(ViewportEvent.PLAYBACK_STATE_CHANGED, this.onViewportPlaybackStateChanged);
			
			// listener for changing volume levels
			this.viewport.addEventListener(ViewportEvent.AUDIO_VOLUME_CHANGED, this.onViewportAudioVolumeChanged);
			
			this._activeTimingNodes = new Vector.<SMILTimeInstance>();
			this._activeMediaElements = new Vector.<SMILMediaElement>();
			
			this._waitingForDataHandlerList = new Vector.<SMILKitHandler>();
			
			this.reset();
		}
		
		public function get viewport():Viewport
		{
			return this._objectPool.viewport;
		}
		
		public function get elements():Vector.<SMILTimeInstance>
		{
			return this._activeTimingNodes;
		}
		
		public function get nextChangeOffset():int
		{
			return this._nextChangeOffset;
		}
		
		public function get lastChangeOffset():int
		{
			return this._lastChangeOffset;
		}
		
		public function get document():SMILDocument
		{
			return this._objectPool.document;
		}
		
		public function get hasDocumentAttached():Boolean
		{
			return (this.document != null);
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
		* Detaches this RenderTree instance from the owning viewport - this RenderTree will no long sync to viewport state.
		*/ 
		public function detach():void
		{
			SMILKit.logger.debug("Detaching from object pool", this);
			
			this.document.removeEventListener(SMILMutationEvent.DOM_TIMEGRAPH_MODIFIED, this.onTimeGraphRebuild, false);

			SharedTimer.instance.removeEventListener(TimerEvent.TIMER, this.onHeartbeatTick);
			
			this.document.scheduler.removeEventListener(HeartbeatEvent.RUNNING_OFFSET_CHANGED, this.onHeartbeatRunningOffsetChanged);
			this.document.scheduler.removeEventListener(HeartbeatEvent.PAUSED, this.onHeartbeatPaused);
			this.document.scheduler.removeEventListener(HeartbeatEvent.RESUMED, this.onHeartbeatResumed);
		
			this._objectPool.viewport.removeEventListener(ViewportEvent.PLAYBACK_STATE_CHANGED, this.onViewportPlaybackStateChanged);
			this._objectPool.viewport.removeEventListener(ViewportEvent.AUDIO_VOLUME_CHANGED, this.onViewportAudioVolumeChanged);
		}
		
		/**
		 * Updates the RenderTree for the current point in time (according to the Viewport).
		 */
		public function update():void
		{
			this.updateAt(this.document.offset);
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

			// !!!!
			this.update();
		}
		
		/**
		 * Syncs up all the handlers that exist in the <code>RenderTree</code> so they all resume at the same time (or as close as possible).
		 */
		public function syncHandlersToViewportState():void
		{
			if (this.document.scheduler.running)
			{
				SMILKit.logger.debug("Syncing handlers to viewport state: heartbeat is running - resuming "+this.elements.length+" assets.", this);
				// Sync everything to a running state by resuming playback.
				for (var i:int = 0; i < this.elements.length; i++)
				{
					var node:SMILTimeInstance = this.elements[i];
					
					if (node.mediaElement.playbackState == ElementTimeContainer.PLAYBACK_STATE_PAUSED)
					{
						node.mediaElement.handler.pause();
					}
					else
					{
						node.mediaElement.handler.resume();
					}
					
					node.mediaElement.handler.setVolume(this._objectPool.viewport.volume);
				}
			}
			else
			{
				SMILKit.logger.debug("Syncing handlers to viewport state: heartbeat is paused - pausing "+this.elements.length+" non-syncing assets.", this);
				// Sync to a paused heartbeat state by pausing everything EXCEPT handlers that are waiting for sync.
				for (var j:int = 0; j < this.elements.length; j++)
				{
					var pauseNode:SMILTimeInstance = this.elements[j];
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
		* In the event that an asset is added to the RenderTree at a non-zero internal offset (either a temporal asset
		* with the clip-begin attribute or a temporal asset introduced by way of a DOM manipulation such as an "excl"
		* tag re-evaluating, we must resume that asset from an internal seek and therefore a sync is needed.)
		*
		* A sync for any particular handler has several stages, each of which is considered asynchronous:
		*
		* 1. Resolve stage. If a handler has not yet resolved its own intrinsic properties, then step 2 is deferred until 
		*    it has done so and emitted a DURATION_RESOLVED event. Each seekable handler on the RenderTree instance is
		*    added to the sync wait list during this stage.
		* 2. Seek stage. The handler is seeked to offset determined by the findNearestSyncPoint method. We then wait until
		*    the handler dispatches a SEEK_NOTIFY event.
		* 3. Catchup stage. If the handler was seeked to a point before the desired offset, it is allowed to play silently
		*    until that offset is reached. The catchup phase will be skipped if playback is currently paused.
		* 4. Event loop stage. The offset of each handler on the sync wait list is checked, and removed if it is satisfactory.
		*    When no more handlers exist on the sync wait list, the sync loop exits.
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
		*
		* @see org.smilkit.render.RenderTree.onHandlerSeekNotify
		* @see org.smilkit.handler.SMILKitHandler.findNearestSyncPoint
		*/
		public function syncHandlersToViewportOffset():void
		{
			// Cancel any running sync operations
			if(this._waitingForSync)
			{
				SMILKit.logger.debug("Asked to start a sync operation, but one is already in progress. Cancelling existing sync operation.", this);
				this.cancelOffsetSync();
			}
			
			
			SMILKit.logger.debug("Beginning sync operation...", this);
			
			this._offsetSyncHandlerList = new Vector.<SMILKitHandler>();
			this._offsetSyncOffsetList = new Vector.<uint>();
			
			// Loop over all handlers
			for (var i:int = 0; i < this.elements.length; i++)
			{
				var node:SMILTimeInstance = this.elements[i];
				var handler:SMILKitHandler = (node.mediaElement.handler as SMILKitHandler);
				
				if(handler.seekable)
				{
					// Calculate the target offset for this handler
					// TODO include clip-begin into the equation
					var offset:uint = (this._objectPool.viewport.offset - node.currentBegin);
					
					// Push the handler onto the sync wait list
					this._offsetSyncHandlerList.push(handler);
					this._offsetSyncOffsetList.push(offset);
					
					if (!this._waitingForSync)
					{
						SMILKit.logger.debug("Waiting for sync on "+this._offsetSyncHandlerList.length+" handlers.", this);
						
						this._waitingForSync = true;				
						this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.WAITING_FOR_SYNC, null));
					}
					
					if(handler.completedResolving || handler.completedLoading)
					{
						handler.enterSyncState();
						
						this.execSyncHandlerForViewportOffset(handler);
					}
					else
					{
						SMILKit.logger.debug("Sync cycle encountered an unloaded or unresolved handler. Deferring sync on this handler until it has resolved itself.", this);
					}
				}
			}
			
			if (this._offsetSyncHandlerList.length == 0)
			{
				SMILKit.logger.debug("No handlers require sync at this time.", this);
			}
		}
		
		protected function execSyncHandlerForViewportOffset(handler:SMILKitHandler):void
		{
			if(this._offsetSyncHandlerList != null)
			{
				var index:int = this._offsetSyncHandlerList.indexOf(handler);
				if(index >= 0)
				{
					var offset:uint = this._offsetSyncOffsetList[index];
				
					if(handler.seekable)
					{						
						// Perform sync
						var nearestSyncPoint:Number = handler.findNearestSyncPoint(offset);
						var destinationOffset:Number;
						if(nearestSyncPoint <= offset){
							destinationOffset = nearestSyncPoint;
							SMILKit.logger.debug("Syncing a handler using known syncpoints. Seeking handler to "+destinationOffset+"ms (selected from "+handler.syncPoints.length+" syncpoints: "+handler.syncPoints.join(", ")+") with a target offset of "+offset+"ms. completedResolving: "+handler.completedResolving+", completedLoading"+ handler.completedLoading, this);
						}
						else
						{
							destinationOffset = offset ;
							SMILKit.logger.debug("Syncing a handler using random access (since nearest syncpoint was "+nearestSyncPoint+"ms). Seeking handler to "+offset+"ms.", this);
						};

						handler.seek(destinationOffset); // The SEEK_NOTIFY operation dispatched by this call will continue the sync for this handler.
					}
					else
					{
						// Remove from sync wait list
						SMILKit.logger.debug("About to begin a deferred sync on a handler, but the handler is no longer seekable. About to remove from wait list.", this);
						this.removeHandlerFromWaitingForSyncList(handler);
					}
				}			
				else
				{
					SMILKit.logger.debug("Asked to begin a deferred sync for a handler, but the handler could not be found on the sync wait list.", this);
				}
			}
		}
		
		/**
		* Cancels any sync operations that are in progress.
		*/
		protected function cancelOffsetSync():void
		{
			if(this._waitingForSync)
			{
				SMILKit.logger.debug("Cancelling a running sync operation.", this);
				this._waitingForSync = false;
				this._offsetSyncHandlerList = new Vector.<SMILKitHandler>();
				this._offsetSyncOffsetList = new Vector.<uint>();
				this.syncHandlersToViewportState();
			}
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
				var removeHandlers:Vector.<SMILKitHandler> = new Vector.<SMILKitHandler>;
				
				for (var i:int = 0; i < this._offsetSyncHandlerList.length; i++)
				{
					var waitHandler:SMILKitHandler = this._offsetSyncHandlerList[i];
					var waitOffset:uint = this._offsetSyncOffsetList[i];
					
					if (waitHandler.currentOffset >= waitOffset)
					{
						SMILKit.logger.debug("A handler is synced to "+waitHandler.currentOffset+" (target was "+waitOffset+"). Will remove from sync wait list.", this);
						// Sync is complete on this handler.
						removeHandlers.push(waitHandler);
						waitHandler.pause();						
						// TODO add to stage here??
					}
					// // Uncomment for ridiculous amounts of sync debug
					//else
					//{
					//	Logger.debug("A handler is synced to "+waitHandler.currentOffset+" but the target is "+waitOffset+". Continuing sync operation.", this);
					//}
				}
				
				// work backwards to avoid a fuck up with the indexes in mid-loop
				for (var j:int = 0; j < removeHandlers.length; j++)
				{
					this.removeHandlerFromWaitingForSyncList(waitHandler);
				}
				
				if (this._offsetSyncHandlerList.length < 1)
				{
					this._waitingForSync = false;
					
					if (!this._waitingForData)
					{
						SMILKit.logger.debug("Sync operation completed. RenderTree now READY.", this);
						this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.READY, null));
					}
					else
					{
						SMILKit.logger.debug("Sync operation completed. Waiting for load wait cycle to complete before the RenderTree is READY.", this);
					}
				}
				else
				{
					SMILKit.logger.debug("Waiting on "+this._offsetSyncHandlerList.length+" handlers to sync before sync operation complete.", this);
				}
			}
		}
		
		/** 
		* Called when any handler on the RenderTree resolves its own intrinsic properties.
		* Used to initiate sync for any assets that are starting from cold (unloaded or unready) when added to the RenderTree.
		*/
		protected function onHandlerDurationResolved(event:HandlerEvent):void
		{
			var waitHandler:SMILKitHandler = event.handler;
			this.execSyncHandlerForViewportOffset(waitHandler);
		}
		
		/**
		* Called when any of the RenderTree's handlers completes an asynchronous seek event.
		*/
		protected function onHandlerSeekNotify(event:HandlerEvent):void
		{
			if(this._offsetSyncHandlerList != null)
			{
				var waitHandler:SMILKitHandler = event.handler;
				var index:int = this._offsetSyncHandlerList.indexOf(waitHandler);
				var viewportPlaying:Boolean = (this._objectPool.viewport.playbackState == Viewport.PLAYBACK_PLAYING);

				if(index >= 0)
				{
					var waitOffset:uint = this._offsetSyncOffsetList[index];
					if(waitHandler.currentOffset < waitOffset && viewportPlaying)
					{
						SMILKit.logger.debug("Got SEEK_NOTIFY from a handler that is waiting for sync. Seek operation unacceptable - starting catchup playback.", this);
						waitHandler.setVolume(0);
						waitHandler.resume();
					}
					else
					{
						if(viewportPlaying)	SMILKit.logger.debug("Got SEEK_NOTIFY from a syncing handler. Seek operation acceptable - removing from wait list.", this);
						else SMILKit.logger.debug("Got SEEK_NOTIFY from a syncing handler. Viewport is paused - skipping catchup phase and removing from wait list.", this);

						waitHandler.pause();
						this.removeHandlerFromWaitingForSyncList(waitHandler);
					}
				}
			}
		}
		
		protected function onHandlerStopNotify(e:HandlerEvent):void
		{
			SMILKit.logger.debug("Got STOP_NOTIFY from "+e.handler+". About to request out-of-band heartbeat tick.", this);
			this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.ELEMENT_STOPPED, e.handler));
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
				
				handler.leaveSyncState();
				
				if (index >= 0)
				{
					SMILKit.logger.debug("Handler removed from RenderTree's sync wait list", handler);
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
					SMILKit.logger.debug("Handler removed from RenderTree's load wait list", handler);
					this._waitingForDataHandlerList.splice(index, 1);
					this.checkLoadState();
				}
			}
		}
		
		/**
		 * Checks the current position of the player and requests the stage be redrawn according to timings in the TimingGraph
		 * 
		 * Schedules an offset sync if an asset is added with a non-zero internal offset during normal playback.
		 *
		 * @see org.smilkit.render.RenderTree.syncHandlersToViewportOffset
		 * @param offset The offset to set the contents of the <code>RenderTree</code> to.
		 */		
		public function updateAt(offset:Number):void
		{
			if (this.elements != null && this.elements.length > 0)
			{
				//return;
			}
			
			// we only need to do a loop if the offset is less than our last change
			// or bigger than our next change
			if (offset < this._lastChangeOffset || offset >= this._nextChangeOffset)
			{			
				// Set the sync flag to false. It will be set to TRUE when adding a seekable handler to the RenderTree during a playing state.
				var syncAfterUpdate:Boolean = false;
				
				// Set up the action vectors
				var actionableChanges:Boolean = false;
				var removedTimingNodes:Vector.<SMILTimeInstance> = new Vector.<SMILTimeInstance>();
				var addedTimingNodes:Vector.<SMILTimeInstance> = new Vector.<SMILTimeInstance>();
				var modifiedTimingNodes:Vector.<SMILTimeInstance> = new Vector.<SMILTimeInstance>();
				
				// make a copy of the elements so we can update the list without causing loop issues
				var nodes:Vector.<SMILTimeInstance> = this.document.timeGraph.activeElements;
				
				for (var i:int = 0; i < nodes.length; i++)
				{
					var time:SMILTimeInstance = nodes[i];
					var element:SMILMediaElement = (time.element as SMILMediaElement);
					
					// skip time containers
					if (element != null)
					{
						var handler:SMILKitHandler = element.handler;
						
						if (handler != null)
						{
							var previousIndex:int = this._activeMediaElements.indexOf(element);
							var alreadyExists:Boolean = (previousIndex != -1);
							
							element.updateRenderState();
							
							// hidden things skip the render tree and dont playback
							if (element.renderState != ElementTestContainer.RENDER_STATE_HIDDEN)
							{
								if (alreadyExists)
								{
									actionableChanges = true;
									modifiedTimingNodes.push(time);
									
									this._lastChangeOffset = offset;
								}
								else
								{
									actionableChanges = true;
									addedTimingNodes.push(time);
									
									this._lastChangeOffset = offset;
									
									// If the element is being introduced at a non-zero internal offset we'll schedule a sync to run at the end of 
									// the update operation. Sync operations are only scheduled upon handler addition to the render tree if the 
									// viewport is currently playing.
									if(!syncAfterUpdate && handler.seekable)
									{
										syncAfterUpdate = true;
									}
								}
							}
							else
							{
								// remove if we used to exist and were now hidden
								if (alreadyExists)
								{
									actionableChanges = true;
									removedTimingNodes.push(time);
									
									this._lastChangeOffset = offset;
								}
							}
						}
					}
				}
				
				for (var k:int = 0; k < this.elements.length; k++)
				{
					var node:SMILTimeInstance = this.elements[k];
					
					if (modifiedTimingNodes.indexOf(node) != -1 || addedTimingNodes.indexOf(node) != -1 || removedTimingNodes.indexOf(node) != -1)
					{
						continue;
					}
					
					// doesnt exist on any list so must of been dropped off the active time graph
					removedTimingNodes.push(node);
				}

					
					
					// Have you ever looked at your console output and thought mournfully to yourself that it doesn't have enough ridiculously in-depth analysis of every RenderTree update?
					// WE THINK THE SAME.
					// Uncomment the lines below to fill your console with ludicrous amounts of RenderTree update diff debug!
					// Logger.debug("RenderTree update ("+offset+"ms) "+(i+1)+"/"+timingNodes.length+" processing node with begin: "+time.begin+" and end: "+time.end, this);
										

					/*
				if (time.begin != Time.UNRESOLVED && time.begin > offset && (time.begin < this._lastChangeOffset || this._lastChangeOffset == -1) && time.begin < this.nextChangeOffset)
				{
				this._nextChangeOffset = time.begin;
				}
				
					// remove non active, existing elements
					if (!activeNow && alreadyExists)
					{
						this._lastChangeOffset = offset;
						actionableChanges = true;
						removedTimingNodes.push(time);
					}
					// add active, non existant elements
					else if (activeNow)
					{						
						element.updateRenderState();
						
						if (element.renderState != ElementTestContainer.RENDER_STATE_HIDDEN)
						{
							// only add to the canvas, when the element hasnt existed before
							if (!alreadyExists)
							{
								this._lastChangeOffset = offset;
								actionableChanges = true;
								addedTimingNodes.push(time);
								// If the element is being introduced at a non-zero internal offset we'll schedule a sync to run at the end of 
								// the update operation. Sync operations are only scheduled upon handler addition to the render tree if the 
								// viewport is currently playing.
								// Also only schedule a sync operation if the asset is added at a non-zero timestamp
								if(!syncAfterUpdate && handler.seekable && time.begin != offset)
								{
									syncAfterUpdate = true;
								}
							}
							else
							{
								// already exists
								var previousTime:SMILTimeInstance = this._activeTimingNodes[previousIndex];
								if (time === previousTime && time != previousTime)
								{
									this._lastChangeOffset = offset;
									actionableChanges = true;
									modifiedTimingNodes.push(time);
								}
							}
						}
					}
					
				}*/
				
				// Action the update changes
				if(actionableChanges)
				{
					SMILKit.logger.debug("RenderTree.updateAt("+offset+"): actioning changes. "+addedTimingNodes.length+" added, "+removedTimingNodes.length+" removed, "+modifiedTimingNodes.length+" modified.", this);
					
					var actionTime:SMILTimeInstance;
					var actionHandler:SMILKitHandler;
					
					// Additions
					for(var a:int=0; a<addedTimingNodes.length; a++)
					{
						actionTime = addedTimingNodes[a];
						actionHandler = (actionTime.element as SMILMediaElement).handler;
						
						SMILKit.logger.debug("RenderTree.updateAt("+offset+"): ADD "+actionHandler.handlerId+":"+actionHandler+"("+actionTime.begin.resolvedOffset+"s-"+actionTime.end.resolvedOffset+"s)", this);
						
						this.addTimingNodeHandlerToActiveList(actionTime);
					}
					
					// Removals
					for(var r:int=0; r<removedTimingNodes.length; r++)
					{
						actionTime = removedTimingNodes[r];
						actionHandler = (actionTime.element as SMILMediaElement).handler;
						
						SMILKit.logger.debug("RenderTree.updateAt("+offset+"): REMOVE "+actionHandler.handlerId+":"+actionHandler+"("+actionTime.begin.resolvedOffset+"s-"+actionTime.end.resolvedOffset+"s)", this);
						
						this.removeTimingNodeHandlerFromActiveList(actionTime);
					}
					
					// Modifications
					for(var m:int=0; m<modifiedTimingNodes.length; m++)
					{
						actionTime = modifiedTimingNodes[m];
						actionHandler = (actionTime.element as SMILMediaElement).handler;
						
						SMILKit.logger.debug("RenderTree.updateAt("+offset+"): MOD "+actionHandler.handlerId+":"+actionHandler+"("+actionTime.begin.resolvedOffset+"s-"+actionTime.end.resolvedOffset+"s)", this);
						
						this.timingNodeModifiedOnActiveList(actionTime);
					}
					
					this.syncHandlersToViewportState();
				}
				
				// Remove anything no longer found on the timing graph
				var orphanCount:uint = this.garbageCollectOrphanedHandlers();
				
				if (orphanCount > 0)
				{
					SMILKit.logger.debug("RenderTree update at " + offset + "ms garbage collected " + orphanCount + " dead handlers", this);
				}
				
				// UPDATE COMPLETE
				// Perform the sync if we flagged up that one is needed
				if(syncAfterUpdate && this._performOffsetSyncAfterUpdate) 
				{
					SMILKit.logger.debug("About to run a sync operation scheduled for after the RenderTree has completed updating.")
					this._performOffsetSyncAfterUpdate = false;
					this.syncHandlersToViewportOffset();
				}
			}
		}
		
		protected function garbageCollectOrphanedHandlers():uint
		{
			// Get all handlers from the timing graph
			var tgHandlers:Vector.<SMILKitHandler> = new Vector.<SMILKitHandler>();
			
			if (this.document.timeGraph.mediaElements != null)
			{
				for (var i:uint = 0; i < this.document.timeGraph.mediaElements.length; i++)
				{
					tgHandlers.push(this.document.timeGraph.mediaElements[i].mediaElement.handler);
				}
			}

			var deadTimingNodes:Vector.<SMILTimeInstance> = new Vector.<SMILTimeInstance>();
			
			for (var p:uint = 0; p < this._activeTimingNodes.length; p++)
			{
				if(tgHandlers.indexOf(this._activeTimingNodes[p].mediaElement.handler) < 0)
				{
					deadTimingNodes.push(this._activeTimingNodes[p]);
				}
			}
			
			for (var l:uint = 0; l < deadTimingNodes.length; l++)
			{
				SMILKit.logger.debug("RenderTree GC: about to remove "+deadTimingNodes[l].mediaElement.handler+" as it is no longer present on the TimingGraph", this);
				this.removeTimingNodeHandlerFromActiveList(deadTimingNodes[l]);
				deadTimingNodes[l].mediaElement.handler.cancel();
			}
			
			return deadTimingNodes.length;
		}
		
		protected function addTimingNodeHandlerToActiveList(timingNode:SMILTimeInstance):void
		{
			var element:SMILMediaElement = (timingNode.element as SMILMediaElement);
			var handler:SMILKitHandler = element.handler;
			
			// we add our listeners for the dependancy management
			handler.addEventListener(HandlerEvent.LOAD_WAITING, this.onHandlerLoadWaiting);
			handler.addEventListener(HandlerEvent.LOAD_READY, this.onHandlerLoadReady);
			handler.addEventListener(HandlerEvent.LOAD_COMPLETED, this.onHandlerLoadReady);
			handler.addEventListener(HandlerEvent.SEEK_NOTIFY, this.onHandlerSeekNotify);
			handler.addEventListener(HandlerEvent.STOP_NOTIFY, this.onHandlerStopNotify);
			handler.addEventListener(HandlerEvent.DURATION_RESOLVED, this.onHandlerDurationResolved);
			
			this._activeTimingNodes.push(timingNode);
			this._activeMediaElements.push(element);
			
			handler.addedToRenderTree(this);
			this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.ELEMENT_ADDED, handler));
		}
		protected function removeTimingNodeHandlerFromActiveList(timingNode:SMILTimeInstance):void
		{
			var element:SMILMediaElement = (timingNode.element as SMILMediaElement);
			var handler:SMILKitHandler = element.handler;
			var listIndex:int = this._activeMediaElements.indexOf(element);
			
			if (handler.hasEventListener(HandlerEvent.LOAD_WAITING))
			{
				handler.removeEventListener(HandlerEvent.LOAD_WAITING, this.onHandlerLoadWaiting);
				handler.removeEventListener(HandlerEvent.LOAD_READY, this.onHandlerLoadReady);
				handler.removeEventListener(HandlerEvent.LOAD_COMPLETED, this.onHandlerLoadReady);
				handler.removeEventListener(HandlerEvent.DURATION_RESOLVED, this.onHandlerDurationResolved);
				handler.removeEventListener(HandlerEvent.SEEK_NOTIFY, this.onHandlerSeekNotify);
				handler.removeEventListener(HandlerEvent.STOP_NOTIFY, this.onHandlerStopNotify);
			}
			
			// remove from the list
			this._activeTimingNodes.splice(listIndex, 1);
			this._activeMediaElements.splice(listIndex, 1);
			
			// pause playback
			handler.pause();

			// remove from sync wait list
			this.removeHandlerFromWaitingForSyncList(handler); // checkSyncOperation
			// remove from load wait list
			this.removeHandlerFromWaitingForDataList(handler); // checkLoadState();
			
			handler.removedFromRenderTree(this);
			// remove from canvas
			this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.ELEMENT_REMOVED, handler));
			
		}
		protected function timingNodeModifiedOnActiveList(timingNode:SMILTimeInstance):void
		{
			var element:SMILMediaElement = (timingNode.element as SMILMediaElement);
			var handler:SMILKitHandler = element.handler;
			this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.ELEMENT_MODIFIED, handler));
		}
		
		/**
		* Called when a handler reports that it needs more data. Throws the <code>RenderTree</code> into a waitingForData state
		* and dispatches the matching event.
		*/
		protected function onHandlerLoadWaiting(e:HandlerEvent):void
		{
			SMILKit.logger.debug("Handler dispatched LOAD_WAITING, about to enter load wait cycle.", this);
			// add to waiting list
			this._waitingForDataHandlerList.push(e.handler);
			this.checkLoadState();
		}
		
		/**
		* Called when a handler reports that it has enough data to begin playback.
		*/
		protected function onHandlerLoadReady(e:HandlerEvent):void
		{
			SMILKit.logger.debug("Handler dispatched LOAD_READY, checking load wait cycle status.", this);
			// remove from waiting list
			this.removeHandlerFromWaitingForDataList(e.handler);
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
						SMILKit.logger.debug("Load wait cycle completed. RenderTree now READY.", this);
						this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.READY, null));
					}
					else
					{
						SMILKit.logger.debug("Load wait cycle completed. Still waiting for sync cycle to complete before RenderTree is READY.", this);
					}
				}
			}
			else
			{
				if (!this._waitingForData)
				{
					SMILKit.logger.debug("Entering load wait cycle.", this);
					// The wait list has items, but we are not yet officially waiting for data. 
					// Set the waitingForData flag and dispatch the relevant event.
					this._waitingForData = true;				
					// we have nothing on our plate, so we are ready!
					this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.WAITING_FOR_DATA, null));
				}
				SMILKit.logger.debug("Load wait cycle waiting for "+this._waitingForDataHandlerList.length+" handlers to dispatch LOAD_READY. ("+this._waitingForDataHandlerList.join(", ")+")", this);
			}
		}
		
		/**
		 * Function called when the TimingGraph rebuilds itself, this function in turn calls the reset function 
		 * @param e
		 * 
		 */		
		protected function onTimeGraphRebuild(e:SMILMutationEvent):void
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
			// refresh the state of the render tree first
			this.update();
			
			switch (this._objectPool.viewport.playbackState)
			{
				case Viewport.PLAYBACK_SEEKING:
					this.cancelOffsetSync();
					SMILKit.logger.debug("Scheduling a new sync wait cycle to begin on the next Viewport state change to PLAYBACK_PLAYING", this);
					this._performOffsetSyncOnNextResume = true;
					break;
				case Viewport.PLAYBACK_PLAYING:
					if (this._performOffsetSyncOnNextResume)
					{
						SMILKit.logger.debug("About to run a scheduled sync wait cycle.", this);
						this.syncHandlersToViewportOffset();
						this._performOffsetSyncOnNextResume = false;
					}
					this._performOffsetSyncAfterUpdate = true;
					break;
				case Viewport.PLAYBACK_PAUSED:
					if(this._performOffsetSyncOnNextResume)
					{
						SMILKit.logger.debug("Running interim quick sync cycle, leaving full cycle until next Viewport state change to PLAYBACK_PLAYING");
						this.syncHandlersToViewportOffset();
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