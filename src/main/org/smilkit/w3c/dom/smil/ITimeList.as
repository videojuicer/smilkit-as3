package org.smilkit.w3c.dom.smil
{
	public interface ITimeList
	{
		/** added by SMILKit **/
		function get last():ITime;
		function get first():ITime;
		
		function get length():int;
		
		function item(index:int):ITime;
	}
}