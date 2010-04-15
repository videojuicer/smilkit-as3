package org.smilkit.dom
{
	import org.smilkit.w3c.dom.IAttr;

	internal class EnclosingAttr
	{
		protected var _node:IAttr;
		protected var _oldValue:String;
		
		public function get node():IAttr
		{
			return this._node;
		}
		
		public function set node(value:IAttr):void
		{
			this._node = value;
		}
		
		public function get oldValue():String
		{
			return this._oldValue;
		}
		
		public function set oldValue(value:String):void
		{
			this._oldValue = value;
		}
	}
}