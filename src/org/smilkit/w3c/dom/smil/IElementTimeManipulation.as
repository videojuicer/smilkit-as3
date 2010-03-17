package org.smilkit.w3c.dom.smil
{
	public interface IElementTimeManipulation
	{
		function get speed():Number;
		function set speed(speed:Number):void;
		
		function get accelerate():Number;
		function set accelerate(accelerate:Number):void;
		
		function get decelerate():Number;
		function set decelerate(decelerate:Number):void;
		
		function get autoReverse():Boolean;
		function set autoReverse(autoReverse:Boolean):void;
	}
}