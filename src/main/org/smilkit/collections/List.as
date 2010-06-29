package org.smilkit.collections
{
	public class List
	{
		protected var _source:Array;
		
		public function List(source:Array = null)
		{
			this._source = source;
			
			if (this._source == null)
			{
				this._source = new Array();
			}
		}
		
		public function get source():Array
		{
			return this._source;
		}
		
		public function set source(source:Array):void
		{
			this._source = source;
		}
		
		public function get length():int
		{
			return (this._source != null) ? this._source.length : 0;
		}
		
		public function getItemAt(index:int):*
		{
			if (index < 0 || index >= this.length)
			{
				// TODO: use a message formatter for exception messages
				//throw new ListException(ListException.OUT_OF_BOUNDS_ERR, "Index '"+index+"' out of bounds on Array");
			}
			
			return this.source[index];
		}
		
		public function setItemAt(item:*, index:int):*
		{
			if (index < 0 || index >= this.length)
			{
				//throw new ListException(ListException.OUT_OF_BOUNDS_ERR, "Index '"+index+"' out of bounds on Array");
			}
			
			var old:Object = this.source[index];
			
			this.source[index] = item;
			
			return old;
		}
		
		public function addItem(item:*):void
		{
			this.addItemAt(item, this.length);
		}
		
		public function addItemAt(item:*, index:int):void
		{
			if (index < 0 || index > this.length) {
				//throw new ListException(ListException.OUT_OF_BOUNDS_ERR, "Index '"+index+"' out of bounds on Array");
			}
			
			this.source.splice(index, 0, item);
		}
		
		public function getItemIndex(item:*):int
		{
			return this.getItemIndexFrom(item, 0);
		}
		
		public function getItemIndexFrom(item:*, start:int):int
		{
			if (start < 0 || start > this.length)
			{
				//throw new ListException(ListException.OUT_OF_BOUNDS_ERR, "Index '"+index+"' out of bounds on Array");
			}
			
			var i:int = 0;
			
			if (this._source != null)
			{
				var first:int = start;
				var last:int = this.length - 1;
				
				while (first <= last)
				{
					i = (first + last) / 2;
					
					var cur:* = this.source[i];
					
					if (cur == item)
					{
						return i;
					}
					else
					{
						first = i + 1;
					}
				}
				
				if (first > i)
				{
					i = first;
				}
			}
			
			return -1 - i;
		}
		
		public function removeItemAt(index:int):*
		{
			if (index < 0 || index >= this.length)
			{
				//throw new ListException(ListException.OUT_OF_BOUNDS_ERR, "Index '"+index+"' out of bounds on Array");
			}
			
			var old:* = this.source.splice(index, 1)[0];
			
			return old;
		}
		
		public function removeAll():void
		{
			if (this.length > 0)
			{
				this.source.splice(0, this.length);
			}
		}
	}
}