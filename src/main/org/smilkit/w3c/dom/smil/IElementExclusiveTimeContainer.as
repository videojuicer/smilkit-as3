package org.smilkit.w3c.dom.smil
{
	import org.smilkit.w3c.dom.INodeList;

	public interface IElementExclusiveTimeContainer extends IElementTimeContainer
	{
		function get endSync():String;
		function set endSync(endSync:String):void;
		
		function get pausedElements():INodeList;
	}
}