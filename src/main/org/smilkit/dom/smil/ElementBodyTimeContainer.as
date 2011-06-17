package org.smilkit.dom.smil
{
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;
	
	public class ElementBodyTimeContainer extends ElementSequentialTimeContainer
	{
		public function ElementBodyTimeContainer(owner:IDocument, name:String)
		{
			super(owner, name);
			
			this.addEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, this.onDOMSubtreeModified, false);
		}

		public override function get isPlaying():Boolean
		{
			return this.ownerSMILDocument.scheduler.running;
		}
		
		public override function get parentTimeContainer():ElementTimeContainer
		{
			// return self, theres no time containers above the body
			return this;
		}
		
		public override function gatherFirstInterval():void
		{
			super.gatherFirstInterval();
		}
		
		public override function gatherNextInterval(usingBegin:Time = null):Boolean
		{
			return super.gatherNextInterval(usingBegin);
		}
		
		protected override function childIntervalChanged(child:ElementTimeContainer):void
		{
			// since were our own parent time container, we dont trigger a change when
			// we notify ourself of a new interval
			if (child == this)
			{
				return;
			}
			
			super.childIntervalChanged(child);
		}
		
		protected function onDOMSubtreeModified(e:MutationEvent):void
		{
			this.resetElementState();
			this.startup();
		}
	}
}