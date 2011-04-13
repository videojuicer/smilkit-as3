package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.smil.ISMILSwitchElement;
	
	public class SMILSwitchElement extends ElementParallelTimeContainer implements ISMILSwitchElement
	{
		public function SMILSwitchElement(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public override function get durationResolved():Boolean
		{
			var selected:IElement = this.selectedElement;
			
			if (selected != null)
			{
				return (selected as ElementTimeContainer).durationResolved;
			}
			
			return true;
		}
		
		public override function get duration():Number
		{
			var selected:ElementTimeContainer = (this.selectedElement as ElementTimeContainer);
			
			if (selected != null)
			{
				selected.resolve();
				
				return selected.duration;
			}
			
			return 0;
		}
		
		public function get selectedElement():IElement
		{
			var selected:INode = null;
			var child:INode = this.firstChild;
			
			while ((child = child.nextSibling) != null)
			{
				// test child
				if (child is ElementTestContainer)
				{
					if ((child as ElementTestContainer).test())
					{
						selected = child
						
						break;
					}
				}
			}
			
			return (selected as IElement);
		}
	}
}