package org.smilkit.render
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.events.RenderTreeEvent;
	import org.smilkit.events.TimingGraphEvent;
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
		 * Stored reference to the TimingGraph instance from its parent viewport 
		 */		
		protected var _objectPool:ViewportObjectPool;
		
		
		protected var _activeElements:Vector.<TimingNode>;
		
		protected var _nextChangeOffset:int = -1;
		protected var _lastChangeOffset:int = -1;
		
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
			this._objectPool.viewport.heartbeat.addEventListener(TimerEvent.TIMER, this.onHeartbeatBeat);
			
			// listener to re-draw for every timing graph rebuild (does a fresh draw of the canvas - incase big things have changed)
			this.timingGraph.addEventListener(TimingGraphEvent.REBUILD, this.onTimeGraphRebuild);
		
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

			// !!!!
			this.update();
		}
		
		/**
		 * Checks the current position of the player and requests the stage be redrawn according to timings in the TimingGraph
		 * @param offset
		 * 
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
					
					if (time.begin != Time.UNRESOLVED && time.begin > offset && (time.begin < this._lastChangeOffset || this._lastChangeOffset == -1))
					{
						this._nextChangeOffset = time.begin;
					}
					
					// remove non active, existing elements
					if (!activeNow && alreadyExists)
					{
						this._lastChangeOffset = offset;
						
						// remove from canvas
						this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.ELEMENT_REMOVED));
						
						// dont add to new vector
					}
					// add active, non existant elements
					else if (activeNow)
					{
						// only add to the canvas, when the element hasnt existed before
						if (!alreadyExists)
						{
							this._lastChangeOffset = offset;
							
							// actually draw element to canvas ....
							this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.ELEMENT_ADDED));
						}
						// already exists
						else
						{
							var previousTime:TimingNode = this._activeElements[previousIndex];
							
							if (time === previousTime && time != previousTime)
							{
								this._lastChangeOffset = offset;
								
								this.dispatchEvent(new RenderTreeEvent(RenderTreeEvent.ELEMENT_MODIFIED));
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
		protected function onHeartbeatBeat(e:TimerEvent):void
		{
			this.update();
		}
	}
}