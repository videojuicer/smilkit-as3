package org.smilkit.dom.smil
{
	import flash.events.Event;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.ISMILRefElement;
	
	public class SMILRefElement extends SMILMediaElement implements ISMILRefElement
	{
		public function SMILRefElement(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public override function get durationResolved():Boolean
		{
			SMILKit.logger.debug("REF->DURATION->");
			
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
			
			if (this.hasChildNodes() && duration == 0)
			{
				var childDuration:Number = 0;
				
				for (var i:int = 0; i < this.timeDescendants.length; i++)
				{
					if (this.timeDescendants.item(i) is ElementTimeContainer)
					{
						childDuration += (this.timeDescendants.item(i) as ElementTimeContainer).duration;
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