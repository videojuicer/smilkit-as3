package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementExclusiveTimeContainer;
	
	public class ElementExclusiveTimeContainer extends ElementParallelTimeContainer implements IElementExclusiveTimeContainer
	{
		public function ElementExclusiveTimeContainer(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public function get pausedElements():INodeList
		{
			return null;
		}
	}
}