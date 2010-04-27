package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementParallelTimeContainer;
	import org.smilkit.w3c.dom.smil.ITimeList;
	
	public class ElementParallelTimeContainer extends ElementTimeContainer implements IElementParallelTimeContainer
	{
		public function ElementParallelTimeContainer(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public function get endSync():String
		{
			return null;
		}
		
		public function set endSync(endSync:String):void
		{
		}
		
		public function get implicitDuration():Number
		{
			return 0;
		}
	}
}