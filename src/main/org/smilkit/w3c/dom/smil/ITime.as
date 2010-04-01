package org.smilkit.w3c.dom.smil
{
	import org.smilkit.w3c.dom.IElement;

	public interface ITime
	{
		function get resolved():Boolean;

		function get resolvedOffset():Number;
		
		function get timeType():uint;

		function get offset():Number;
		function set offset(offset:Number):void;
		
		function get baseElement():IElement;
		function set baseElement(baseElement:IElement):void;
		
		function get baseBegin():Boolean;
		function set baseBegin(baseBegin:Boolean):void;
		
		function get event():String;
		function set event(event:String):void;
		
		function get marker():String;
		function set marker(marker:String):void;
	}
}