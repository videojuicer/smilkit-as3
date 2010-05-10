package org.smilkit.time
{
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class ResolvedTimeElement
	{
		private var _begin:uint;
		private var _end:uint;
		private var _element:ISMILMediaElement;
		
		public function ResolvedTimeElement(element:ISMILMediaElement, begin:uint, end:uint)
		{
			this._element = element;
			
			this._begin = begin;
			this._end = end;
		}
		
		public function get begin():uint
		{
			return this._begin;
		}
		
		public function get end():uint
		{
			return this._end;
		}
		
		public function get element():ISMILMediaElement
		{
			return this._element;
		}
		
		public function activeAt(offset:Number):Boolean
		{
			return (offset >= this._begin && offset <= this._end);
		}
	}
}