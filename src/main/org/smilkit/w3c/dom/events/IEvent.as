package org.smilkit.w3c.dom.events
{
	import flash.events.Event;

	public interface IEvent
	{
		function get type():String;
		function get target():Object;
		function get currentTarget():Object;
		function get eventPhase():uint;
		function get bubbles():Boolean;
		function get cancelable():Boolean;
		function get stopPropagationEvent():Boolean;
		function get preventDefaultEvent():Boolean;
		function get timestamp():int;
		
		function stopPropagation():void;
		function preventDefault():void;
		function initEvent(type:String, bubbles:Boolean, cancelable:Boolean):void;
	}
}