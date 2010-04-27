package org.smilkit.dom.smil
{
	import org.osmf.events.TimeEvent;
	import org.smilkit.dom.events.EventListener;
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
		protected var _baseElement:IElement = null;
		protected var _baseBegin:Boolean = false;
		protected var _offset:Number = 0;
		protected var _resolvedOffset:Number = 0;
		protected var _event:String;
		protected var _marker:String;
		protected var _type:int = Time.SMIL_TIME_SYNC_BASED;
		
		public static var SMIL_TIME_INDEFINITE:int = 0;
		public static var SMIL_TIME_OFFSET:int = 1;
		public static var SMIL_TIME_SYNC_BASED:int = 2;
		public static var SMIL_TIME_EVENT_BASED:int = 3;
		public static var SMIL_TIME_WALLCLOCK:int = 4;
		public static var SMIL_TIME_MEDIA_MARKER:int = 5;
		
		public function Time(type:int)
		{
			this._type = type;
		}
		
		public function resolve():void
		{
			// resolve the time
			switch (this.timeType)
			{
				case Time.SMIL_TIME_SYNC_BASED:
					this._offset = (this._baseElement.parentNode as IElementTime).begin.item(0).offset;
					
					var parent:IElement = null;
					var element:IElement = this._baseElement;
					
					while (parent == null)
					{
						if (element.parentNode != null && element.parentNode is IElementTimeContainer)
						{
							parent = (element.parentNode as IElement);
							break;
						}
					}
					
					if (parent is IElementSequentialTimeContainer)
					{
						// add up the duration of previous children
						var children:INodeList = parent.childNodes;
						var previousDuration:Number = 0;
						
						for (var i:int = 0; i < children.length; i++)
						{
							var child:INode = children.item(i);
							
							if (child == this._baseElement)
							{
								break;
							}
							
							if ((child as IElementTime).end.item(0).resolved)
							{
								previousDuration += (child as IElementTime).end.item(0).resolvedOffset;
							}
							else
							{
								this._resolved = false;
								
								return;
							}
						}
						
						if (this.baseBegin)
						{
							this._resolved = true;
							this._resolvedOffset = previousDuration;
						}
						else
						{
							var dur:Number = (this._baseElement as ISMILMediaElement).dur;
							
							this._resolved = true;
							this._resolvedOffset = previousDuration + dur;
						}
					}
					else if (parent is IElementParallelTimeContainer)
					{
						if ((parent as IElementParallelTimeContainer).begin.item(0).resolved)
						{
							if (this.baseBegin)
							{
								var beginTime:ITime = (parent as IElementParallelTimeContainer).begin.item(0);
								
								if (beginTime.resolved)
								{
									this._resolvedOffset = beginTime.resolvedOffset;
									this._resolved = true;
								}
								else
								{
									this._resolved = false;
								}
							}
							else
							{
								var endTime:ITime = (parent as IElementParallelTimeContainer).end.item(0);
								
								if (endTime.resolved)
								{
									this._resolvedOffset = endTime.resolvedOffset;
									this._resolved = true;
								}
								else
								{
									this._resolved = false;
								}
							}
						}
					}
					
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
							eventElement.addEventListener(eventType, new EventListener(this.onEventOccurred), false);
						}
					}
					break;
				case Time.SMIL_TIME_OFFSET:
					break;
				case Time.SMIL_TIME_MEDIA_MARKER:
					break;
				case Time.SMIL_TIME_INDEFINITE:
					//this._resolvedOffset = Number.POSITIVE_INFINITY;
					break;
				case Time.SMIL_TIME_WALLCLOCK:
					break;
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
		 * The clock value in miliseconds relative to the syncbase or event base.
		 */
		public function get offset():Number
		{
			return this._offset;
		}
		
		public function set offset(offset:Number):void
		{
			this._offset = offset;
		}
		
		public function get baseElement():IElement
		{
			return this._baseElement;
		}
		
		public function set baseElement(baseElement:IElement):void
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