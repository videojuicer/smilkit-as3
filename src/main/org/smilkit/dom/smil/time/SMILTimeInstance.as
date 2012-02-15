/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
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
//			var pair:Object = { begin: 0, end: Times.UNRESOLVED };
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
//						if (offset <= end || Times.UNRESOLVED == end == Times.INDEFINITE)
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
//						if (offset <= end || Times.UNRESOLVED == end == Times.INDEFINITE)
//						{
//							return true;
//						}
//					}
//				}
//			}
// 			
//			return false;

			var now:Time = new Time(null, false, (offset * 1000) + "ms");
			
			return ((now.isGreaterThan(this.begin) || now.isEqualTo(this.begin)) && this.end.isGreaterThan(now));
			
			/*
			if (this._begin == Times.UNRESOLVED)
			{
				return false;
			}
			
			return (offset >= this._begin && (this._end == Times.UNRESOLVED || this._end == Times.INDEFINITE || offset <= this._end));
			*/
		}
	}
}