package org.smilkit.time
{
	import org.smilkit.dom.smil.Time;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class TimingNode
	{
		private var _begin:int;
		private var _end:int;
		private var _element:ISMILMediaElement;
		
		public function TimingNode(element:ISMILMediaElement, begin:uint, end:uint)
		{
			this._element = element;
			
			this._begin = begin;
			this._end = end;
		}
		
		public function get begin():int
		{
			return this._begin;
		}
		
		public function get end():int
		{
			return this._end;
		}
		
		public function get element():ISMILMediaElement
		{
			return this._element;
		}
		
		public function activeAt(offset:Number):Boolean
		{
			if (this._begin == Time.UNRESOLVED)
			{
				return false;
			}
			
			return (offset >= this._begin && offset <= this._end);
		}
	}
}