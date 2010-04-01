package org.smilkit.w3c.dom.smil
{
	public interface ISMILSetElement extends IElementTimeControl, IElementTime, IElementTargetAttributes, ISMILElement
	{
		function get to():String;
		function set to(to:String):void;
	}
}