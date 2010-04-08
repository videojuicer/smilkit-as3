package org.smilkit.util
{
	import org.hamcrest.mxml.collection.Array;

	public class KeyPairHashMap extends HashMap
	{
		protected var _keys:HashMap = new HashMap();
		
		public function KeyPairHashMap()
		{
			super(null);
		}
		
		public function getItem(key:Object):Object
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
		
		public function getNamedIndex(key:Object):int
		{
			if (this.hasItem(key))
			{
				for (var i:int = this._keys.length; i > 0; i--)
				{
					if (key == this._keys[i])
					{
						return i;
					}
				}
			}
			
			return -1;
		}
		
		public function setItem(key:Object, value:Object):void
		{
			var i:int = this.getNamedIndex(key);
			
			if (i == -1)
			{
				var n:int = this.length+1;
				
				this._keys[n] = key;
				this.setItemAt(value, n);
			}
			else
			{
				this.setItemAt(value, i);
			}
		}
		
		public function removeItem(key:Object):void
		{
			var i:int = this.getNamedIndex(key);
			
			if (i != -1)
			{
				this._keys.removeItemAt(i);
				this.removeItemAt(i);
			}
		}
		
		public function hasItem(key:Object):Boolean
		{
			for (var i:int = this._keys.length; i > 0; i--)
			{
				if (key == this._keys[i])
				{
					return true;
				}
			}
			
			return false;
		}
	}
}