package org.smilkit.dom.events
{
	import org.smilkit.w3c.dom.events.IEvent;
	import org.smilkit.w3c.dom.events.IEventListener;
	
	public class EventListener implements IEventListener
	{
		protected var _callback:Function = null;
		
		public function EventListener(callback:Function)
		{
			this._callback = callback;
		}
		
		public function get callback():Function
		{
			return this._callback;
		}
		
		public function handleEvent(event:IEvent):void
		{
			if (this.callback != null)
			{
				this._callback.call(event);
			}
		}
	}
}