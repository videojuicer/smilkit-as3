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
package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.smil.ITime;
	import org.smilkit.w3c.dom.smil.ITimeList;
	
	public class TimeList implements ITimeList
	{
		protected var _element:ElementTimeContainer = null;
		
		protected var _begin:Boolean = false;
		protected var _tokenString:String = null;
		
		protected var _times:Vector.<Time>;

		public function TimeList(element:ElementTimeContainer, begin:Boolean = false, tokenString:String = null)
		{
			this._element = element;
			
			this._begin = begin;
			this._tokenString = tokenString;
			
			this._times = new Vector.<Time>();
			
			// go go go
			this.parseAttribute();
		}
		
		public function get length():int
		{
			return (this._times != null ? this._times.length : 0);
		}
		
		public function get isDefined():Boolean
		{
			return (this.length > 0);
		}
		
		public function get last():ITime
		{
			if (this.length > 0)
			{
				return this.item(this.length - 1);
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
		
		public function get current():ITime
		{
			if (this.length > 0)
			{
				return this.item(0);
			}
			
			return null;
		}
		
		public function add(time:ITime):void
		{			
			this._times.push(time);
			
			this._times.sort(this.sortTimeList);
		}
		
		public function getTimeGreaterThan(time:Time):Time
		{
			var result:Time = null;
			
			for (var i:uint = 0; i < this._times.length; i++)
			{
				result = this._times[i];
				
				if (result.isGreaterThan(time))
				{
					return result;
				}
			}
			
			return null;
		}
		
		protected function sortTimeList(a:Time, b:Time):int
		{
			if (b.isGreaterThan(a))
			{
				return -1
			}
			else if (a.isGreaterThan(b))
			{
				return 1;
			}
			
			return 0;
		}

		public function item(index:int):ITime
		{
			return (this._times != null && index < this._times.length ? (this._times[index]) : null);
		}
		
		public function parseAttribute():void
		{
			if (this._tokenString != null && this._tokenString != "")
			{
				// split the expression into many
				var expressions:Array = this._tokenString.split(";");
				
				for (var i:uint = 0; i < expressions.length; i++)
				{
					// our expression
					var expression:String = expressions[i];
					
					var time:Time = new Time(this._element, this._begin, expressions[i]);
					
					this.add(time);
				}
			}
			
			/* NOOO we dont
			// need to make sure we have an end for each begin
			if (!this._baseBegin && this._baseElement != null)
			{
				var endCount:uint = this._times.length;
				var beginCount:uint = this._baseElement.begin.length;
				
				if (endCount < beginCount)
				{
					var missing:uint = (beginCount - endCount);
					var startIndex:uint = (beginCount - missing);
					
					for (var m:uint = 0; m < missing; m++)
					{
						
					}
				}
			}
			*/
		}
	}
}