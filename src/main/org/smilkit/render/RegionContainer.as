package org.smilkit.render
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.smil.SMILRegionElement;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.util.MathHelper;
	import org.smilkit.view.Viewport;
	import org.utilkit.util.Environment;

	public class RegionContainer extends Sprite
	{
		protected var _drawingBoard:DrawingBoard;
		protected var _region:SMILRegionElement;
		protected var _matrix:Rectangle;
		protected var _children:Vector.<SMILKitHandler>;
		protected var _renderTree:RenderTree;

		// Link context for managing click actions
		protected var _linkContextElement:Element;
		
		public function RegionContainer(region:SMILRegionElement, drawingBoard:DrawingBoard = null)
		{
			super();
			
			this._drawingBoard = drawingBoard;
			
			this._region = region;
			this._children = new Vector.<SMILKitHandler>();
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.addEventListener(MouseEvent.CLICK, this.onClick)
		}
		
		public function get region():SMILRegionElement
		{
			return this._region;
		}
		
		public function get drawingBoard():DrawingBoard
		{
			return this._drawingBoard;
		}
		
		public function set drawingBoard(drawingBoard:DrawingBoard):void
		{
			this._drawingBoard = drawingBoard;
		}
		
		public function get linkContextElement():Element
		{
			return this._linkContextElement;
		}
		
		public function set linkContextElement(e:Element):void
		{
			this._linkContextElement = e;
			this.buttonMode = (e != null);
			this.useHandCursor = (e != null);
		}
		
		public function get renderTree():RenderTree
		{
			return this._renderTree;
		}
		
		public function set renderTree(r:RenderTree):void
		{
			this._renderTree = r;
		}
		
		public override function get width():Number
		{
			if (this._matrix == null || this._matrix.width == 0)
			{
				return super.width;
			}
			
			return this._matrix.width;
		}
		
		public override function get height():Number
		{
			if (this._matrix == null || this._matrix.height == 0)
			{
				return super.height;
			}
			
			return this._matrix.height;
		}

		public function invalidateSizeAndLayout():void
		{
			if (this.drawingBoard != null)
			{
				this._matrix = new Rectangle();
				
				var width:String = this.region.getAttribute("width");
				var height:String = this.region.getAttribute("height");
				
				var parentWidth:int = this.drawingBoard.width;
				var parentHeight:int = this.drawingBoard.height;
				
				if (MathHelper.isPercentage(width))
				{
					var percentWidth:int = MathHelper.percentageToInteger(width);
					
					this._matrix.width = (percentWidth / 100) * parentWidth;
				}
				else
				{
					var widhthUnitsIndex:uint = width.search(/[%a-z]+/i);
					
					this._matrix.width = parseFloat(width.substring(0, widhthUnitsIndex));
				}
				
				if (MathHelper.isPercentage(height))
				{
					var percentHeight:int = MathHelper.percentageToInteger(height);
					
					this._matrix.height = (percentHeight / 100) * parentHeight;
				}
				else
				{
					var heightUnitsIndex:uint = height.search(/[%a-z]+/i);
					
					this._matrix.height = parseFloat(height.substring(0, heightUnitsIndex));
				}
				
				if (this.region.top != null)
				{
					this._matrix.y = parseFloat(this.region.top);
				}
				
				if (this.region.bottom != null)
				{
					this._matrix.y = (parentHeight - parseFloat(this.region.bottom) - this._matrix.height);
				}
				
				if (this.region.left != null)
				{
					this._matrix.x = parseFloat(this.region.left);
				}
				
				if (this.region.right != null)
				{
					this._matrix.x = (parentWidth - parseFloat(this.region.right) - this._matrix.width);
				}
				
				var backgroundColour:uint = 0xFFFFFF;
				var alpha:Number = 0;
				
				var backgroundAttribute:String = this.region.backgroundColor;
				var alphaAttribute:String = this.region.backgroundOpacity;
				
				if (backgroundAttribute == "random")
				{
					backgroundColour = Math.round(Math.random() * 0xFFFFFF);
					alpha = 1;
				}
				else if (backgroundAttribute == "transparent")
				{
					backgroundColour = 0xFFFFFF;
					alpha = 0;
				}
				else if (backgroundAttribute != null && backgroundAttribute != "")
				{
					if (backgroundAttribute.indexOf("#") != -1)
					{
						backgroundAttribute = "0x"+backgroundAttribute.slice(1, backgroundAttribute.length);
					}
					
					backgroundColour = new uint(backgroundAttribute);
					alpha = 1;
				}
				
				if (alphaAttribute != null && alphaAttribute != "")
				{
					if (MathHelper.isPercentage(alphaAttribute))
					{
						var alphaPercentage:uint = MathHelper.percentageToInteger(alphaAttribute);
						
						alpha = (alphaPercentage / 100);
					}
					else
					{
						alpha = parseFloat(alphaAttribute);
					}
				}
				
				this.graphics.clear();
				this.graphics.beginFill(backgroundColour, alpha);
				//this.graphics.lineStyle(0, 0xED05AF, 0.5);
				this.graphics.drawRect(0, 0, this._matrix.width, this._matrix.height);
				this.graphics.endFill();
				
				// actually position using the matrix as a guide
				this.width = this._matrix.width;
				this.height = this._matrix.height;
				
				this.x = this._matrix.x;
				this.y = this._matrix.y;
		
				// resize children!
				for (var i:int = 0; i < this._children.length; i++)
				{
					this._children[i].resize();
				}
			}
		}
		
		protected function onClick(e:MouseEvent):void
		{
			var context:Element = this.linkContextElement;
			if(context != null)
			{
				var viewport:Viewport;
				if(this.renderTree != null)
				{
					viewport = this.renderTree.viewport;
				}
				 
				var href:String = context.getAttribute("href");
				var target:String = context.getAttribute("target");
				if(target == null) target = "_blank";
				var sourcePlaystate:String = context.getAttribute("sourcePlaystate");
				if(sourcePlaystate == null) sourcePlaystate = "pause";
				
				if(href != null)
				{
					if(target == "_blank" && href.indexOf("http") == 0)
					{
						// Blank-targeted links navigate the browser
						SMILKit.logger.debug("Region with link context about to launch web link with href '"+href+"'", this);
						var req:URLRequest = new URLRequest(href);
						
						Environment.openWindow(req);
						
						if(viewport != null)
						{
							if(sourcePlaystate == "pause")
							{
								SMILKit.logger.debug("Pausing viewport as a link with sourcePlaystate=pause was activated", this);
								viewport.pause();
							}
						}
					}
					else if(href.indexOf("http") == 0)
					{
						// Self-targeted links spawn a new player session
						SMILKit.logger.debug("Region with link context about to load new presentation with href '"+href+"'", this);
						if(viewport != null)
						{
							viewport.location = href;
							if(!viewport.autoRefresh)
							{
								viewport.refresh();
							}
						}
					}
				}
			}
		}
		
		protected function onAddedToStage(e:Event):void
		{
			this.invalidateSizeAndLayout();
		}
		
		public function addAssetChild(handler:SMILKitHandler):void
		{	
			super.addChild(handler.displayObject);
			
			this._children.push(handler);
			
			handler.resize();
		}
		
		public function removeAssetChild(handler:SMILKitHandler):void
		{
			var children:Vector.<SMILKitHandler> = new Vector.<SMILKitHandler>();
			
			for (var i:int = 0; i < this._children.length; i++)
			{
				var child:SMILKitHandler = this._children[i];
				
				if (child != handler)
				{
					children.push(child);
				}
			}
			
			super.removeChild(handler.displayObject);
			this._children = children;
		}
		
		public function clear():void
		{
			for (var i:int = 0; i < this._children.length; i++)
			{
				this.removeAssetChild(this._children[i]);
			}
		}
		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			throw new IllegalOperationError("You can only add a SMILKitHandler to a RegionContainer, use addAssetChild() instead.");
		}
		
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			throw new IllegalOperationError("You can only add a SMILKitHandler to a RegionContainer, use addAssetChild() instead.");
		}
	}
}