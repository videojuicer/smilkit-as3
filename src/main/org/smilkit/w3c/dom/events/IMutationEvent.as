package org.smilkit.w3c.dom.events
{
	import org.smilkit.w3c.dom.INode;

	public interface IMutationEvent extends IEvent
	{
		function get relatedNode():INode;
		function get prevValue():String;
		function get newValue():String;
		function get attrName():String;
		function get attrChange():uint;
		
		function initMutationEvent(type:String, bubbles:Boolean, cancelable:Boolean, relatedNode:INode, prevValue:String, newValue:String, attrName:String, attrChange:uint):void;
	}
}