package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementSequentialTimeContainer;
	import org.smilkit.w3c.dom.smil.ITimeList;
	
	public class ElementSequentialTimeContainer extends SMILElement implements IElementSequentialTimeContainer
	{
		public function ElementSequentialTimeContainer(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public function get timeChildren():INodeList
		{
			return null;
		}
		
		public function activeChildrenAt(instant:Number):INodeList
		{
			return null;
		}
		
		public function get begin():ITimeList
		{
			return null;
		}
		
		public function set begin(begin:ITimeList):void
		{
		}
		
		public function get end():ITimeList
		{
			return null;
		}
		
		public function set end(end:ITimeList):void
		{
		}
		
		public function get dur():Number
		{
			return 0;
		}
		
		public function set dur(dur:Number):void
		{
		}
		
		public function get restart():uint
		{
			return 0;
		}
		
		public function set restart(restart:uint):void
		{
		}
		
		public function get fill():uint
		{
			return 0;
		}
		
		public function set fill(fill:uint):void
		{
		}
		
		public function get repeatCount():Number
		{
			return 0;
		}
		
		public function set repeatCount(repeatCount:Number):void
		{
		}
		
		public function get repeatDur():Number
		{
			return 0;
		}
		
		public function set repeatDur(repeatDur:Number):void
		{
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
		}
		
		public function resumeElement():void
		{
		}
		
		public function seekElement(seekTo:Number):void
		{
		}
	}
}