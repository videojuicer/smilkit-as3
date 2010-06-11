package org.smilkit.dom.smil
{
	import org.smilkit.collections.List;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.smil.ITime;
	import org.smilkit.w3c.dom.smil.ITimeList;
	
	public class TimeList implements ITimeList
	{
		protected var _times:Vector.<ITime>;
		protected var _timesResolved:int = 0;
		
		public function TimeList()
		{
			this._times = new Vector.<ITime>();
		}
		
		public function get length():int
		{
			return (this._times != null ? this._times.length : 0);
		}
		
		public function get last():ITime
		{
			if (this.length > 0)
			{
				return this.item(this.length);
			}
			
			return null;
		}
		
		public function get first():ITime
		{
			if (this.length > 0)
			{
				return this.item(0);
			}
			
			return null;
		}
		
		public function add(time:ITime):void
		{
			this.addAt(time, this._times.length);
		}
		
		public function addAt(time:ITime, index:int):void
		{
			this._times[index] = time;
		}
		
		public function item(index:int):ITime
		{
			return (this._times != null && index < this._times.length ? (this._times[index]) : null);
		}
		
		public function get resolved():Boolean
		{
			return (this._timesResolved == this.length);
		}
		
		// TODO: update with a cache so we dont need to loop every time ...
		public function resolve():Boolean
		{
			var count:int = this._timesResolved;
			
			for (var i:int = 0; i < this.length; i++)
			{
				var time:Time = (this.item(i) as Time);
				
				if (!time.resolved)
				{
					time.resolve();
					
					if (time.resolved)
					{
						this._timesResolved++;
					}
				}
			}
			
			return (count < this._timesResolved);
		}
	}
}