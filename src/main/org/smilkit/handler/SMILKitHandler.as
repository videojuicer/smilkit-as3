package org.smilkit.handler
{
	import flash.events.EventDispatcher;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.SMILRegionElement;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.render.RegionContainer;
	import org.smilkit.util.MathHelper;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.smilkit.events.HandlerEvent;

	public class SMILKitHandler extends EventDispatcher
	{
		protected var _element:IElement;
		protected var _startedLoading:Boolean = false;
		protected var _completedLoading:Boolean = false;
		protected var _completedResolving:Boolean = false;
		
		protected var _intrinsicDuration:int = Time.UNRESOLVED;
		
		public function SMILKitHandler(element:IElement)
		{
			this._element = element;
		}
		
		public function get startedLoading():Boolean
		{
			return this._startedLoading;
		}
		
		public function get completedLoading():Boolean
		{
			return this._completedLoading;
		}
		
		public function get completedResolving():Boolean
		{
			return this._completedResolving;
		}
		
		public function get intrinsicDuration():int
		{
			return this._intrinsicDuration;
		}
		
		public function get intrinsicWidth():uint
		{
			return 0;
		}
		
		public function get intrinsicHeight():uint
		{
			return 0;
		}
		
		public function get intrinsicSpatial():Boolean
		{
			return false;
		}
		
		public function get intrinsicTemporal():Boolean
		{
			return false;
		}
		
		public function get displayObject():DisplayObject
		{
			return null;
		}
		
		public function get resolvable():Boolean
		{
			return false;
		}
		
		public function get preloadable():Boolean
		{
			return true;
		}
		
		public function get element():ISMILMediaElement
		{
			return (this._element as ISMILMediaElement);
		}
		
		public function load():void
		{
			
		}
		
		public function pause():void
		{
			
		}
		
		public function resume():void
		{
			
		}
		
		public function seek(seekTo:Number):void
		{
			
		}
		
		/**
		 * Cancels the loading of the implementing handler, handlers should discard
		 * there current progress when this method is called unless loading is complete. 
		 */
		public function cancel():void
		{
			this._completedLoading = false;
			this._startedLoading = false;
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_CANCELLED, this));
		}
		
		public function movedToJustInTimeWorkList():void
		{
			if (!this.startedLoading)
			{
				this.load();
			}
		}
		
		public function movedToPreloadWorkList():void
		{
			if (!this.startedLoading && this.preloadable)
			{
				this.load();
			}
		}
		
		public function movedToResolveWorkList():void
		{
			if (!this.startedLoading && this.resolvable)
			{
				this.load();
			}
		}
		
		public function removedFromLoadScheduler():void
		{
			if (this.startedLoading)
			{
				this.cancel();
			}
		}
		
		/**
		 * Triggers the resolved event on the handler, the specified resolvedDuration
		 * is used to update the DOM element assigned to this handler.
		 * 
		 * @param resolvedDuration The resolved duration in miliseconds.
		 */
		protected function resolved(resolvedDuration:int):void
		{
			this._intrinsicDuration = resolvedDuration;
			this._completedResolving = true;
			
			// here we update the dom
			if (this.element != null && this.element.dur == Time.UNRESOLVED)
			{
				this.element.dur = this._intrinsicDuration;
			}
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.DURATION_RESOLVED, this));
		}
		
		/**
		 * Resizes the handler display object to fit inside the parent region. Uses a generic
		 * formula to resize the display object to fit inside the parent region as much as
		 * possible whilst maintaining the aspect-ratio.
		 * 
		 * Can be overridden by the implmeneting handler to provide different resizing logic.
		 * 
		 * @see MathHelper.createMatrixFor
		 */ 
		public function resize():void
		{
			var mediaElement:SMILMediaElement = (this.element as SMILMediaElement);
			var region:SMILRegionElement = (mediaElement.region as SMILRegionElement);
			
			if (region != null)
			{
				var container:RegionContainer = region.regionContainer;
				
				if (container != null)
				{
					var matrix:Rectangle = MathHelper.createMatrixFor(this, container);
					
					if (this.displayObject != null)
					{
						this.displayObject.width = matrix.width;
						this.displayObject.height = matrix.height;
						
						this.displayObject.x = matrix.x;
						this.displayObject.y = matrix.y;
					}
				}
			}
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return null;
			//return new HandlerMap([ "rtmp" ], [ "video/flv" = [ "flv", "f4v" ], "video/mpeg" = [ "mp4", "f4v" ] ]);
		}
	}
}