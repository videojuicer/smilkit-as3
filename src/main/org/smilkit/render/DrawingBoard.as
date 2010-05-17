package org.smilkit.render
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import mx.controls.Button;
	import mx.controls.Label;
	
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.events.RenderTreeEvent;
	import org.smilkit.time.ResolvedTimeElement;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.supportClasses.DisplayLayer;

	public class DrawingBoard extends Sprite
	{
		protected var _renderTree:RenderTree;
		protected var _canvas:Sprite;
		protected var _elements:Vector.<ResolvedTimeElement>;
		
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
							
							var displayObject:DisplayObject = (time.element as SMILMediaElement).handler.displayObject;
							
							// place element on canvas
							this._canvas.addChild(displayObject);
							
							this._elements.push(time);
						}
					}
				}
			}
		}
		
		/**
		 * Resets the Drawingboard to a default state, where the Canvas is blank.
		 */
		public function reset():void
		{
			this._elements = new Vector.<ResolvedTimeElement>();
			this._canvas = new Sprite();
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