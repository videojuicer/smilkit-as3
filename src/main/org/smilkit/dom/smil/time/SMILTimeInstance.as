package org.smilkit.dom.smil.time
{
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.Time;

	public class SMILTimeInstance
	{
		private var _begin:Time;
		private var _end:Time;
		private var _element:ElementTimeContainer;
		
		public function SMILTimeInstance(element:ElementTimeContainer, begin:Time, end:Time)
		{
			this._element = element;
			
			this._begin = begin;
			this._end = end;
		}
		
		public function get begin():Time
		{
			return this._begin;
		}
		
		public function get end():Time
		{
			return this._end;
		}
		
		public function get element():ElementTimeContainer
		{
			return this._element;
		}
		
		public function get mediaElement():SMILMediaElement
		{
			return (this._element as SMILMediaElement);
		}
		
		public function get currentBegin():Number
		{
			var pair:Object = this.activePair;
			
			if (pair == null)
			{
				return NaN;
			}
			
			return pair.begin;
		}
		
		public function get currentEnd():Number
		{
			var pair:Object = this.activePair;
			
			if (pair == null)
			{
				return NaN;
			}
			
			return pair.end;
		}
		
		public function get activePair():Object
		{
			return this.activePairAt((this.element.ownerDocument as SMILDocument).offset);
		}
		
		public function activePairAt(offset:Number):Object
		{
//			var pair:Object = { begin: 0, end: Time.UNRESOLVED };
//			
//			for (var i:uint = 0; i < this.begin.length; i++)
//			{
//				var begin:Number = this.begin[i];
//				
//				if (offset >= begin)
//				{
//					pair.begin = begin;
//					
//					// this begin, fills our wishes
//					for (var j:uint = 0; j < this.end.length; j++)
//					{
//						var end:Number = this.end[i];
//						
//						if (offset <= end || Time.UNRESOLVED == end == Time.INDEFINITE)
//						{
//							pair.end = end;
//							
//							return pair;
//						}
//					}
//				}
//			}
			
			return null;
		}
		
		public function activeAt(offset:Number):Boolean
		{
			// end -> which ever condition comes first (events will be moved into first place when they hit and stored with the offset)
			// begin -> each new begin met is a restart
//			for (var i:uint = 0; i < this.begin.length; i++)
//			{
//				var begin:Number = this.begin[i];
//				
//				if (offset >= begin)
//				{
//					// this begin, fills our wishes
//					for (var j:uint = 0; j < this.end.length; j++)
//					{
//						var end:Number = this.end[i];
//						
//						if (offset <= end || Time.UNRESOLVED == end == Time.INDEFINITE)
//						{
//							return true;
//						}
//					}
//				}
//			}
// 			
//			return false;

			var now:Time = new Time(null, false, offset + "ms");
			
			return ((now.isGreaterThan(this.begin) || now.isEqualTo(this.begin)) && this.end.isGreaterThan(now));
			
			/*
			if (this._begin == Time.UNRESOLVED)
			{
				return false;
			}
			
			return (offset >= this._begin && (this._end == Time.UNRESOLVED || this._end == Time.INDEFINITE || offset <= this._end));
			*/
		}
	}
}