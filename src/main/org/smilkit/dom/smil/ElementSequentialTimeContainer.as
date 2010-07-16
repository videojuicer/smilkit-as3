package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementSequentialTimeContainer;
	import org.smilkit.w3c.dom.smil.ITimeList;
	
	public class ElementSequentialTimeContainer extends ElementTimeContainer implements IElementSequentialTimeContainer
	{
		public function ElementSequentialTimeContainer(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public override function get dur():Number
		{
			var duration:Number = super.dur;
			
			if (this.hasChildNodes() && duration == 0)
			{
				var childDuration:Number = 0;
				
				for (var i:int = 0; i < this.childNodes.length; i++)
				{
					if (this.childNodes.item(i) is ElementTimeContainer)
					{
						childDuration += (this.childNodes.item(i) as ElementTimeContainer).dur;
					}
				}
				
				if (childDuration != 0)
				{
					return childDuration;
				}
			}
			
			return duration;
		}
	}
}