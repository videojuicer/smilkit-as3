package org.smilkit.collections
{
	import org.smilkit.w3c.dom.events.IEventListener;

	public class ListenerEntry
	{
		private var _type:String;
		private var _listener:IEventListener;
		private var _useCapture:Boolean;
			
		public function ListenerEntry(type:String, listener:IEventListener, useCapture:Boolean)
		{
			this._type = type;
			this._listener = listener;
			this._useCapture = useCapture;
		}
		
		public function get type():String
		{
			return this._type;
		}
		
		public function get listener():IEventListener
		{
			return this._listener;
		}
		
		public function get useCapture():Boolean
		{
			return this._useCapture;
		}
	}
}