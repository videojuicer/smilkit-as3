package org.smilkit.render
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.geom.Rectangle;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.SMILRegionElement;
	import org.smilkit.dom.smil.time.SMILTimeInstance;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.events.RenderTreeEvent;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	public class DrawingBoard extends Sprite
	{
		protected var _renderTree:RenderTree;
		protected var _canvas:Sprite;
		protected var _elements:Vector.<SMILTimeInstance>;
		protected var _regions:Vector.<RegionContainer>;
		
		protected var _boundingRect:Rectangle = new Rectangle(0, 0, 0, 0);
		protected var _boundingDisplayParent:Sprite = null;
		
		public function DrawingBoard()
		{
			this.reset();
		}
		
		/**
		 * The <code>RenderTree</code> instance used by this <code>DrawingBoard</code>.
		 */
		public function get renderTree():RenderTree
		{
			return this._renderTree;
		}
		
		/**
		 * Sets the <code>RenderTree</code> instance used by this <code>DrawingBoard</code>,
		 * resets the current state of the DrawingBoard when this is set.
		 */
		public function set renderTree(value:RenderTree):void
		{
			this._renderTree = value;
			this.reset();
		}
		
		/**
		 * Returns the <code>Sprite</code> canvas that the <code>RenderTree</code> draws too.
		 */
		public function get canvas():Sprite
		{
			return this._canvas;
		}
		
		/**
		* <code>Rectangle</code> that specifies the size at which the <code>DrawingBoard</code> is drawn, the x + y params
		* of <code>Rectangle</code> are ignored.
		*/
		public function get boundingRect():Rectangle
		{
			return this._boundingRect;
		}
		
		/**
		* Sets the <code>Rectangle</code> that specifies the size at which the <code>DrawingBoard</code> is drawn,
		* the x + y params of <code>Rectangle</code> are ignored.
		*/
		public function set boundingRect(rect:Rectangle):void
		{
			this._boundingRect = rect;
			
			this.reset();
			this.draw();
		}
		
		/**
		* The Sprite that the <code>DrawingBoard</code> exists inside of, automatically calls
		* addChild on the Sprite and adds the <code>DrawingBoard</code> as a child. Using this
		* still requires the update of <code>boundingRect</code> as Sprites dont issue 
		* resize events. 
		*/
		public function get boundingDisplayParent():Sprite
		{
			return this._boundingDisplayParent;
		}
		
		/**
		* Sets the Sprite that the <code>DrawingBoard</code> exists inside of, automatically calls
		* addChild on the Sprite and adds the <code>DrawingBoard</code> as a child. Using this
		* still requires the update of <code>boundingRect</code> as Sprites dont issue 
		* resize events. 
		*/
		public function set boundingDisplayParent(parent:Sprite):void
		{
			this._boundingDisplayParent = parent;

			this._boundingDisplayParent.addChild(this);
		}
		
		/**
		 * Draws all the elements that exist in the RenderTree to the Canvas.
		 */
		public function draw():void
		{
			if (this.renderTree != null)
			{
				var elements:Vector.<SMILTimeInstance> = this._renderTree.elements;
				
				if (elements != null)
				{
					SMILKit.logger.debug("Attempting to draw "+elements.length+" handlers to the Canvas", this);
					
					var drawnCount:int = 0;
					
					for (var i:int = 0; i < elements.length; i++)
					{
						var time:SMILTimeInstance = elements[i];
						
						// check if it doesnt exist yet
						if (this._elements.indexOf(time) == -1)
						{
							var region:SMILRegionElement = ((time.element as SMILMediaElement).region as SMILRegionElement);
							
							if (region != null)
							{
								var mediaElement:SMILMediaElement = time.mediaElement;
								var handler:SMILKitHandler = mediaElement.handler;
								
								SMILKit.logger.debug("Adding Handler to region '"+region.id+"' on the DrawingBoard", handler);
								drawnCount++;
								
								// place the element on to the region it belongs too
								region.regionContainer.addAssetChild(handler);
								region.regionContainer.renderTree = this._renderTree;
								
								if(handler.spatial)
								{
									region.regionContainer.linkContextElement = mediaElement.linkContextElement;
								}
								// Examine the link context with element.linkParent
								// Set link href and target on regioncontainer
									// set pointerCursor if link context found
									// set null if no link context
									
							}
							
							this._elements.push(time);
						}
					}
					
					if (drawnCount > 0)
					{
						SMILKit.logger.debug("Drawn "+drawnCount+" handlers to the Canvas", this);
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
				
				SMILKit.logger.debug("Re-drawn "+this._regions.length+" regions to the DrawingBoard's Canvas", this);
			}
		}
		
		public function removeRegions():void
		{
			if (this.renderTree != null && this.renderTree.hasDocumentAttached && this._regions != null)
			{
				for (var i:int = 0; i < this._regions.length; i++)
				{
					var regionContainer:RegionContainer = this._regions[i];
					regionContainer.clear();
					
					this._canvas.removeChild(regionContainer);
				}
				
				this._regions = new Vector.<RegionContainer>();
			}
			
			SMILKit.logger.debug("Removed drawn regions", this);
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
			
			SMILKit.logger.debug("Resetting the DrawingBoard and Canvas state", this);
			
			this._elements = new Vector.<SMILTimeInstance>();
			this._canvas = new Sprite();
			
			if (this._renderTree != null)
			{
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_ADDED, this.onRenderTreeElementAdded);
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_REMOVED, this.onRenderTreeElementRemoved);
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_MODIFIED, this.onRenderTreeElementModified);
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_REPLACED, this.onRenderTreeElementReplaced);
	
				this._renderTree.document.viewportObjectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.PAUSED, this.onHeartbeatPaused);
				this._renderTree.document.viewportObjectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.RESUMED, this.onHeartbeatResumed);
			}
			
			this._canvas.graphics.clear();
			
			this._canvas.graphics.beginFill(0xFFFFFF, 0.0);
			this._canvas.graphics.drawRect(0, 0, this.boundingRect.width, this.boundingRect.height);
			this._canvas.graphics.endFill();
			
			super.addChild(this._canvas);
			
			this.drawRegions();
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