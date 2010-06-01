package org.smilkit.w3c.dom.smil
{
	public interface ISMILRegionElement extends ISMILElement, IElementLayout
	{
		function get backgroundColor():String
		function get backgroundOpacity():String
		
		function get fit():String;
		function set fit(fit:String):void;
		
		function get top():String;
		function set top(top:String):void;
		
		/* added by smilkit */
		function get bottom():String;
		function set bottom(bottom:String):void;
		
		/* added by smilkit */
		function get left():String;
		function set left(left:String):void;
		
		/* added by smilkit */
		function get right():String;
		function set right(right:String):void;
		
		function get zIndex():String;
		function set zIndex(zIndex:String):void;
	}
}