package org.smilkit.render
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import mx.controls.Button;
	import mx.controls.Label;
	
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.SMILRegionElement;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.events.RenderTreeEvent;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.time.TimingNode;
	import org.smilkit.util.logger.Logger;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	public class DrawingBoard extends Sprite
	{
		protected var _renderTree:RenderTree;
		protected var _applicationStage:Stage;
		protected var _canvas:Sprite;
		protected var _elements:Vector.<TimingNode>;
		protected var _regions:Vector.<RegionContainer>;
		
		public function DrawingBoard()
		{
			this.reset();
		}
		
		public function get renderTree():RenderTree
		{
			return this._renderTree;
		}
		
		public function set renderTree(value:RenderTree):void
		{
			this._renderTree = value;
			this.reset();
		}
		
		/**
		 * Returns the <code>Sprite</code> canvas the <code>RenderTree</code> draws too.
		 */
		public function get canvas():Sprite
		{
			return this._canvas;
		}
		
		public function get applicationStage():Stage
		{
			return this._applicationStage;
		}
		
		public function set applicationStage(value:Stage):void
		{
			this._applicationStage = value;
		}
		
		/**
		 * Draws all the elements that exist in the RenderTree to the Canvas.
		 */
		public function draw():void
		{
			if (this.renderTree != null)
			{
				var elements:Vector.<TimingNode> = this._renderTree.elements;
				
				if (elements != null)
				{
					Logger.debug("Attempting to draw "+elements.length+" handlers to the Canvas", this);
					
					var drawnCount:int = 0;
					
					for (var i:int = 0; i < elements.length; i++)
					{
						var time:TimingNode = elements[i];
						
						// check if it doesnt exist yet
						if (this._elements.indexOf(time) == -1)
						{
							//time.element.resumeElement();
							
							var regionId:String = time.element.getAttribute("region");
							var region:SMILRegionElement = (this.renderTree.document.getElementById(regionId) as SMILRegionElement);
							
							if (region != null)
							{
								var handler:SMILKitHandler = (time.element as SMILMediaElement).handler;
								
								Logger.debug("Adding Handler to region '"+regionId+"' on the DrawingBoard", handler);
								drawnCount++;
								
								// place the element on to the region it belongs too
								region.regionContainer.addAssetChild(handler);
							}
							
							this._elements.push(time);
						}
					}
					
					if (drawnCount > 0)
					{
						Logger.debug("Drawn "+drawnCount+" handlers to the Canvas", this);
					}
				}
			}
		}
		
		/**
		 * Draws all the regions to the canvas.
		 */
		public function drawRegions():void
		{
			if (this.renderTree != null && this.renderTree.hasDocumentAttached)
			{
				this._regions = new Vector.<RegionContainer>();
				
				var regions:INodeList = this.renderTree.document.getElementsByTagName("region");
				
				for (var i:int = 0; i < regions.length; i++)
				{
					var node:INode = regions.item(i) as INode;
					var region:SMILRegionElement = (node as SMILRegionElement);
					
					region.regionContainer.drawingBoard = this;
					
					// hit a problem where the region would calculate its size based on the parent, when the region was
					// drawn to the parent and then the next region is calculated. the parent width + height masks were changed 
					// (as actionscript 3.0 sprites resize to fit there children). this made the next region calculations use another
					// set of dimensions for the parent and then only the first region would be sized correctly.
					//
					// we get around this by going through the list of regions twice, first time around we calculate the position
					// and sizing of each region, and then we go through again and add them to the drawing board
					region.regionContainer.invalidateSizeAndLayout();
					
					this._regions.push(region.regionContainer);
				}
				
				// add the regions now
				for (var j:int = 0; j < this._regions.length; j++)
				{
					this._canvas.addChild(this._regions[j]);
				}
				
				Logger.debug("Re-drawn "+this._regions.length+" regions to the DrawingBoard's Canvas", this);
			}
		}
		
		public function removeRegions():void
		{
			if (this.renderTree != null && this.renderTree.hasDocumentAttached && this._regions != null)
			{
				for (var i:int = 0; i < this._regions.length; i++)
				{
					var regionContainer:RegionContainer = this._regions[i];

					this._canvas.removeChild(regionContainer);
				}
				
				this._regions = new Vector.<RegionContainer>();
			}
			
			Logger.debug("Removed drawn regions", this);
		}
		
		/**
		 * Resets the Drawingboard to a default state, where the Canvas is blank.
		 */
		public function reset():void
		{
			if (this._canvas != null && this._canvas.parent != null)
			{
				super.removeChild(this._canvas);
				
				// we need to go through the regions and delete em
				this.removeRegions();
			}
			
			Logger.debug("Resetting the DrawingBoard and Canvas state", this);
			
			this._elements = new Vector.<TimingNode>();
			this._canvas = new Sprite();
			
			if (this._renderTree != null)
			{
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_ADDED, this.onRenderTreeElementAdded);
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_REMOVED, this.onRenderTreeElementRemoved);
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_MODIFIED, this.onRenderTreeElementModified);
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_REPLACED, this.onRenderTreeElementReplaced);
				
				this._renderTree.timingGraph.viewportObjectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.PAUSED, this.onHeartbeatPaused);
				this._renderTree.timingGraph.viewportObjectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.RESUMED, this.onHeartbeatResumed);
			}
			
			var parentWidth:Number = 0;
			var parentHeight:Number = 0;
			
			if (this.parent != null)
			{
				parentWidth = this.parent.width;
				parentHeight = this.parent.height;
				
				this.applicationStage.removeEventListener(Event.RESIZE, this.onApplicationStageResize);
				this.applicationStage.addEventListener(Event.RESIZE, this.onApplicationStageResize);
			}
			
			this._canvas.graphics.clear();
			
			this._canvas.graphics.beginFill(0xFFFFFF, 0.0);
			this._canvas.graphics.drawRect(0, 0, parentWidth, parentHeight);
			this._canvas.graphics.endFill();
			
			super.addChild(this._canvas);
			
			this.drawRegions();
		}
		
		protected function onApplicationStageResize(e:Event):void
		{
			this.reset();
		}
		
		public override function get width():Number
		{
			if (this.parent != null)
			{
				return this.parent.width;
			}
			
			return super.width;
		}
		
		public override function set width(value:Number):void
		{
			super.width = value;
			
			for (var i:int = 0; i < this._regions.length; i++)
			{
				var region:RegionContainer = this._regions[i] as RegionContainer;
				region.invalidateSizeAndLayout();
			}
		}
		
		public override function get height():Number
		{
			if (this.parent != null)
			{
				return this.parent.height;
			}
			
			return super.height;
		}
		
		public override function set height(value:Number):void
		{
			super.height = value;
			
			for (var i:int = 0; i < this._regions.length; i++)
			{
				var region:RegionContainer = this._regions[i] as RegionContainer;
				region.invalidateSizeAndLayout();
			}
		}
		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			throw new IllegalOperationError("Invalid method call, you cannot add a child to SMILKits drawing board.");
		}
		
		public override function removeChild(child:DisplayObject):DisplayObject
		{
			throw new IllegalOperationError("Invalid method call, you cannot remove a child from SMILKits drawing board.");
		}
		
		protected function onRenderTreeElementAdded(e:RenderTreeEvent):void
		{
			this.draw();
		}
		
		protected function onRenderTreeElementRemoved(e:RenderTreeEvent):void
		{
			this.reset();
			this.draw();
		}
		
		protected function onRenderTreeElementModified(e:RenderTreeEvent):void
		{
			this.reset();
			this.draw();
		}
		
		protected function onRenderTreeElementReplaced(e:RenderTreeEvent):void
		{
			this.reset();
			this.draw();
		}
		
		protected function onHeartbeatPaused(e:HeartbeatEvent):void
		{
			this.draw();
		}
		
		protected function onHeartbeatResumed(e:HeartbeatEvent):void
		{
			this.reset();
			this.draw();
		}
	}
}