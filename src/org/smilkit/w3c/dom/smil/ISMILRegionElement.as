package org.smilkit.w3c.dom.smil
{
	public interface ISMILRegionElement extends ISMILElement, IElementLayout
	{
		function get fit():String;
		function set fit(fit:String):void;
		
		function get top():String;
		function set top(top:String):void;
		
		function get zIndex():String;
		function set zIndex(zIndex:String):void;
	}
}