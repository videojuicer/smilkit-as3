package org.smilkit.handler
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.SMILRegionElement;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.handler.state.HandlerState;
	import org.smilkit.render.RegionContainer;
	import org.smilkit.util.MathHelper;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class SMILKitHandler extends EventDispatcher
	{
		protected var _element:IElement;
		protected var _startedLoading:Boolean = false;
		protected var _completedLoading:Boolean = false;
		protected var _completedResolving:Boolean = false;
		
		protected var _currentOffset:int;
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
		
		public function get handlerState():HandlerState
		{
			return null;	
		}
		
		public function get element():ISMILMediaElement
		{
			return (this._element as ISMILMediaElement);
		}
		
		public function get currentOffset():int
		{
			return this._currentOffset;
		}
		
		public function load():void
		{
			
		}
		
		/**
		 * Pause's the playback of the handler instance, as a pause does not usually occur
		 * on a stream instantly a <code>HandlerEvent.PAUSE_NOTIFY</code> should be dispatched
		 * once the stream has actually paused.
		 * 
		 * @see org.smilkit.event.HandlerEvent.PAUSE_NOTIFY
		 */
		public function pause():void
		{
			
		}
		
		/**
		 * Resume's playback of the handler instance, as a resume does not usually occur on
		 * a stream straight away a <code>HandlerEvent.RESUME_NOTIFY</code> is dispatched
		 * once the resume has been completed successfully.
		 * 
		 * @see org.smilkit.event.HandlerEvent.RESUME_NOTIFY
		 */
		public function resume():void
		{
			
		}
		
		/**
		 * Seeks the handler instance to the specified offset, as a seek does not usually happen
		 * on a stream straight away a <code>HandlerEvent.SEEK_NOTIFY</code> is dispatched once
		 * the seek has been completed successfully. In Flash a seek can only occur on a keyframe
		 * in a video stream, so the actual seek time will most likely differ after the event
		 * is dispatched.
		 * 
		 * If the seek offset is an invalid time, a <code>HandlerEvent.SEEK_INVALIDTIME</code>
		 * event is dispatched. If a seek was requested on a stream that is broken or the seek
		 * could not be completed successfully a <code>HandlerEvent.SEEK_FAILED</code> will be
		 * dispatched.
		 * 
		 * @param seekTo The offset to seek the handler to.
		 * 
		 * @see org.smilkit.event.HandlerEvent.SEEK_NOTIFY
		 * @see org.smilkit.event.HandlerEvent.SEEK_INVALIDTIME
		 * @see org.smilkit.event.HandlerEvent.SEEK_FAILED
		 */
		public function seek(seekTo:Number):void
		{
			
		}
		
		/**
		 * Merges the old handler state into this handler instance, this mainly provides
		 * functionality for switching dynamic streams through RTMP.
		 * 
		 * @param handlerState The <code>HandlerState</code> to merge with the current handler instance.
		 * 
		 * @return Returns true if the <code>HandlerState</code> was successfully merged with
		 * the current handler instance, false otherwise.
		 * 
		 * @see org.smilkit.handler.HandlerState
		 */
		public function merge(handlerState:HandlerState):Boolean
		{
			if (this.handlerState.compatibleWith(handlerState))
			{
				this._currentOffset = handlerState.handlerOffset;
				
				return true;
			}
			
			return false;
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
		
		/**
		 * Callback method for when the <code>LoadScheduler</code> moves this handler instance
		 * to the just in time work list. The just in time queue starts loading as soon as its
		 * placed on the queue.
		 * 
		 * @see org.smilkit.load.LoadScheduler
		 */
		public function movedToJustInTimeWorkList():void
		{
			if (!this.startedLoading)
			{
				this.load();
			}
			
			if (this.completedLoading)
			{
				// were ready since load has finished!
				this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
			}
		}
		
		/**
		 * Callback method for when the <code>LoadScheduler</code> moves this handler instance
		 * to the preload work list. 
		 * 
		 * @see org.smilkit.load.LoadScheduler
		 */
		public function movedToPreloadWorkList():void
		{
			if (!this.startedLoading && this.preloadable)
			{
				this.load();
			}
		}
		
		/**
		 * Callback method for when the <code>LoadScheduler</code> moves this handler instance
		 * to the resolve work list. When the handler is moved to the resolve work list, the 
		 * handler begins to load until it is resolved, after that an event is dispatched to
		 * the <code>LoadScheduler</code> which either cancels the loading of the handler or keeps
		 * it going (if its about to be played back).
		 * 
		 * @see org.smilkit.load.LoadScheduler
		 */
		public function movedToResolveWorkList():void
		{
			if (!this.startedLoading && this.resolvable)
			{
				this.load();
			}
		}
		
		/**
		 * Callback method for when the <code>LoadScheduler</code> removes this handler instance
		 * from any work list.
		 * 
		 * @see org.smilkit.load.LoadScheduler
		 */
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
		
		/**
		 * Returns a <code>HandlerMap</code> which can be used to match and register against
		 * this handler instance.
		 * 
		 * @return The <code>HandlerMap</code> instance for this handler.
		 * 
		 * @see org.smilkit.handler.HandlerMap
		 */
		public static function toHandlerMap():HandlerMap
		{
			return null;
		}
	}
}