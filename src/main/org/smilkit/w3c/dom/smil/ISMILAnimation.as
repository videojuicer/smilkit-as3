package org.smilkit.w3c.dom.smil
{
	public interface ISMILAnimation extends ISMILElement, IElementTargetAttributes, IElementTime, IElementTimeControl
	{
		function get additive():int;
		function set additive(additive:int):void;
		
		function get accumulate():int;
		function set accumulate(accumulate:int):void;
		
		function get calcMode():int;
		function set calcMode(calcMode:int):void;
		
		function get keySplines():String;
		function set keySplines(keySplines:String):void;
		
		function get keyTimes():ITimeList;
		function set keyTimes(keyTimes:ITimeList):void;
		
		function get values():String;
		function set values(values:String):void;
		
		function get from():String;
		function set from(from:String):void;
		
		function get to():String;
		function set to(to:String):void;
		
		function get by():String;
		function set by(by:String):void;
	}
}