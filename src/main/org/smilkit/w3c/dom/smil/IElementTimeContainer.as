package org.smilkit.w3c.dom.smil
{
	import org.smilkit.w3c.dom.INodeList;

	public interface IElementTimeContainer extends IElementTime
	{
		function get timeChildren():INodeList;
		
		function get durationResolved():Boolean;
		function activeChildrenAt(instant:Number):INodeList;
	}
}