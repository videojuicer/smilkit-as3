package org.smilkit.dom.smil
{
	import org.utilkit.collection.Hashtable;

	public class SMILEventStack
	{
		public static var SMILELEMENT_BEGIN:String = "beginEvent";
		public static var SMILELEMENT_END:String = "endEvent";
		public static var SMILELEMENT_REPEAT:String = "repeatEvent";
		
		protected var _document:SMILDocument = null;
		protected var _triggeredStack:Hashtable = null;
		
		public function SMILEventStack(document:SMILDocument)
		{
			this._document = document;
			
			this.clear();
		}
		
		public function triggerEvent(element:SMILElement, eventName:String):void
		{
			var events:Hashtable = new Hashtable();
			
			if (this._triggeredStack.hasItem(element))
			{
				events = this._triggeredStack.getItem(element);
			}
			
			events.setItem(eventName, this._document.offset);
			
			this._triggeredStack.setItem(element, events);
		}
		
		public function hasEventTriggered(element:SMILElement, eventName:String):Boolean
		{
			if (this._triggeredStack.hasItem(element))
			{
				var events:Hashtable = this._triggeredStack.getItem(element);
				
				if (events.hasItem(eventName))
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function getTriggeredOffset(element:SMILElement, eventName:String):Number
		{
			if (this._triggeredStack.hasItem(element))
			{
				var events:Hashtable = this._triggeredStack.getItem(element);
				
				if (events.hasItem(eventName))
				{
					return events.getItem(eventName);
				}
			}
			
			return 0;
		}
		
		public function clear():void
		{
			this._triggeredStack = new Hashtable();
		}
	}
}