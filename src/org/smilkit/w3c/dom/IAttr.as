package org.smilkit.w3c.dom
{
	public interface IAttr extends INode
	{
		function get name():String;
		function get specified():Boolean;
		function get value():String;
		function set value(value:String):void;
		function get ownerElement():IElement;
	}
}