package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementParallelTimeContainer;
	
	public class ElementParallelTimeContainer extends ElementTestContainer implements IElementParallelTimeContainer
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
		
		protected override function childIntervalChanged(child:ElementTimeContainer):void
		{
			// a child changed but were running in parallel so we dont need to do anything
			
			super.childIntervalChanged(child);
		}
		
		public override function get durationResolved():Boolean
		{
		    if(super.durationResolved)
		    {
		       return true;
		    }
		
            for (var i:int = (this.timeDescendants.length-1); i >= 0; i--)
            {
                if (this.timeDescendants.item(i) is ElementTimeContainer)
                {
                    if(!(this.timeDescendants.item(i) as ElementTimeContainer).durationResolved)
                    {
                          return false;
                    }
                }
            }
			
            return true;
		}
		
		public override function get duration():Number
		{
			var duration:Number = super.duration;
			
			if (this.hasChildNodes() && ((duration == Time.MEDIA) && !this.hasDuration()))
			{
				var childDuration:Number = 0;
				
				for (var i:int = 0; i < this.timeDescendants.length; i++)
				{
					if (this.timeDescendants.item(i) is ElementTimeContainer)
					{
						var container:ElementTimeContainer = (this.timeDescendants.item(i) as ElementTimeContainer);

						if (container.end.first.resolvedOffset > childDuration)
						{
							childDuration = container.end.first.resolvedOffset;
						}
					}
				}
				
				if (childDuration != 0)
				{
					childDuration = (childDuration - this.begin.first.resolvedOffset);
					
					return childDuration;
				}
				
				return Time.UNRESOLVED;
			}
			
			return duration;
		}
		
		public override function computeImplicitDuration():Time
		{
			// no duration defined on a par, so we use the children
			var duration:Number = 0;
			var timeChildren:INodeList = this.timeDescendants;
			
			for (var i:uint = 0; i < timeChildren.length; i++)
			{
				var child:ElementTimeContainer = (timeChildren.item(i) as ElementTimeContainer);
				
				if (child.currentEndInterval == null || !child.currentEndInterval.resolved)
				{
					return new Time(this, false, "unresolved");
				}
				else if (child.currentEndInterval.indefinite)
				{
					return new Time(this, false, "indefinite");
				}
				else
				{
					if (child.currentEndInterval.resolvedOffset > duration)
					{
						duration = child.currentEndInterval.resolvedOffset;
					}
				}
			}
			
			return new Time(this, false, int(duration * 1000) + "ms");
		}
	}
}