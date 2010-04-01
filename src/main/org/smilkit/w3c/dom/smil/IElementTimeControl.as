package org.smilkit.w3c.dom.smil
{
	public interface IElementTimeControl
	{
		function beginElement():Boolean;
		function beginElementAt(offset:Number):Boolean;
		function endElement():Boolean;
		function endElementAt(offset:Number):Boolean;
	}
}