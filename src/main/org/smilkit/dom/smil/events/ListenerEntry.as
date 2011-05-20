package org.smilkit.dom.smil.events
{
	public class ListenerEntry
	{
		private var _type:String;
		private var _listener:Function;
		private var _useCapture:Boolean;
			
		public function ListenerEntry(type:String, listener:Function, useCapture:Boolean)
		{
			this._type = type;
			this._listener = listener;
			this._useCapture = useCapture;
		}
		
		public function get type():String
		{
			return this._type;
		}
		
		public function get listener():Function
		{
			return this._listener;
		}
		
		public function get useCapture():Boolean
		{
			return this._useCapture;
		}
	}
}