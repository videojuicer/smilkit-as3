package org.smilkit.dom.smil.display
{
	import flash.events.Event;
	
	import org.smilkit.dom.smil.ElementTimeContainer;
	
	public class DisplayStackEvent extends Event
	{
		public static var ELEMENT_ADDED:String = "displayStackElementAdded";
		public static var ELEMENT_REMOVED:String = "displayStackElementRemoved";

		protected var _element:ElementTimeContainer = null;
		
		public function DisplayStackEvent(type:String, element:ElementTimeContainer, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this._element = element;
		}
		
		public function get element():ElementTimeContainer
		{
			return this._element;
		}
	}
}