package org.smilkit.dom.smil
{
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;
	
	public class ElementBodyTimeContainer extends ElementSequentialTimeContainer
	{
		protected var _intervalsLaunched:Boolean = false;
		
		public function ElementBodyTimeContainer(owner:IDocument, name:String)
		{
			super(owner, name);
			
			this.addEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, this.onDOMBodySubtreeModified, false);
		}
		
		public function get intervalsLaunched():Boolean
		{
			return this._intervalsLaunched;
		}

		public override function get isPlaying():Boolean
		{
			return true;
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
		
		protected function onDOMBodySubtreeModified(e:MutationEvent):void
		{
			this.ownerSMILDocument.scheduler.reset();
			
			this.resetElementState();
			
			this.startup();
			
			this._intervalsLaunched = true;
		}
	}
}