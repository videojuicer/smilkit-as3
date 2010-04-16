package org.smilkit.dom.events
{
	import org.smilkit.w3c.dom.events.IEvent;
	import org.smilkit.w3c.dom.events.IEventTarget;

	public class Event implements IEvent
	{
		public static var CAPTURING_PHASE:uint = 0;
		public static var AT_TARGET:uint = 1;
		public static var BUBBLING_PHASE:uint = 2;
		public static var DEFAULT_PHASE:uint = 3;
		
		protected var _type:String = null;
		protected var _target:IEventTarget;
		protected var _currentTarget:IEventTarget;
		protected var _eventPhase:uint;
		protected var _initialized:Boolean = false;
		protected var _bubbles:Boolean = true;
		protected var _cancelable:Boolean = false;
		protected var _stopPropagation:Boolean = false;
		protected var _preventDefault:Boolean = false;
		
		protected var _timestamp:int = Date.length;
		
		public function Event()
		{
			
		}
		
		public function get type():String
		{
			return this._type;
		}
		
		public function get target():IEventTarget
		{
			return this._target;
		}
		
		public function set target(value:IEventTarget):void
		{
			this._target = value;
		}
		
		public function get currentTarget():IEventTarget
		{
			return this._currentTarget;
		}
		
		public function set currentTarget(value:IEventTarget):void
		{
			this._currentTarget = value;
		}
		
		public function get eventPhase():uint
		{
			return this._eventPhase;
		}
		
		public function set eventPhase(value:uint):void
		{
			this._eventPhase = value;
		}
		
		public function get initialized():Boolean
		{
			return this._initialized;
		}
		
		public function get bubbles():Boolean
		{
			return this._bubbles;
		}
		
		public function get cancelable():Boolean
		{
			return this._cancelable;
		}
		
		public function get stopPropagationEvent():Boolean
		{
			return this._stopPropagation;
		}
		
		public function set stopPropagationEvent(value:Boolean):void
		{
			this._stopPropagation = value;
		}
		
		public function get preventDefaultEvent():Boolean
		{
			return this._preventDefault;
		}
		
		public function set preventDefaultEvent(value:Boolean):void
		{
			this._preventDefault = value;
		}
		
		public function get timestamp():int
		{
			return this._timestamp;
		}
		
		public function stopPropagation():void
		{
			this._stopPropagation = true;
		}
		
		public function preventDefault():void
		{
			this._preventDefault = true;
		}
		
		public function initEvent(type:String, bubbles:Boolean, cancelable:Boolean):void
		{
			this._type = type;
			this._bubbles = bubbles;
			this._cancelable = cancelable;
			
			this._initialized = true;
		}
	}
}