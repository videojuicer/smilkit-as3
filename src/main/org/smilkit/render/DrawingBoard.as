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
	import org.smilkit.events.RenderTreeEvent;
	import org.smilkit.time.ResolvedTimeElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.supportClasses.DisplayLayer;


	public class DrawingBoard extends Sprite
	{
		protected var _renderTree:RenderTree;
		protected var _applicationStage:Stage;
		protected var _canvas:Sprite;
		protected var _elements:Vector.<ResolvedTimeElement>;
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
				var elements:Vector.<ResolvedTimeElement> = this._renderTree.elements;
				
				if (elements != null)
				{
					for (var i:int = 0; i < elements.length; i++)
					{
						var time:ResolvedTimeElement = elements[i];
						
						// check if it doesnt exist yet
						if (this._elements.indexOf(time) == -1)
						{
							time.element.resumeElement();
							
							var regionId:String = time.element.getAttribute("region");
							var region:SMILRegionElement = (this.renderTree.document.getElementById(regionId) as SMILRegionElement);
							
							if (region != null)
							{
								var displayObject:DisplayObject = (time.element as SMILMediaElement).handler.displayObject;
								
								// place the element on to the region it belongs too
								region.regionContainer.addChild(displayObject);
							}
							
							this._elements.push(time);
						}
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
					
					this._canvas.addChild(region.regionContainer);
					this._regions.push(region.regionContainer);
				}
			}
		}
		
		/**
		 * Resets the Drawingboard to a default state, where the Canvas is blank.
		 */
		public function reset():void
		{
			if (this._canvas != null && this._canvas.parent != null)
			{
				super.removeChild(this._canvas);
			}
			
			this._elements = new Vector.<ResolvedTimeElement>();
			this._canvas = new Sprite();
			
			if (this._renderTree != null)
			{
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_ADDED, this.onRenderTreeElementAdded);
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_REMOVED, this.onRenderTreeElementRemoved);
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_MODIFIED, this.onRenderTreeElementModified);
				this._renderTree.addEventListener(RenderTreeEvent.ELEMENT_REPLACED, this.onRenderTreeElementReplaced);
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
			if (this.stage != null)
			{
				return this.stage.stageWidth;
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
			if (this.stage != null)
			{
				return this.stage.stageHeight;
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
	}
}