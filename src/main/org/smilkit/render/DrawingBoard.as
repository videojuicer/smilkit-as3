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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.geom.Rectangle;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.SMILRegionElement;
	import org.smilkit.dom.smil.display.DisplayStackEvent;
	import org.smilkit.dom.smil.time.SMILTimeInstance;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.events.HandlerControllerEvent;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	public class DrawingBoard extends Sprite
	{
		protected var _handlerController:HandlerController;
		protected var _canvas:Sprite;
		protected var _elements:Vector.<ElementTimeContainer>;
		protected var _regions:Vector.<RegionContainer>;
		
		protected var _boundingRect:Rectangle = new Rectangle(0, 0, 0, 0);
		protected var _boundingDisplayParent:Sprite = null;
		
		protected var _usingRootRegion:SMILRegionElement = null;
		
		public function DrawingBoard()
		{
			this.reset();
		}
		
		/**
		 * The <code>RenderTree</code> instance used by this <code>DrawingBoard</code>.
		 */
		public function get renderTree():HandlerController
		{
			return this._handlerController;
		}
		
		/**
		 * Sets the <code>RenderTree</code> instance used by this <code>DrawingBoard</code>,
		 * resets the current state of the DrawingBoard when this is set.
		 */
		public function set renderTree(value:HandlerController):void
		{
			this._handlerController = value;
			this.reset();
		}
		
		public function get ownerDocument():SMILDocument
		{
			return this.renderTree.document;
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
				var elements:Vector.<ElementTimeContainer> = this.ownerDocument.displayStack.elements;
				
				if (elements != null && elements.length > 0)
				{
					SMILKit.logger.debug("Attempting to draw "+elements.length+" handlers to the Canvas", this);
					
					var drawnCount:int = 0;
					
					for (var i:int = 0; i < elements.length; i++)
					{
						var element:ElementTimeContainer = elements[i];
						var mediaElement:SMILMediaElement = (element as SMILMediaElement);
						
						// check if it doesnt exist yet
						if (mediaElement != null)
						{
							if (this._elements.indexOf(element) == -1)
							{
								var region:SMILRegionElement = (mediaElement.region as SMILRegionElement);
								
								if (this._usingRootRegion != null && region == null)
								{
									region = this._usingRootRegion;
								}
								
								if (region != null)
								{
									var handler:SMILKitHandler = mediaElement.handler;
									
									SMILKit.logger.benchmark("Adding Handler to region '"+region.id+"' on the DrawingBoard", handler);
									
									drawnCount++;
									
									// place the element on to the region it belongs too
									region.regionContainer.addAssetChild(handler);
									region.regionContainer.renderTree = this._handlerController;
									
									if(handler.spatial)
									{
										region.regionContainer.linkContextElement = mediaElement.linkContextElement;
									}
									
									// Examine the link context with element.linkParent
									// Set link href and target on regioncontainer
										// set pointerCursor if link context found
										// set null if no link context
										
								}
								
								this._elements.push(element);
							}
						}
					}
					
					if (drawnCount > 0)
					{
						SMILKit.logger.benchmark("Drawn "+drawnCount+" handlers to the Canvas", this);
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
				
				var regionsElements:INodeList = this.renderTree.document.getElementsByTagName("region");
				var regions:Vector.<SMILRegionElement> = new Vector.<SMILRegionElement>();
				
				if (regionsElements.length > 0)
				{
					for (var i:int = 0; i < regionsElements.length; i++)
					{
						var node:INode = regionsElements.item(i) as INode;
						var regionEl:SMILRegionElement = (node as SMILRegionElement);
						
						regions.push(regionEl);
					}
				}
				else
				{
					// we have no regions, so lets make a default called 'fake-root'
					var rootRegion:SMILRegionElement = new SMILRegionElement(this.ownerDocument);
					
					rootRegion.setAttribute("id", "fake-root");
					
					rootRegion.setAttribute("height", "100%");
					rootRegion.setAttribute("width", "100%");
					
					// to help with debugging
					//rootRegion.setAttribute("backgroundColor", "#EEEEEE");
					
					// and assign all of our children to it
					this._usingRootRegion = rootRegion;
					
					regions.push(this._usingRootRegion);
				}
				
				// here we sort by z-index!
				regions.sort(function(regionA:SMILRegionElement, regionB:SMILRegionElement):int
				{
					var regionAIndex:String = regionA.zIndex;
					var regionBIndex:String = regionB.zIndex;
					
					var aIndex:Number = 0;
					var bIndex:Number = 0;
					
					if (regionAIndex != null && regionAIndex != "")
					{
						aIndex = parseInt(regionAIndex);
					}
					
					if (regionBIndex != null && regionBIndex != "")
					{
						bIndex = parseInt(regionBIndex);
					}
					
					if (aIndex < bIndex)
					{
						return -1;
					}
					else if (aIndex > bIndex)
					{
						return 1;
					}
					else
					{
						return 0;
					}	
				});
				
				for (var j:int = 0; j < regions.length; j++)
				{
					var region:SMILRegionElement = regions[j];
					
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
				for (var k:int = 0; k < this._regions.length; k++)
				{
					this._canvas.addChild(this._regions[k]);
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
			
			this._elements = new Vector.<ElementTimeContainer>();
			this._canvas = new Sprite();
			
			if (this._handlerController != null)
			{
				this.ownerDocument.displayStack.addEventListener(DisplayStackEvent.ELEMENT_ADDED, this.onDisplayStackElementAdded);
				this.ownerDocument.displayStack.addEventListener(DisplayStackEvent.ELEMENT_REMOVED, this.onDisplayStackElementRemoved);
			}
			
			this._canvas.graphics.clear();
			
			this._canvas.graphics.beginFill(0xFFFFFF, 0.0);
			this._canvas.graphics.drawRect(0, 0, this.boundingRect.width, this.boundingRect.height);
			this._canvas.graphics.endFill();
			
			//this._canvas.graphics.beginFill(0xA62A2A, 0.4);
			//this._canvas.graphics.drawRect(10, 10, this.boundingRect.width - 20, this.boundingRect.height - 20);
			//this._canvas.graphics.endFill();
			
			super.addChild(this._canvas);
			
			this._usingRootRegion = null;
			
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
		
		protected function onDisplayStackElementAdded(e:DisplayStackEvent):void
		{
			this.draw();
		}
		
		protected function onDisplayStackElementRemoved(e:DisplayStackEvent):void
		{
			this.reset();
			this.draw();
		}
		
		protected function onRenderTreeElementModified(e:HandlerControllerEvent):void
		{
			this.reset();
			this.draw();
		}
		
		protected function onRenderTreeElementReplaced(e:HandlerControllerEvent):void
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