package org.smilkit.dom.events
{
	import flash.events.Event;
	
	import org.smilkit.w3c.dom.events.IEvent;
	import org.smilkit.w3c.dom.events.IEventTarget;

	public class DOMEvent extends Event implements IEvent
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
		
		public function DOMEvent()
		{
			super("domEvent");
		}
		
		public override function get type():String
		{
			return this._type;
		}
		
		public override function get target():Object
		{
			return this._target;
		}
		
		public function set target(value:Object):void
		{
			this._target = (value as IEventTarget);
		}
		
		public override function get currentTarget():Object
		{
			return this._currentTarget;
		}
		
		public function set currentTarget(value:Object):void
		{
			this._currentTarget = (value as IEventTarget);
		}
		
		public override function get eventPhase():uint
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
		
		public override function get bubbles():Boolean
		{
			return this._bubbles;
		}
		
		public override function get cancelable():Boolean
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
		
		public override function stopPropagation():void
		{
			this._stopPropagation = true;
		}
		
		public override function preventDefault():void
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