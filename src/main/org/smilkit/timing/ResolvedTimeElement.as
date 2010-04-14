package org.smilkit.timing
{
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class ResolvedTimeElement
	{
		private var _begin:uint;
		private var _end:uint;
		private var _element:ISMILMediaElement;
		
		public function ResolvedTimeElement(element:ISMILMediaElement, begin:uint = -1, end:uint = -1)
		{
			this._element = element;
			
			this._begin = begin;
			this._end = end;
			
			if (this._begin == -1 || this._end == -1)
			{
				// set from element
			}
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
	}
}