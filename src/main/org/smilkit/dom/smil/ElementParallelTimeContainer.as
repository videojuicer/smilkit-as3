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
		
		public override function get durationResolved():Boolean
		{
		    if(super.durationResolved)
		    {
		       return true;
		    }
		
            for (var i:int = (this.childNodes.length-1); i >= 0; i--)
            {
                if (this.childNodes.item(i) is ElementTimeContainer)
                {
                    if(!(this.childNodes.item(i) as ElementTimeContainer).durationResolved)
                    {
                          return false;
                    }
                }
            }
            return true;
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
						var container:ElementTimeContainer = (this.childNodes.item(i) as ElementTimeContainer);
						
						if (container.dur > childDuration)
						{
							childDuration = container.dur;
						}
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