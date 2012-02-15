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
package org.smilkit.render
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.TimeList;
	import org.smilkit.dom.smil.events.SMILMutationEvent;
	import org.smilkit.dom.smil.time.SMILTimeInstance;
	import org.smilkit.events.HandlerControllerEvent;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.time.SharedTimer;
	import org.smilkit.view.BaseViewport;
	import org.smilkit.view.Viewport;
	import org.smilkit.view.ViewportObjectPool;
	import org.utilkit.util.NumberHelper;
	
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
		
		protected var _offsetSyncHandlerList:Vector.<SMILKitHandler>;
		protected var _offsetSyncNextResume:Boolean = false;
		
		protected var _performOffsetSyncOnNextResume:Boolean = false;
		protected var _performOffsetSyncAfterUpdate:Boolean = false;
		
		protected var _useSyncCycles:Boolean = false;

		protected var _waitCycleFirstRun:Boolean = true;
		protected var _waitingForData:Boolean = false;
		protected var _waitingForSync:Boolean = false;
		// A handler with a seek result to which the scheduler will be locked
		// when a sync cycle exits (simple seek mode)
		protected var _simpleSyncLockHandler:SMILKitHandler;
		
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
			this.document.addEventListener(SMILMutationEvent.DOM_TIMEGRAPH_MODIFIED, this.onTimeGraphRebuild, false);

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
			SharedTimer.subscribe(this.onHeartbeatTick);
			
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
			return (!this.waitingForData() && !this.waitingForSync());
		}
		
		/**
		* Detaches this RenderTree instance from the owning viewport - this RenderTree will no long sync to viewport state.
		*/ 
		public function detach():void
		{
			SMILKit.logger.debug("Detaching from object pool", this);
			
			for (var i:int = 0; i < this._activeMediaElements.length; i++)
			{
				if (this._activeMediaElements[i].handler != null)
				{
					this._activeMediaElements[i].handler.pause();
					this._activeMediaElements[i].handler.destroy();
				}
			}
			
			this._activeTimingNodes = new Vector.<SMILTimeInstance>();
			this._activeMediaElements = new Vector.<SMILMediaElement>();
			
			this._waitingForDataHandlerList = new Vector.<SMILKitHandler>();
			
			this.document.removeEventListener(SMILMutationEvent.DOM_TIMEGRAPH_MODIFIED, this.onTimeGraphRebuild, false);

			SharedTimer.unsubscribe(this.onHeartbeatTick);
			
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
			if (this.viewport.playbackState == BaseViewport.PLAYBACK_PLAYING)
			{
				if (this.waitingForSync() || this.waitingForData())
				{
					SMILKit.logger.error("Asked to sync handlers to Viewport state, but assets are currently syncing.", this);
					
					return;
				}
				
				SMILKit.logger.debug("Syncing handlers to viewport state: viewport is running - resuming "+this.elements.length+" assets.", this);
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
					
					// reset the volume when were not using sync cycles (otherwise the handler will always be muted)
					node.mediaElement.handler.leaveFrozenState();
				}
			}
			else
			{
				SMILKit.logger.debug("Syncing handlers to viewport state: viewport is paused - pausing "+this.elements.length+" non-syncing assets.", this);
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
		 * Runs an offset sync operation on all handlers in the <code>HandlerController</code> instance.
		 * 
		 * 1) Simple seek, in a simple seek we seek the active handlers to the specified time, and adjust the DOM clock
		 * to match the times to handlers were able to seek too. With a simple seek, the handler starts to seek to the requested
		 * time and then the <code>HandlerController</code> matches the DOM clock to the handlers current position (after the seek).
		 * 
		 * 2) Complex seek, the DOM clock is adjusted to the requested time and all the handlers are seeked to match the DOM
		 * clock, we wait for all the handlers to match up to the desired time. During a complex seek, the handler is told to
		 * seek to the specified time, if it cannot seek without loading more, the handler enters its own wait cycle, freezes
		 * the display and begins to playback silently until the desired time is met. The indiviual handlers are responsible for
		 * completing the seek task given to them and must only dispatch SEEK_NOTIFY upon completion. 
		 * 
		 * When the handlers are first seeked, they are placed into the sync wait list and removed when the handler has finished
		 * seeking to the desired time (with the SEEK_NOTIFY event). When all handlers have been removed from the sync wait list,
		 * the <code>HandlerController</code> exits the sync cycle.
		 * 
		 */
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
			if(this.waitingForSync())
			{
				SMILKit.logger.debug("Asked to start a sync operation, but one is already in progress. Cancelling existing sync operation.", this);				
				this.cancelOffsetSync();
			}
			
			var seekables:Vector.<SMILTimeInstance> = new Vector.<SMILTimeInstance>();
			
			for (var s:uint = 0; s < this.elements.length; s++)
			{
				if (this.elements[s].mediaElement.handler.seekable)
				{
					seekables.push(this.elements[s]);
				}
			}
			
			var listWasEmpty:Boolean = !this.waitingForSync();

			var strict:Boolean = (seekables.length > 1);
			var offset:Number = this._objectPool.viewport.offset;

			for (var i:uint = 0; i < seekables.length; i++)
			{
				var time:SMILTimeInstance = seekables[i];
				var handler:SMILKitHandler = time.mediaElement.handler;
				var target:uint = Math.max(0, ((offset - time.begin.resolvedOffset) * 1000));
				
				SMILKit.logger.debug("Syncing handler to viewport offset, telling handler "+handler.handlerId+" to seek to: "+target+"ms");
				
				handler.seek(target, strict);
			}
		}
		
		/**
		* Cancels any sync operations that are in progress.
		*/
		protected function cancelOffsetSync():void
		{
			if(this.waitingForSync())
			{
				SMILKit.logger.debug("Cancelling a running sync operation.", this);
				this._offsetSyncHandlerList = new Vector.<SMILKitHandler>();
				this.syncHandlersToViewportState();
			}
		}
		
		/** 
		* Called when any handler on the RenderTree resolves its own intrinsic properties.
		* Used to initiate sync for any assets that are starting from cold (unloaded or unready) when added to the RenderTree.
		*/
		protected function onHandlerDurationResolved(e:HandlerEvent):void
		{
			var waitHandler:SMILKitHandler = e.handler;
		}
		
		protected function onHandlerSelfModified(e:HandlerEvent):void
		{
			this.reset();
			//this.update();
			this.syncHandlersToViewportOffset();
		}
		
		protected function onHandlerLoadFailed(e:HandlerEvent):void
		{
			this.dispatchEvent(new HandlerControllerEvent(HandlerControllerEvent.HANDLER_LOAD_FAILED, e.handler));
		}
		
		protected function onHandlerLoadUnauthorised(e:HandlerEvent):void
		{
			this.dispatchEvent(new HandlerControllerEvent(HandlerControllerEvent.HANDLER_LOAD_UNAUTHORISED, e.handler));
		}
		
		protected function onHandlerSeekWaiting(e:HandlerEvent):void
		{
			SMILKit.logger.debug("Handler "+e.handler+" dispatched SEEK_WAITING.", this);

			// For state comparison		
			var listWasEmpty:Boolean = (!this.waitingForSync());


			if(this._offsetSyncHandlerList == null)
			{
				this._offsetSyncHandlerList = new Vector.<SMILKitHandler>();
			}

			if (this._offsetSyncHandlerList.indexOf(e.handler) == -1)
			{
				this._offsetSyncHandlerList.push(e.handler);
			}

			// Deal with simple sync (single-handler syncing)
			// The state of the wait list at any single point in time cannot be taken
			// as an indicator of simple sync suitability, as the list may have contained
			// other handlers that have since finished syncing - checking that the list is
			// 1 item in length infers only that the list contains the last waiting handler,
			// not the only waiting handler.
			//
			// Therefore to gauge suitability for simple sync mode we need to ensure that 
			// the handler list never grows beyond one item in length and that it always
			// contains the same item - any breach of those conditions should clear
			// the scheduler lock.
			//
			// To follow: we'll check here for list changes as handlers enter a sync state.
			// We'll track the current candidate for scheduler correction as 
			// _simpleSyncLockHandler. If the list breaches the conditions for simple sync,
			// we'll set the _simpleSyncLockHandler to null.
			// 
			// When the sync cycle exits, we'll check _simpleSyncLockHandler and if it
			// contains a handler pointer, we'll nudge the document scheduler appropriately.

			// Check the list state against the lock
			if(this._simpleSyncLockHandler && this._offsetSyncHandlerList.length >= 1 && this._offsetSyncHandlerList[0] == e.handler)
			{
				// Change detected
				SMILKit.logger.warn("Simple sync conditions breached - received SEEK_WAITING from "+e.handler+" when prepared to lock scheduler with "+this._simpleSyncLockHandler+" - clearing scheduler lock", this);
				this._simpleSyncLockHandler = null;
			}
			else if(listWasEmpty && this._offsetSyncHandlerList.length == 1 && this.document.timeGraph.mediaElements.length <= 1)
			{
				SMILKit.logger.debug("Entering simple sync state with a single handler "+e.handler+", flagging this handler for scheduler lock when the sync loop exits.", this);
				this._simpleSyncLockHandler = e.handler;
			}

			this.waitHandlers();

			if (listWasEmpty && this.waitingForSync())
			{
				SMILKit.logger.debug("Entering sync wait cycle.", this);
				this._waitingForSync = true;
				this.dispatchEvent(new HandlerControllerEvent(HandlerControllerEvent.WAITING_FOR_SYNC, null));
			}
			else
			{
				SMILKit.logger.debug("Continuing existing sync wait cycle", this);
			}
		}

		/**
		* Called when any of the RenderTree's handlers completes an asynchronous seek event.
		*/
		protected function onHandlerSeekNotify(e:HandlerEvent=null):void
		{
			if (this._offsetSyncHandlerList != null)
			{
				var handler:SMILKitHandler = e.handler;
				var index:int = this._offsetSyncHandlerList.indexOf(handler);
				
				if(index >= 0)
				{
					// remove the handler from the list
					SMILKit.logger.warn("Received SEEK_NOTIFY from syncing handler "+handler+", removing from sync wait list", this);
					this._offsetSyncHandlerList.splice(index, 1);		
				}
				else
				{
					SMILKit.logger.warn("Received SEEK_NOTIFY from handler "+handler+", but handler was not in the sync wait list", this);
				}
				
				
				this.exitWaitCycleIfReady();
			}
			
		}

		protected function onHandlerStopNotify(e:HandlerEvent):void
		{
			SMILKit.logger.debug("Got STOP_NOTIFY from "+e.handler+". About to request out-of-band heartbeat tick.", this);
			
			//this.dispatchEvent(new HandlerControllerEvent(HandlerControllerEvent.ELEMENT_STOPPED, e.handler));
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
				
				handler.leaveFrozenState();
				
				if (index >= 0)
				{
					SMILKit.logger.debug("Handler removed from RenderTree's sync wait list", handler);
					
					this._offsetSyncHandlerList.splice(index, 1);
					
					this.exitWaitCycleIfReady();
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
					SMILKit.logger.debug("Handler "+handler+" removed from RenderTree's load wait list", this);
					this._waitingForDataHandlerList.splice(index, 1);
				}
				else {
					SMILKit.logger.warn("Handler "+handler+" not found on load wait list: "+this._waitingForDataHandlerList.join(","), this);
				}
				this.exitWaitCycleIfReady();
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
							
							// we have made some modifications, so lets look
							// over our current list and see how long we could wait before doing another update
							if (time.end.resolvedOffset > this._nextChangeOffset)
							{
								this._nextChangeOffset = time.element.currentEndInterval.resolvedOffset;
							}
							
							// hidden things skip the render tree and dont playback
							if (element.renderState != ElementTestContainer.RENDER_STATE_HIDDEN)
							{
								if (alreadyExists)
								{
									// why change anything, we already exist?
									//actionableChanges = true;
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
				
				// Action the update changes
				if (actionableChanges)
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
				
				var syncableCount:uint = 0;
				
				for (var s:uint = 0; s < this.elements.length; s++)
				{
					var mediaElement:SMILMediaElement = (this.elements[s].mediaElement);
					
					if (mediaElement.handler != null && mediaElement.handler.seekable)
					{
						syncableCount += 1;
					}
				}
				
				this._useSyncCycles = (syncableCount > 1);
				
				// UPDATE COMPLETE
				// Perform the sync if we flagged up that one is needed
				if(syncAfterUpdate && this._performOffsetSyncAfterUpdate) 
				{
					SMILKit.logger.warn("Sync cycles disabled, HandlerController will not sync assets together.");
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
			handler.addEventListener(HandlerEvent.LOAD_CANCELLED, this.onHandlerLoadReady);
			handler.addEventListener(HandlerEvent.SEEK_WAITING, this.onHandlerSeekWaiting);
			handler.addEventListener(HandlerEvent.SEEK_NOTIFY, this.onHandlerSeekNotify);
			handler.addEventListener(HandlerEvent.STOP_NOTIFY, this.onHandlerStopNotify);
			handler.addEventListener(HandlerEvent.DURATION_RESOLVED, this.onHandlerDurationResolved);
			handler.addEventListener(HandlerEvent.SELF_MODIFIED, this.onHandlerSelfModified);
			handler.addEventListener(HandlerEvent.LOAD_FAILED, this.onHandlerLoadFailed);
			handler.addEventListener(HandlerEvent.LOAD_UNAUTHORISED, this.onHandlerLoadUnauthorised);
			
			this._activeTimingNodes.push(timingNode);
			this._activeMediaElements.push(element);
			
			handler.addedToRenderTree(this);
			this.dispatchEvent(new HandlerControllerEvent(HandlerControllerEvent.ELEMENT_ADDED, handler));
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
				handler.removeEventListener(HandlerEvent.LOAD_CANCELLED, this.onHandlerLoadReady);
				handler.removeEventListener(HandlerEvent.DURATION_RESOLVED, this.onHandlerDurationResolved);
				handler.removeEventListener(HandlerEvent.SEEK_WAITING, this.onHandlerSeekWaiting);
				handler.removeEventListener(HandlerEvent.SEEK_NOTIFY, this.onHandlerSeekNotify);
				handler.removeEventListener(HandlerEvent.STOP_NOTIFY, this.onHandlerStopNotify);
				handler.removeEventListener(HandlerEvent.SELF_MODIFIED, this.onHandlerSelfModified);
			}
			
			// remove from the list
			this._activeTimingNodes.splice(listIndex, 1);
			this._activeMediaElements.splice(listIndex, 1);
			
			// pause playback
			handler.pause();

			// remove from sync wait list
			this.removeHandlerFromWaitingForSyncList(handler); // exitWaitCycleIfReady
			// remove from load wait list
			this.removeHandlerFromWaitingForDataList(handler); // exitWaitCycleIfReady();
			
			handler.removedFromRenderTree(this);
			// remove from canvas
			this.dispatchEvent(new HandlerControllerEvent(HandlerControllerEvent.ELEMENT_REMOVED, handler));
			
		}
		protected function timingNodeModifiedOnActiveList(timingNode:SMILTimeInstance):void
		{
			var element:SMILMediaElement = (timingNode.element as SMILMediaElement);
			var handler:SMILKitHandler = element.handler;
			this.dispatchEvent(new HandlerControllerEvent(HandlerControllerEvent.ELEMENT_MODIFIED, handler));
		}
		
		/**
		* Called when a handler reports that it needs more data. Throws the <code>RenderTree</code> into a waitingForData state
		* and dispatches the matching event.
		*/
		protected function onHandlerLoadWaiting(e:HandlerEvent):void
		{
			SMILKit.logger.debug("Handler "+e.handler+" dispatched LOAD_WAITING, about to enter load wait cycle.", this);
			
			var listWasEmpty:Boolean = (!this.waitingForData());

			if (this._waitingForDataHandlerList.indexOf(e.handler) == -1)
			{
				this._waitingForDataHandlerList.push(e.handler);
			}

			this.waitHandlers();

			if (listWasEmpty && this.waitingForData())
			{
				SMILKit.logger.debug("Entering load wait cycle.", this);
				this._waitingForData = true;
				this.dispatchEvent(new HandlerControllerEvent(HandlerControllerEvent.WAITING_FOR_DATA, null));
			}
			else
			{
				SMILKit.logger.debug("Continuing existing load wait cycle", this);
			}
		}
		
		/**
		* Called when a handler reports that it has enough data to begin playback.
		*/
		protected function onHandlerLoadReady(e:HandlerEvent):void
		{
			SMILKit.logger.debug("Handler "+e.handler+" dispatched LOAD_READY, checking load wait cycle status.", this);
			// remove from waiting list
			this.removeHandlerFromWaitingForDataList(e.handler);
		}
		
		protected function waitHandlers():void
		{
			SMILKit.logger.debug("Calling wait on all handlers in the HandlerController, with "+this._waitingForDataHandlerList.length+" handlers in the list.");
			
			this.update();
			
			for (var i:int = 0; i < this.elements.length; i++)
			{
				var handler:SMILKitHandler = this.elements[i].mediaElement.handler;
				
				if (handler != null)
				{
					handler.wait(this._waitingForDataHandlerList);
				}
			}
		}
		
		protected function unwaitHandlers():void
		{
			SMILKit.logger.debug("Calling unwait on all handlers in the HandlerController");
			
			for (var i:int = 0; i < this.elements.length; i++)
			{
				var handler:SMILKitHandler = this.elements[i].mediaElement.handler;
				
				if (handler != null)
				{
					handler.unwait();
				}
			}
		}
		
		protected function waitingForData():Boolean
		{
			return (this._waitingForDataHandlerList != null && this._waitingForDataHandlerList.length > 0);
		}

		protected function waitingForSync():Boolean
		{
			return (this._offsetSyncHandlerList != null && this._offsetSyncHandlerList.length > 0);
		}

		protected function exitWaitCycleIfReady():void
		{
			if(!this.waitingForData() && !this.waitingForSync())
			{
				// Lists are clear...
				if(this._waitCycleFirstRun || this._waitingForData || this._waitingForSync)
				{
					// and this is a change in state, or a first run
					SMILKit.logger.debug("Exiting wait state as load and sync cycles have both completed.", this);
					this.exitWaitCycle();
				}
				else
				{
					SMILKit.logger.debug("Refusing to exit wait cycle as we appear to have already exited.", this);
				}
			}
			else if(this.waitingForData())
			{
				// Still waiting on load
				SMILKit.logger.debug("Refusing to exit wait cycle as load operation is still waiting on "+this._waitingForDataHandlerList.join(","), this);
			}
			else if(this.waitingForSync())
			{
				// Still waiting on sync
				SMILKit.logger.debug("Refusing to exit wait cycle as sync operation is still waiting on "+this._offsetSyncHandlerList.join(","), this);
			}

			// Stow previous results
			this._waitCycleFirstRun = false;
			this._waitingForData = this.waitingForData();
			this._waitingForSync = this.waitingForSync();
		}

		protected function exitWaitCycle():void
		{
			// Called ONLY when both sync and load cycles have exited
			this.unwaitHandlers();

			if(this._simpleSyncLockHandler)
			{
				// Calculate offset
				var h:SMILKitHandler = this._simpleSyncLockHandler;
				var internalOffset:Number = h.currentOffset;
				var baseOffset:Number = (h.element.begin.first.resolved)? h.element.begin.first.resolvedOffset : 0;
				var resultOffset:Number = internalOffset+baseOffset;

				SMILKit.logger.debug("Exiting wait cycle with scheduler lock on "+h+", executing scheduler lock to "+resultOffset+" (internal "+internalOffset+" with base "+baseOffset+")", this);

				this.document.scheduler.seek(resultOffset);

				this._simpleSyncLockHandler = null;
			}

			this.dispatchEvent(new HandlerControllerEvent(HandlerControllerEvent.READY, null));
			this.syncHandlersToViewportState();
		}

		
		/**
		 * Function called when the TimingGraph rebuilds itself, this function in turn calls the reset function 
		 * @param e
		 * 
		 */		
		protected function onTimeGraphRebuild(e:SMILMutationEvent):void
		{
			this.reset();
			
			this.syncHandlersToViewportState();
			
			if (this.viewport.offset > 0)
			{
				//this.syncHandlersToViewportOffset();
			}
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
		
		protected function onHeartbeatTick(duration:Number, offset:Number):void
		{
			// this.exitWaitCycleIfReady(); - this should not be necessary. The handlers should be abiding by the event contract of dispatching SEEK_NOTIFY and LOAD_READY at the appropriate times to trigger wait exits or wait continuations if appropriate.
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
				case BaseViewport.PLAYBACK_SEEKING:
					this.cancelOffsetSync();
					
					SMILKit.logger.debug("Scheduling a new sync wait cycle to begin on the next Viewport state change to PLAYBACK_PLAYING", this);
					this._performOffsetSyncOnNextResume = true;
					
					// invalidate active cache
					this._lastChangeOffset = -1;
					this._nextChangeOffset = -1;
					
					break;
				case BaseViewport.PLAYBACK_PLAYING:
					if (this._performOffsetSyncOnNextResume)
					{
						SMILKit.logger.debug("About to run a scheduled sync wait cycle.", this);
						this.syncHandlersToViewportOffset();
						this._performOffsetSyncOnNextResume = false;
					}
					this._performOffsetSyncAfterUpdate = true;
					break;
				case BaseViewport.PLAYBACK_PAUSED:
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
			SMILKit.logger.debug("Syncing handlers to viewport state: viewport is running - resuming "+this.elements.length+" assets.", this);
			
			var volume:uint = this.viewport.volume;
			
			// Sync everything to the Viewports volume
			for (var i:int = 0; i < this.elements.length; i++)
			{
				var node:SMILTimeInstance = this.elements[i];
				
				node.mediaElement.handler.setVolume(volume);
			}
		}

		public override function toString():String
		{
			return super.toString()+"(on viewport "+(this.viewport ? this.viewport : "none")+")";
		}
	}
}