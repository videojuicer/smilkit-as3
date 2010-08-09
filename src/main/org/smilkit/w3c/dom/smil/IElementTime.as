package org.smilkit.w3c.dom.smil
{
	public interface IElementTime
	{
		function get begin():ITimeList;
		function set begin(begin:ITimeList):void;
		
		function get end():ITimeList;
		function set end(end:ITimeList):void;
		
		function get dur():String;
		function set dur(dur:String):void;
		
		function get duration():Number;
		
		function get restart():uint;
		function set restart(restart:uint):void;
		
		function get fill():uint;
		function set fill(fill:uint):void;
		
		function get repeatCount():Number;
		function set repeatCount(repeatCount:Number):void;
		
		function get repeatDur():Number;
		function set repeatDur(repeatDur:Number):void;
		
		function beginElement():Boolean;
		
		function endElement():Boolean;
		
		function pauseElement():void;
		
		function resumeElement():void;
		
		function seekElement(seekTo:Number):void;
	}
}