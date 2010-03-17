package org.smilkit.w3c.dom.smil
{
	import org.smilkit.w3c.dom.views.IAbstractView;

	public interface ITimeEvent
	{
		function get view():IAbstractView;
		function get detail():int;
		
		function initTimeEvent(typeArg:String, viewArg:IAbstractView, detailArg:int):void;
	}
}