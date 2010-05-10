package org.smilkit.render
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.events.TimingGraphEvent;
	import org.smilkit.time.ResolvedTimeElement;
	import org.smilkit.time.TimingGraph;
	import org.smilkit.view.Viewport;
	import org.smilkit.w3c.dom.smil.ISMILDocument;

	public class RenderTree
	{
		protected var _timeGraph:TimingGraph;
		protected var _canvas:Sprite;
		protected var _activeElements:Vector.<ResolvedTimeElement>;
		protected var _viewport:Viewport;
		
		public function RenderTree(viewport:Viewport, timeGraph:TimingGraph)
		{
			this._timeGraph = timeGraph;
			this._viewport = viewport;
			
			// listener for every heart beat (so we recheck the timing tree)
			this._viewport.heartbeat.addEventListener(TimerEvent.TIMER, this.onHeartbeatBeat);
			
			// listener to re-draw for every timing graph rebuild (does a fresh draw of the canvas - incase big things have changed)
			this._timeGraph.addEventListener(TimingGraphEvent.REBUILD, this.onTimeGraphRebuild);
		}
		
		public function get timeGraph():TimingGraph
		{
			return this._timeGraph;
		}
		
		public function get document():ISMILDocument
		{
			return this._timeGraph.document;
		}
		
		/**
		 * Returns the <code>Sprite</code> canvas the <code>RenderTree</code> draws too.
		 */
		public function get canvas():Sprite
		{
			return this._canvas;
		}
		
		/**
		 * Draws the elements to the canvas for the current point in time (according to the viewport).
		 */
		public function draw():void
		{
			this.drawActiveElements(this._viewport.offset);
		}
		
		/**
		 * Redraw draws everythings again on the Canvas, it starts by removing the current
		 * Canvas and then adding all the current selected elements.
		 */
		public function redraw():void
		{
			// reset
			this._canvas = new Sprite();
			this._activeElements = new Vector.<ResolvedTimeElement>();

			// !!!!
			this.draw();
		}
		
		public function drawActiveElements(offset:Number):void
		{
			var elements:Vector.<ResolvedTimeElement> = this._timeGraph.elements;
			var newActiveElements:Vector.<ResolvedTimeElement> = new Vector.<ResolvedTimeElement>();

			for (var i:int = 0; i < elements.length; i++)
			{
				var time:ResolvedTimeElement = elements[i];
				var alreadyExists:Boolean = (this._activeElements.indexOf(time) != -1);
				var activeNow:Boolean = time.activeAt(offset);
				
				// remove non active, existing elements
				if (!activeNow && alreadyExists)
				{
					// remove from canvas
					
					// dont add to new vector
				}
				// add active, non existant elements
				else if (activeNow)
				{
					// only add to the canvas, when the element hasnt existed before
					if (!alreadyExists)
					{
						// actually draw element to canvas ....
					}
					
					// always add to the new active list
					newActiveElements.push(time);
				}
			}
			
			// swap with new list
			this._activeElements = newActiveElements;
		}
		
		protected function onTimeGraphRebuild(e:TimingGraphEvent):void
		{
			this.redraw();
		}
		
		protected function onHeartbeatBeat(e:TimerEvent):void
		{
			this.draw();
		}
	}
}