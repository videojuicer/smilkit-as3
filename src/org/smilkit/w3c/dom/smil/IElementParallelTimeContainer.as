package org.smilkit.w3c.dom.smil
{
	public interface IElementParallelTimeContainer extends IElementTimeContainer
	{
		function get endSync():String;
		function set endSync(endSync:String):void;
		
		function get implicitDuration():Number;
	}
}