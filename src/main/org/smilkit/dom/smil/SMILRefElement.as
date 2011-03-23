package org.smilkit.dom.smil
{
	import flash.events.Event;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementSequentialTimeContainer;
	import org.smilkit.w3c.dom.smil.ISMILRefElement;
	
	public class SMILRefElement extends SMILMediaElement implements ISMILRefElement, IElementSequentialTimeContainer
	{
		public function SMILRefElement(owner:IDocument, name:String)
		{
			super(owner, name);
		}

		protected override function onDOMSubtreeModified(e:MutationEvent):void
		{
			// DO NOTHING
			// Ref elements are not interested in subtree modifications.
		}
		
		public override function get durationResolved():Boolean
		{
			if (super.durationResolved)
			{
				return true;
			}
			
			if (this.timeDescendants.length == 0)
			{
				return false;
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
			
			if (this.hasChildNodes() && duration < 0) // counts special constants like UNRESOLVED
			{
				var childDuration:Number = 0;
				
				for (var i:int = 0; i < this.timeDescendants.length; i++)
				{
					if (this.timeDescendants.item(i) is ElementTimeContainer)
					{
						var container:ElementTimeContainer = (this.timeDescendants.item(i) as ElementTimeContainer);
						container.resolve();
						
						if (!(container.end as TimeList).resolved)
						{
							return Time.UNRESOLVED;
						}
						
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
			}
			return duration;
		}
	}
}