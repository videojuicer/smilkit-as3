package org.smilkit.render
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	
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
			
			// listener for every heart beat (so we recheck the timing tree)
			this._objectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.OFFSET_CHANGED, this.onHeartbeatBeat);
			
			// listener to re-draw for every timing graph rebuild (does a fresh draw of the canvas - incase big things have changed)
			this.timingGraph.addEventListener(TimingGraphEvent.REBUILD, this.onTimeGraphRebuild);
			
			// listener to detect playback state changes on the viewport
			this._objectPool.viewport.addEventListener(ViewportEvent.PLAYBACK_STATE_CHANGED, this.onViewportPlaybackStateChanged);
			
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
			// TODO: Change volume
			// TODO: Ignore syncing handlers
			if (this._objectPool.viewport.playing && this._objectPool.viewport.ready)
			{
				// resume all!
				for (var i:int = 0; i < this.elements.length; i++)
				{
					var node:TimingNode = this.elements[i];
					
					node.mediaElement.handler.resume();
				}
			}
			else
			{
				// pause all!
				for (var j:int = 0; i < this.elements.length; i++)
				{
					var nodeJ:TimingNode = this.elements[j];
					
					nodeJ.mediaElement.handler.pause();
				}
			}
		}
		
		public function syncHandlersToViewportOffset():void
		{
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
					this._waitingForSync = true;
					
					this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.WAITING_FOR_SYNC, null));
				}
			}
		}
		
		public function cancelOffsetSync():void
		{
			this._waitingForSync = false;
			this._offsetSyncHandlerList = new Vector.<SMILKitHandler>();
			this._offsetSyncOffsetList = new Vector.<uint>();
			
			this.syncHandlersToViewportState();
		}
		
		public function checkSyncOperation():void
		{
			if (this._waitingForSync)
			{
				var removeIndexes:Array = new Array();
				
				for (var i:int = 0; i < this._offsetSyncHandlerList.length; i++)
				{
					var waitHandler:SMILKitHandler = this._offsetSyncHandlerList[i];
					var waitOffset:uint = this._offsetSyncOffsetList[i];
					
					if (waitHandler.currentOffset >= this._objectPool.viewport.offset)
					{
						removeIndexes.push(i);
						
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
					this.syncHandlersToViewportState();
					
					if (!this._waitingForData)
					{
						this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.READY, null));
					}
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
		
		protected function onHandlerLoadWaiting(e:HandlerEvent):void
		{
			// add to waiting list
			this._waitingForDataHandlerList.push(e.handler);
			
			this.checkLoadState()
		}
		
		protected function onHandlerLoadReady(e:HandlerEvent):void
		{
			// remove from waiting list
			var i:int = this._waitingForDataHandlerList.indexOf(e.handler, 0);
			
			if (i != -1)
			{
				this._waitingForDataHandlerList.splice(i, 1);
			}
			
			this.checkLoadState();
		}
		
		/**
		 * Runs a waiting / ready state check on the render tree contents and dispatches
		 * an event if the state changes.
		 */
		protected function checkLoadState():void
		{
			if (this._waitingForDataHandlerList.length == 0)
			{
				if (this._waitingForData)
				{
					// The list is empty, but we were waiting for data. This means the wait operation has concluded.
					this._waitingForData = false;					
					this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.READY, null));
				}
			}
			else
			{
				if (!this._waitingForData && !this._waitingForSync)
				{
					// The wait list has items, but we are not yet officially waiting for data. 
					// Set the waitingForData flag and dispatch the relevant event.
					this._waitingForData = true;				
					// we have nothing on our plate, so we are ready!
					this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.WAITING_FOR_DATA, null));
				}
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
		
		/**
		 * Function called when the Viewports heartbeat dispatches a TimerEvent, which then updates the RenderTree 
		 * @param e
		 */		
		protected function onHeartbeatBeat(e:HeartbeatEvent):void
		{
			this.update();
		}
		
		protected function onHeartbeatTick(e:TimerEvent):void
		{
			this.checkSyncOperation();
		}
		
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
					else
					{
						this.cancelOffsetSync();
					}
					break;
				default:
					this.cancelOffsetSync();
					break;
			}
		}
	}
}