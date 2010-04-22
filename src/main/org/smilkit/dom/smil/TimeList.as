package org.smilkit.dom.smil
{
	import org.smilkit.collections.List;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.smil.ITime;
	import org.smilkit.w3c.dom.smil.ITimeList;
	
	public class TimeList implements ITimeList
	{
		protected var _times:Vector.<ITime>;
		
		public function TimeList()
		{
			this._times = new Vector.<ITime>();
		}
		
		public function get length():int
		{
			return (this._times != null ? this._times.length : 0);
		}
		
		public function add(time:ITime):void
		{
			this.addAt(time, this._times.length + 1);
		}
		
		public function addAt(time:ITime, index:int):void
		{
			this._times[index] = time;
		}
		
		public function item(index:int):ITime
		{
			return (this._times != null && index < this._times.length ? (this._times[index]) : null);
		}
	}
}