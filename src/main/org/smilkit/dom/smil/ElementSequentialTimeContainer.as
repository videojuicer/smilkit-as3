package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementSequentialTimeContainer;
	import org.utilkit.collection.Hashtable;
	
	public class ElementSequentialTimeContainer extends ElementTestContainer implements IElementSequentialTimeContainer
	{
		protected var _childCachedTimes:Hashtable = null;
		
		public function ElementSequentialTimeContainer(owner:IDocument, name:String)
		{
			super(owner, name);
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
			var duration:Number = Time.UNRESOLVED;
			
			if (this._currentEndInterval != null)
			{
				if (this._currentEndInterval.resolved)
				{
					if (this._currentEndInterval.indefinite)
					{
						duration = Time.INDEFINITE;	
					}
					else
					{
						duration = (this._currentEndInterval.resolvedOffset * 1000);
					}
				}
			}
			
			return duration;
		}
		
		public override function computeImplicitDuration():Time
		{
			// no duration defined on a seq, so we use the children
			var duration:Number = 0;
			var timeChildren:INodeList = this.timeChildren; //this.timeDescendants;
			
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
					duration = child.currentEndInterval.resolvedOffset;
				}
			}
			
			return new Time(this, false, int(duration * 1000) + "ms");
		}
		
		public override function offsetForChild(element:ElementTimeContainer):Number
		{
			var duration:Number = 0;
			var timeDescendants:INodeList = this.timeChildren;
			
			for (var i:uint = 0; i < timeDescendants.length; i++)
			{
				var child:ElementTimeContainer = (timeDescendants.item(i) as ElementTimeContainer);
				
				if (element == child)
				{
					return duration;
				}
				
				if (child.currentEndInterval == null || !child.currentEndInterval.resolved)
				{
					return Time.UNRESOLVED;
				}
				
				duration = child.currentEndInterval.resolvedOffset;
			}
			
			return duration;
		}
		
		protected override function childIntervalChanged(child:ElementTimeContainer):void
		{
			this.updateChildCachedTimes();
			
			// we only change ourself if the last child changed, otherwise we might as well wait
			// until that child changes
			
			super.childIntervalChanged(child);
		}
		
		protected function updateChildCachedTimes():void
		{
			this._childCachedTimes = new Hashtable();
			
			var timeDescendants:INodeList = this.timeDescendants;
			
			for (var i:int = 0; i < timeDescendants.length; i++)
			{
				var element:ElementTimeContainer = (timeDescendants.item(i) as ElementTimeContainer);
				
				var resolvedEndOffset:int = Time.UNRESOLVED;
				
				if (element.currentEndInterval != null)
				{
					resolvedEndOffset = element.currentEndInterval.resolvedOffset;
				}
				
				this._childCachedTimes.setItem(resolvedEndOffset, element);
			}
		}
	}
}