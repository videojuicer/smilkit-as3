package org.smilkit.dom.smil
{
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.util.logger.Logger;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.events.IEvent;
	import org.smilkit.w3c.dom.smil.IElementParallelTimeContainer;
	import org.smilkit.w3c.dom.smil.IElementSequentialTimeContainer;
	import org.smilkit.w3c.dom.smil.IElementTime;
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.smilkit.w3c.dom.smil.ITime;
	
	public class Time implements ITime
	{
		protected var _resolved:Boolean = false;
		protected var _baseElement:INode = null;
		protected var _baseBegin:Boolean = false;
		protected var _offset:Number = 0;
		protected var _resolvedOffset:Number = 0; //Time.UNRESOLVED;
		protected var _event:String;
		protected var _marker:String;
		protected var _type:int = Time.SMIL_TIME_SYNC_BASED;
		
		/** NON-DOM:
		* Determines whether this time should be considered resolved if the baseElement contains no duration attribute. This flag is used to 
		* prevent the timing model from marking temporal media elements such as video, audio etc. as having a resolved duration of zero if the 
		* handler has not yet resolved or if no duration is provided in the document. The default behaviour is to resolve all end times as zero
		* if their baseElement has no content or duration.
		*/
		protected var _resolveWithoutDuration:Boolean = true;
		
		/** NON-DOM:
		* A flag used for caching purposes - each Time is processed only once during a single walk of the DOM. If <code>_validCache</code> is true, then
		* <code>resolve()</code> will skip work and the already-processed values will be used. Call <code>invalidate()</code> to reset this variable and ensure that
		* the next <code>resolve()</code> call fetches up-to-date values.
		*
		* @see org.smilkit.dom.smil.Time.invalidate
		*/
		protected var _validCache:Boolean = false;
		
		public static var SMIL_TIME_INDEFINITE:int = 0;
		public static var SMIL_TIME_OFFSET:int = 1;
		public static var SMIL_TIME_SYNC_BASED:int = 2;
		public static var SMIL_TIME_EVENT_BASED:int = 3;
		public static var SMIL_TIME_WALLCLOCK:int = 4;
		public static var SMIL_TIME_MEDIA_MARKER:int = 5;
		
		public static var INDEFINITE:int = -100;
		public static var UNRESOLVED:int = -101;
		
		public function Time(type:int)
		{
			this._type = type;
		}
		
		/** NON-DOM:
		* Invalidates any cached values on this <code>Time</code> object and ensures that the next call to <code>resolve()</code> refreshes the values on this object.
		*/
		public function invalidate():void
		{
			this._validCache = false;
		}
		
		public function get validCache():Boolean
		{
			return this._validCache;
		}
		
		public function resolve(force:Boolean=false):void
		{
			if(this._validCache && !force)
			{
				// Skip resolve as we have a valid cache and are not being told to force-reset the operation.
				return;
			}

			// If this time represents the end of a SMILMediaElement, ElementSequentialTimeContainer or ElementParallelTimeContainer 
			// then we will set the _resolveWithoutDuration flag to FALSE, causing the end time to remain unresolved until the
			// node's duration is resolved. In the case of SMILMediaElements, _resolveWithoutDuration is only set to false if the 
			// element's handler is temporal in nature.
			if(!this.baseBegin)
			{
				if(this.baseElement is SMILMediaElement)
				{
					var baseMediaElement:SMILMediaElement = (this.baseElement as SMILMediaElement);
					var baseMediaElementHandler:SMILKitHandler = baseMediaElement.handler;
					if(baseMediaElementHandler != null && baseMediaElementHandler.temporal == true)
					{
						this._resolveWithoutDuration = false;
					}
				}
				else if(this.baseElement is ElementSequentialTimeContainer || this.baseElement is ElementParallelTimeContainer)
				{
					this._resolveWithoutDuration = false;
				}
			}
			
			this._type = ElementTime.timeAttributeToTimeType(Time.INDEFINITE.toString(), (this.baseElement as ElementTimeContainer), this.baseBegin);
			
			// resolve the time
			switch (this.timeType)
			{
				case Time.SMIL_TIME_SYNC_BASED:
					this.resolveSyncBased();
					break;
				case Time.SMIL_TIME_EVENT_BASED:
					var pieces:Array = this.event.split(".");
					
					if (pieces.length > 0)
					{
						var elementId:String = pieces[0];
						var eventType:String = pieces[1];
						
						var eventElement:IElement = this.baseElement.ownerDocument.getElementById(elementId);
						
						if (eventElement != null)
						{
							eventElement.addEventListener(eventType, this.onEventOccurred, false);
						}
					}
					break;
				case Time.SMIL_TIME_OFFSET:
					break;
				case Time.SMIL_TIME_MEDIA_MARKER:
					break;
				case Time.SMIL_TIME_INDEFINITE:
					this._resolvedOffset = Time.INDEFINITE;
					this._resolved = true;
					break;
				case Time.SMIL_TIME_WALLCLOCK:
					break;
			}
			
			this._validCache = true;
		}
		
		private function resolveSyncBased():void
		{
			var parent:IElementTimeContainer = null;
			var element:INode = this._baseElement;
			
			while (parent == null)
			{
				if (element.parentNode != null && element.parentNode is IElementTimeContainer)
				{
					parent = (element.parentNode as IElementTimeContainer);
					break;
				}
			}
			
			this._offset = parent.begin.item(0).offset;
			
			if (parent is IElementSequentialTimeContainer)
			{
				//Logger.debug("About to resolve times in a sequential syncbase for element with tagName: "+element.nodeName, this);
				this.resolveSequentialSyncBased(parent as IElementSequentialTimeContainer);
			}
			else if (parent is IElementParallelTimeContainer)
			{
				//Logger.debug("About to resolve times in a parallel syncbase for element with tagName: "+element.nodeName, this);
				this.resolveParallelSyncBased(parent as IElementParallelTimeContainer);
			}
		}
		
		private function resolveParallelSyncBased(parent:IElementParallelTimeContainer):void
		{
			var parentBeginList:TimeList = ((parent as IElementParallelTimeContainer).begin as TimeList);
			
			parentBeginList.resolve();
			
			if (parentBeginList.resolved)
			{
				if (this.baseBegin)
				{
				    // BEGIN time for a tag within a parallel container
				
					var beginTime:ITime = (parent as IElementParallelTimeContainer).begin.first;
				   // TODO take into account begin attribute on baseElement
					this._resolvedOffset = beginTime.resolvedOffset;
					this._resolved = beginTime.resolved;
					
					//Logger.debug("BEGIN time for a "+this._baseElement.nodeName+" tag in a parallel sync block. "+this._resolvedOffset+" ("+(this._resolved ? "resolved" : "unresolved")+")", this);
				}
				else
				{
				    // END time for a tag within a parallel container
				
					var timeContainer:IElementTimeContainer = (this._baseElement as IElementTimeContainer);
    
				    var begin:ITime = timeContainer.begin.first;
				   // TODO take into account begin attribute on baseElement
					this._resolvedOffset = begin.resolvedOffset + timeContainer.duration;					
					this._resolved = (begin.resolved && (timeContainer.durationResolved || this._resolveWithoutDuration));
					
					//Logger.debug("END time for a "+this._baseElement.nodeName+" tag in a parallel sync block. "+this._resolvedOffset+" ("+(this._resolved ? "resolved" : "unresolved")+")", this);
				}
			}
		}
		
		private function resolveSequentialSyncBased(parent:IElementSequentialTimeContainer):void
		{
			// add up the duration of previous siblings
			var siblings:INodeList = (parent as INode).childNodes;
			var previousDuration:Number = 0;
			var previousSiblingEndTimesResolved:Boolean = true;
			
			for (var i:int = 0; i < siblings.length; i++)
			{
				var sibling:INode = siblings.item(i);
				
				if (sibling == this._baseElement)
				{
				    // Exit the loop when we hit this Time's baseElement
					break;
				}
				
				var timeContainer:IElementTimeContainer = (sibling as IElementTimeContainer);
				
				(timeContainer.end as TimeList).resolve();
				
				if (timeContainer.end.first.resolved)
				{
					previousDuration += (sibling as IElementTime).end.first.resolvedOffset;
				}
				else
				{
					previousSiblingEndTimesResolved = false;
				}
			}
			
			if (this.baseBegin)
			{
			    // BEGIN time for a tag within a sequential container
			
				this._resolved = previousSiblingEndTimesResolved;
				// TODO account for begin offset
				this._resolvedOffset = previousDuration;
				
				//Logger.debug("BEGIN time for a "+this._baseElement.nodeName+" tag in a sequential sync block. "+this._resolvedOffset+" ("+(this._resolved ? "resolved" : "unresolved")+")", this);
			}
			else
			{
			    // END time for a tag within a sequential container
			
			    var baseElementTimeContainer:IElementTimeContainer = (this._baseElement as IElementTimeContainer);
				var dur:Number = baseElementTimeContainer.duration;
				this._resolvedOffset = previousDuration + dur;
				
				if (previousSiblingEndTimesResolved && (baseElementTimeContainer.durationResolved || this._resolveWithoutDuration))
				{
					//Logger.debug("Break: "+previousSiblingEndTimesResolved+" "+baseElementTimeContainer.durationResolved+" "+this._resolveWithoutDuration, this);
					
				    this._resolved = true;
				}
				
				//Logger.debug("END time for a "+this._baseElement.nodeName+" tag in a sequential sync block. "+this._resolvedOffset+" ("+(this._resolved ? "resolved" : "unresolved")+")", this);
			}
		}
		
		protected function onEventOccurred(e:IEvent):void
		{
			this._resolvedOffset = e.timestamp;
			this._resolved = true;
		}
		
		public function get resolved():Boolean
		{
			return this._resolved;
		}
		
		public function get resolvedOffset():Number
		{
			return this._resolvedOffset;
		}
		
		public function get timeType():uint
		{
			return this._type;
		}
		
		/**
		 * The clock value in milliseconds relative to the syncbase or event base.
		 */
		public function get offset():Number
		{
			return this._offset;
		}
		
		public function set offset(offset:Number):void
		{
			this._offset = offset;
		}
		
		public function get baseElement():INode
		{
			return this._baseElement;
		}
		
		public function set baseElement(baseElement:INode):void
		{
			this._baseElement = baseElement;
		}
		
		public function get baseBegin():Boolean
		{
			return this._baseBegin;
		}
		
		public function set baseBegin(baseBegin:Boolean):void
		{
			this._baseBegin = baseBegin;
		}
		
		public function get event():String
		{
			return this._event;
		}

		public function set event(event:String):void
		{
			this._event = event;
		}
		
		public function get marker():String
		{
			return this._marker;
		}
		
		/**
		 * 
		 * @throws org.smilkit.w3c.dom.DOMException
		 */
		public function set marker(marker:String):void
		{
			this._marker = marker;
		}
	}
}