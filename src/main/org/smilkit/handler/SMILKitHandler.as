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
package org.smilkit.handler
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.ElementLoadableContainer;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.FileSize;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.SMILRegionElement;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.handler.state.HandlerState;
	import org.smilkit.render.HandlerController;
	import org.smilkit.render.RegionContainer;
	import org.smilkit.util.MathHelper;
	import org.smilkit.view.ViewportObjectPool;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class SMILKitHandler extends EventDispatcher
	{
		public static var __idCounter:int = 0;
		
		protected var _handlerId:int;
		protected var _element:IElement;
		protected var _mediaElement:SMILMediaElement;
		protected var _startedLoading:Boolean = false;
		protected var _completedLoading:Boolean = false;
		protected var _completedResolving:Boolean = false;
		protected var _shield:Sprite;
		
		protected var _currentOffset:int;
		protected var _duration:int = Time.UNRESOLVED;
		
		protected var _region:SMILRegionElement = null;
		
		protected var _hasSetImplicitMediaDuration:Boolean = false;
		
		protected var _baseResumed:Boolean = false;
		
		protected var _seekingTo:Boolean = false;
		protected var _seekingToTarget:Number = 0;
		
		protected var _frozen:Boolean = false;
		protected var _waitCommitted:Boolean = false;

		public function SMILKitHandler(element:IElement)
		{
			this._element = element;
			this._mediaElement = (element as SMILMediaElement);
			SMILKitHandler.__idCounter++;
			this._handlerId = SMILKitHandler.__idCounter;
			this.resolveInitialLoadableProperties();
		}

		public function get handlerId():int
		{
			return this._handlerId;
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
		
		public function get duration():int
		{
			return this._duration;
		}
		
		public function get width():uint
		{
			return 0;
		}
		
		public function get height():uint
		{
			return 0;
		}
		
		public function get spatial():Boolean
		{
			return false;
		}
		
		public function get temporal():Boolean
		{
			return false;
		}
		
		public function get fileSizeWillResolve():Boolean
		{
			return true;
		}
		
		public function get displayObject():DisplayObject
		{
			return null;
		}
		
		public function get innerDisplayObject():DisplayObject
		{
			return null;
		}
		
		public function get resolvable():Boolean
		{
			return false;
		}
		
		public function get seekable():Boolean
		{
			return false;
		}
		
		public function get cuePoints():Vector.<int>
		{
			return new Vector.<int>();
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
		
		/**
		 * The tolerance to use when finding the nearest sync point in milliseconds.
		 */
		protected function get syncTolerance():Number
		{
			return 10,000;
		}
		
		public function get viewportObjectPool():ViewportObjectPool
		{
			if (this.element != null)
			{
				var document:SMILDocument = (this.element.ownerDocument as SMILDocument)
				
				if (document != null)
				{
					return document.viewportObjectPool;
				}
			}
				
			return null;
		}
		
		public function get bitmapSnapshot():BitmapData
		{
			var bitmapData:BitmapData = new BitmapData(this.innerDisplayObject.width, this.innerDisplayObject.height, true, 0x000000);
			var matrix:Matrix = new Matrix();
			
			if (this.displayObject != null)
			{
				try
				{
					bitmapData.draw(this.displayObject, matrix);
				}
				catch (e:SecurityError)
				{
					SMILKit.logger.error("Unable to read byte data on Handler, crossdomain.xml missing from content source?");
				}
			}
			
			return bitmapData;
		}
		
		public function get region():SMILRegionElement
		{
			return this._region;
		}
		
		public function get resumed():Boolean
		{
			return this._baseResumed;
		}
		
		public function get seekingTo():Boolean
		{
			return this._seekingTo;
		}
		
		public function get seekingToTarget():Number
		{
			return this._seekingToTarget;
		}
		
		public function load():void
		{
			
		}

		public function wait(handlers:Vector.<SMILKitHandler>):void
		{
			if (this.resumed)
			{
				this.pause();
			}
			this._waitCommitted = true;
		}
		
		public function unwait():void
		{
			if (this.resumed && this._waitCommitted)
			{
				this.resume();
			}
			this._waitCommitted = false;
		}
		
		protected function resolveInitialLoadableProperties():void
		{
			if(this._mediaElement != null)
			{
				if(this.fileSizeWillResolve)
				{
					var sizeParam:String = this._mediaElement.getParam("filesize");
					if(sizeParam)
					{
						var sizeVal:int = parseInt(sizeParam);
						if(isNaN(sizeVal))
						{
							SMILKit.logger.debug("Ignoring hinted size "+sizeParam+" as it appears to be invalid", this);
							this._mediaElement.intrinsicBytesLoaded = FileSize.UNRESOLVED;
						}
						else
						{
							SMILKit.logger.debug("Caught hinted intrinsic size "+sizeVal+", passing to element as intrinsic value", this);
							this._mediaElement.intrinsicBytesTotal = sizeVal;
						}
					}
					else
					{
						this._mediaElement.intrinsicBytesLoaded = FileSize.UNRESOLVED;
					}
				}
				else
				{
					this._mediaElement.intrinsicBytesTotal = FileSize.UNRESOLVED;
					this._mediaElement.intrinsicBytesLoaded = FileSize.UNRESOLVED;
				}
			}
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
			this._baseResumed = false;
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
			this._baseResumed = true;
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
		 * @throws flash.errors.IllegalOperationError
		 * 
		 * @see org.smilkit.event.HandlerEvent.SEEK_NOTIFY
		 * @see org.smilkit.event.HandlerEvent.SEEK_INVALIDTIME
		 * @see org.smilkit.event.HandlerEvent.SEEK_FAILED
		 */
		public function seek(target:Number, strict:Boolean):void
		{
			if (!this.seekable)
			{
				throw new IllegalOperationError("Unable to seek on a un-seekable SMILKitHandler.");
			}
			else
			{
				if (strict)
				{
					this.onSeekTo(target);
				}
			}
		}
		
		protected function onSeekTo(target:Number):void
		{
			this._seekingToTarget = target;
			
			this._seekingTo = true;
		}
		
		protected function onSeekToCompleted():void
		{
			this._seekingTo = false;
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_NOTIFY, this));
		}
		
		/**
		 * Finds the nearest sync point on the current handler to the specified offset, uses the handlers
		 * <code>syncTolerance</code> value to determine if a sync point should be choosen before or after
		 * the offset. 
		 */
		public function findNearestCuePoint(offset:Number):Number
		{
			if (this.cuePoints.length > 0)
			{
				var beforeSyncPoint:Number = 0;
				var afterSyncPoint:Number = Number.POSITIVE_INFINITY;
				
				for (var i:int = 0; i < this.cuePoints.length; i++)
				{
					if (this.cuePoints[i] <= offset && this.cuePoints[i] > beforeSyncPoint)
					{
						beforeSyncPoint = this.cuePoints[i];
					}
					else if (this.cuePoints[i] >= offset && this.cuePoints[i] < afterSyncPoint)
					{
						afterSyncPoint = this.cuePoints[i];
					}
				}
				
				// is the before or after point closests?
				var beforeDiff:Number = (offset - beforeSyncPoint);
				var afterDiff:Number = (afterSyncPoint - offset);
				
				if (beforeDiff > this.syncTolerance && (afterDiff < beforeDiff && afterDiff <= this.syncTolerance))
				{
					return afterSyncPoint;
				}
				else
				{
					return beforeSyncPoint;
				}
			}
			
			return offset;
		}
		
		/**
		 * Sets the volume to the specified value, the volume value is treated
		 * from 0-100, 0 being muted and a value of 100 would be full volume.
		 * 
		 * @param volume The integer value to set the volume to, between 0-100.
		 */
		public function setVolume(volume:uint):void
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
			SMILKit.logger.debug("Handler "+this.handlerId+" cancelling load operation.", this)
			
			if(this._mediaElement != null)
			{
				this._mediaElement.intrinsicBytesLoaded = 0;
			}
			
			// cancelling the implicit media duration on the element, would cause
			// the element to be reset and new intervals which might not reflect
			// the state it currently should be in
			/*
			if (this._hasSetImplicitMediaDuration)
			{
				this._mediaElement.implicitMediaDuration = null;
				
				this._hasSetImplicitMediaDuration = false;
			}
			*/
			
			this._completedLoading = false;
			this._startedLoading = false;
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_CANCELLED, this));
		}
		
		/**
		 * Destroys the current handler and all of its children, if any exist.
		 */
		public function destroy():void
		{
			this.cancel();
			
			this._element = null;
			this._region = null;
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
			SMILKit.logger.debug("Handler "+this.handlerId+" moved to just in time worker's worklist", this);
			
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
			SMILKit.logger.debug("Handler "+this.handlerId+" moved to preload worker's worklist", this);
			
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
			SMILKit.logger.debug("Handler "+this.handlerId+" moved to resolve worker's worklist", this);
			
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
			SMILKit.logger.debug("Handler "+this.handlerId+" removed from load scheduler (startedLoading: "+this.startedLoading+", completedLoading: "+this.completedLoading+")", this);			
			if (this.startedLoading && !this.completedLoading)
			{
				this.cancel();
			}
		}
		
		/**
		 * Callback method for when this handler is added to a <code>SMILRegionElement</code> during drawing.
		 */
		public function addedToDrawingRegion(region:SMILRegionElement):void
		{
			SMILKit.logger.debug("Added to display region "+region, this);
			this._region = region;
		}
		
		/**
		 * Callback method for when this handler is removed from a <code>SMILRegionElement</code> during drawing.
		 */
		public function removedFromDrawingRegion(region:SMILRegionElement):void
		{
			SMILKit.logger.debug("Removed from display region "+region, this);
			this._region = null;
		}
		
		/**
		* Callback method for when this handler is added to the <code>RenderTree</code>'s active list.
		*/
		public function addedToRenderTree(r:HandlerController):void
		{
			// override me IF YOU DARE
		}
		
		/**
		* Callback method for when this handler is added to the <code>RenderTree</code>'s active list.
		*/
		public function removedFromRenderTree(r:HandlerController):void
		{
			// override me IF YOU'RE MAN ENOUGH
		}
		
		/**
		 * Triggers the resolved event on the handler, the specified resolvedDuration
		 * is used to update the DOM element assigned to this handler.
		 * 
		 * @param resolvedDuration The resolved duration in milliseconds.
		 */
		protected function resolved(resolvedDuration:int):void
		{
			if (!this._completedResolving || resolvedDuration != this._duration)
			{
				SMILKit.logger.debug("Handler "+this.handlerId+" resolved own intrinsic duration ("+resolvedDuration+")", this);
				
				this._duration = resolvedDuration;
				this._completedResolving = true;
				
				// here we update the dom
				if (this.element != null && (this.element.duration == Time.MEDIA || this.element.duration == 0))
				{
					if (resolvedDuration == Time.INDEFINITE)
					{
						(this.element as SMILMediaElement).implicitMediaDuration = new Time((this.element as ElementTimeContainer), false, "indefinite");
						
						this._hasSetImplicitMediaDuration = true;
					}
					
					else
					{
						(this.element as SMILMediaElement).implicitMediaDuration = new Time((this.element as ElementTimeContainer), false, this._duration.toString() + "ms");
						
						this._hasSetImplicitMediaDuration = true;
					}
				}
				
				this.dispatchEvent(new HandlerEvent(HandlerEvent.DURATION_RESOLVED, this));
			}
		}
		
		protected var _resizeDeferredWithoutRegion:Boolean = false;

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
			if (this.region != null)
			{
				var container:RegionContainer = this.region.regionContainer;
				
				if (container != null)
				{
					var matrix:Rectangle = MathHelper.createMatrixFor(this, container);
					
					if (this.displayObject != null)
					{
						SMILKit.logger.debug("Handler resize calculated. x:"+matrix.x+" y:"+matrix.y+" w:"+matrix.width+" h:"+matrix.height, this);

						this.displayObject.width = matrix.width;
						this.displayObject.height = matrix.height;
						
						this.displayObject.x = matrix.x;
						this.displayObject.y = matrix.y;

						SMILKit.logger.debug("Handler resize executed, result: x:"+this.displayObject.x+" y:"+this.displayObject.y+" w:"+this.displayObject.width+" h:"+this.displayObject.height, this);

						this._resizeDeferredWithoutRegion = false;
					}
				}
			}
			else
			{
				SMILKit.logger.warn("Handler attempted to resize without an attached region", this);
				this._resizeDeferredWithoutRegion = true;
			}
		}
		
		/**
		 * Draw's a click shield over the specified child <code>Sprite</code> and inside the
		 * <code>displayObject</code>, the shield is not automatically drawn and must be called 
		 * when desired by the implementing handler. The shield draws a invisible sprite over
		 * the specified child <code>Sprite</code>, this allows clicks (left and right) to be
		 * caught over media assets that don't usually let you capture the clicks (like videos
		 * and animations). For the shield to draw correctly the <code>displayObject</code>
		 * property on the handler must be a valid sprite that allows children.
		 * 
		 * @param child The child <code>Sprite</code> to draw a click shield over.
		 */
		protected function drawClickShield(child:DisplayObject):void
		{
			if (this._startedLoading && child != null)
			{
				var parent:Sprite = (this.displayObject as Sprite);
				
				if (this._shield == null)
				{
					this._shield = new Sprite();
					this._shield.x = 0;
					this._shield.y = 0;
					
					parent.addChild(this._shield);
				}
				
				if (parent.contains(child) && parent.getChildIndex(child) != -1)
				{
					parent.setChildIndex(child, 0);
					parent.setChildIndex(this._shield, 1);
				}
				
				this._shield.graphics.clear();
				
				this._shield.graphics.beginFill(0x000000, 0.0); // red -> 0xC50000
				this._shield.graphics.drawRect(0, 0, child.width, child.height);
				this._shield.graphics.endFill();
			}
		}
		
		public function get frozen():Boolean
		{
			return this._frozen;
		}
		
		public function enterFrozenState():void
		{
			var parent:Sprite = (this.displayObject as Sprite);
			
			if (this.innerDisplayObject != null && parent.contains(this.innerDisplayObject))
			{
				if (this.frozen)
				{
					SMILKit.logger.debug("Handler "+this.handlerId+" already frozen, re-freezing handler state");
				}
				else
				{
					SMILKit.logger.debug("Handler "+this.handlerId+" entering a into a frozen state");
				}

				this._frozen = true;
				
				parent.graphics.clear();
				
				parent.graphics.beginBitmapFill(this.bitmapSnapshot, new Matrix(), false, true);
				parent.graphics.drawRect(0, 0, this.innerDisplayObject.width, this.innerDisplayObject.height);
				parent.graphics.endFill();
				
				parent.removeChild(this.innerDisplayObject);
			}
		}
		
		public function leaveFrozenState():void
		{
			var parent:Sprite = (this.displayObject as Sprite);
			
			if (this.frozen && this.innerDisplayObject != null && !parent.contains(this.innerDisplayObject))
			{
				SMILKit.logger.debug("Handler "+this.handlerId+" melting and leaving frozen state");

				parent.graphics.clear();
				
				this._frozen = false;
				
				parent.addChild(this.innerDisplayObject);
			}
		}
		
		public override function toString():String
		{
			return super.toString()+"[id: "+this.handlerId+"]";
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