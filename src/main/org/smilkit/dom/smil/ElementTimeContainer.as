package org.smilkit.dom.smil
{
	import org.smilkit.parsers.SMILTimeParser;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;
	import org.smilkit.w3c.dom.smil.ITimeList;
	import org.smilkit.util.logger.Logger;
	
	public class ElementTimeContainer extends SMILElement implements IElementTimeContainer
	{
		protected var _beginList:ITimeList;
		protected var _endList:ITimeList;
		
		protected var _durationParser:SMILTimeParser;
		
		public function ElementTimeContainer(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public function get timeChildren():INodeList
		{
			return new ElementTimeNodeList(this);
		}
		
		public function activeChildrenAt(instant:Number):INodeList
		{
			return null;
		}
		
		public function get begin():ITimeList
		{
			if (this._beginList == null)
			{
				this._beginList = ElementTime.parseTimeAttribute(this.getAttribute("begin"), this, true);
			}
			
			return this._beginList;
		}
		
		public function set begin(begin:ITimeList):void
		{
			this._beginList = begin;
		}
		
		public function get end():ITimeList
		{
			if (this._endList == null)
			{
				this._endList = ElementTime.parseTimeAttribute(this.getAttribute("end"), this, false);
			}
			
			return this._endList;
		}
		
		public function set end(end:ITimeList):void
		{
			this._endList = end;
		}
		
		public function get dur():Number
		{	
			if (this._durationParser == null)
			{
				this._durationParser = new SMILTimeParser(this, this.getAttribute("dur"));
			}
			
			if (this._durationParser.timeString != this.getAttribute("dur"))
			{
				this._durationParser.parse(this.getAttribute("dur"));
			}
			return this._durationParser.milliseconds;
		}
		
		/**
		* Indicates whether the current duration on this time container may be considered resolved.
		* Since SMILKit's media handlers actually write a duration to their parent nodes when resolving
		* assets with implicit durations, for most elements this simply means determining if a duration
		* has been set on the node. See ElementSequentialTimeContainer and ElementParallelTimeContainer for
		* more complex implementations.
		*
		* @see org.smilkit.dom.smil.ElementSequentialTimeContainer
		* @see org.smilkit.dom.smil.ElementParallelTimeContainer
		*/
		public function get durationResolved():Boolean
		{
            return this.hasAttribute("dur");
		}
		
		public function set dur(dur:Number):void
		{
			this.setAttribute("dur", dur.toString()+"ms");
		}
		
		public function get restart():uint
		{
			return (this.getAttribute("restart") as uint);
		}
		
		public function set restart(restart:uint):void
		{
			this.setAttribute("restart", (restart as String));
		}
		
		public function get fill():uint
		{
			return (this.getAttribute("fill") as uint);
		}
		
		public function set fill(fill:uint):void
		{
			this.setAttribute("fill", (fill as String));
		}
		
		public function get repeatCount():Number
		{
			return (this.getAttribute("repeatCount") as Number);
		}
		
		public function set repeatCount(repeatCount:Number):void
		{
			this.setAttribute("repeatCount", (repeatCount as String));
		}
		
		public function get repeatDur():Number
		{
			return (this.getAttribute("repeatDur") as Number);
		}
		
		public function set repeatDur(repeatDur:Number):void
		{
			this.setAttribute("repeatDur", (repeatDur as String));
		}
		
		public function beginElement():Boolean
		{
			return false;
		}
		
		public function endElement():Boolean
		{
			return false;
		}
		
		public function pauseElement():void
		{
			// pause children
		}
		
		public function resumeElement():void
		{
			// resume children
		}
		
		public function seekElement(seekTo:Number):void
		{
			// seek children 
		}
		
		public function resolve():void
		{
			var begin:TimeList = (this.begin as TimeList);
			var end:TimeList = (this.end as TimeList);
			
			if (begin != null)
			{
				begin.resolve();
			}
			
			if (end != null)
			{
				end.resolve();
			}
		}
	}
}