package org.osmf.smil.model
{
	import org.utilkit.util.BooleanHelper;

	public class SMILAttribute
	{
		public function SMILAttribute()
		{
			
		}
		
		public function get name():String
		{
			return this._name;
		}
		
		public function set name(value:String):void
		{
			this._name = value;
		}
		
		public function get value():String
		{
			return this._value;
		}
		
		public function set value(value:String):void
		{
			this._value = value;
		}
		
		public function get valueAsBoolean():Boolean
		{
			return BooleanHelper.stringToBoolean(this.value);
		}
		
		public function get valueAsNumber():Number
		{
			return parseFloat(this.value);
		}
		
		private var _name:String;
		private var _value:String;
	}
}