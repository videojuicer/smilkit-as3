package org.smilkit.dom.smil
{
	import org.hamcrest.mxml.object.Null;
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.expressions.SMILExpressionParser;
	import org.smilkit.dom.smil.expressions.SMILTimeExpressionParser;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.smil.ITime;
	import org.smilkit.w3c.dom.smil.ITimeList;
	import org.utilkit.collection.List;
	
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