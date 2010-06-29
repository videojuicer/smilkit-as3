package org.smilkit.w3c.dom.events
{
	import flash.events.Event;

	public interface IEventTarget
	{
		function addEventListener(type:String, listener:Function, useCapture:Boolean):void;
		function removeEventListener(type:String, listener:Function, useCapture:Boolean):void;
		function dispatchEvent(event:IEvent):Boolean;
	}
}