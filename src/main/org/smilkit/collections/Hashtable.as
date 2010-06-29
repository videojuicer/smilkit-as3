package org.smilkit.collections
{

	public class Hashtable extends List
	{
		protected var _keys:List = new List();
		
		public function Hashtable()
		{
			super(null);
		}
		
		public function get isEmpty():Boolean
		{
			return (this._keys.length == 0);
		}
		
		public function getItem(key:*):*
		{
			var i:int = this.getNamedIndex(key);
			
			if (i == -1)
			{
				return null;
			}
			else
			{
				return this.getItemAt(i);
			}
		}
		
		public function getKeyAt(index:int):*
		{
			if (index > this.length || index < 0)
			{
				return null;
			}
			
			return this._keys.getItemAt(index);
		}
		
		public function getNamedIndex(key:*):int
		{
			if (this.hasItem(key))
			{
				for (var i:int = this._keys.length; i >= 0; i--)
				{
					if (key == this._keys.getItemAt(i))
					{
						return i;
					}
				}
			}
			
			return -1;
		}
		
		public function setItem(key:*, value:*):void
		{
			var i:int = this.getNamedIndex(key);
			
			if (i == -1)
			{
				var n:int = this.length;
				
				this._keys.setItemAt(key, n);
				this.setItemAt(value, n);
			}
			else
			{
				this.setItemAt(value, i);
			}
		}
		
		public function removeItem(key:*):void
		{
			var i:int = this.getNamedIndex(key);
			
			if (i != -1)
			{
				this._keys.removeItemAt(i);
				this.removeItemAt(i);
			}
		}
		
		public function hasItem(key:*):Boolean
		{
			for (var i:int = this._keys.length; i >= 0; i--)
			{
				var newKey:* = this._keys.getItemAt(i);
				
				if (key == newKey)
				{
					return true;
				}
			}
			
			return false;
		}
	}
}