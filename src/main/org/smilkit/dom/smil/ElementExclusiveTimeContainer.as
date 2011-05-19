package org.smilkit.dom.smil
{
	import org.smilkit.dom.smil.events.SMILMutationEvent;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementExclusiveTimeContainer;
	
	public class ElementExclusiveTimeContainer extends ElementParallelTimeContainer implements IElementExclusiveTimeContainer
	{
		protected var _selectedElement:ElementTestContainer;
		
		public function ElementExclusiveTimeContainer(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public override function resumeElement():void
		{
			// only resume the selected element
			if (this.selectedElement != null)
			{
				this.resumeElement();
			}
			
			this._playbackState = ElementTimeContainer.PLAYBACK_STATE_PLAYING;
		}
		
		public override function appendChild(newChild:INode):INode
		{
			var child:INode = super.appendChild(newChild);
			
			// add listeners for when the child changes play state
			child.addEventListener(SMILMutationEvent.DOM_PLAYBACK_STATE_MODIFIED, this.onDOMPlaybackStateModified, false);
			
			return child;
		}
		
		public override function removeChild(oldChild:INode):INode
		{
			var child:INode = super.removeChild(oldChild);
			
			child.removeEventListener(SMILMutationEvent.DOM_PLAYBACK_STATE_MODIFIED, this.onDOMPlaybackStateModified, false);
		
			return child;
		}
		
		protected function onDOMPlaybackStateModified(e:SMILMutationEvent):void
		{
			var child:ElementTestContainer = (e.relatedNode as ElementTestContainer);
			var state:uint = uint(e.newValue);
			
			if (state == ElementTimeContainer.PLAYBACK_STATE_PLAYING)
			{
				// switch to the new element
				this.updateSelectedElement(child);
			}
		}
		
		public function recheck():void
		{
			var child:INode = this.firstChild;
			
			while ((child = child.nextSibling) != null)
			{
				if (child is ElementTestContainer)
				{
					var childContainer:ElementTestContainer = (child as ElementTestContainer);
					
					if (childContainer.test())
					{
						this.updateSelectedElement(childContainer);
						
						return;
					}
				}
			}
			
			this.updateSelectedElement(null);
		}
		
		protected function updateSelectedElement(element:ElementTestContainer):void
		{
			var previous:ElementTestContainer = this._selectedElement;
	
			if (previous != element)
			{
				// need to pause previous
				previous.pauseElement();
				
				this._selectedElement = element;
				
				this._selectedElement.resumeElement();
			}
		}
		
		public override function get durationResolved():Boolean
		{
			if (this._selectedElement != null)
			{
				return this._selectedElement.durationResolved;
			}
			
			return true;
		}
		
		public override function get duration():Number
		{
			if (this._selectedElement != null)
			{
				if (!this._selectedElement.durationResolved)
				{
					//this._selectedElement.resolve();
				}
				
				return this._selectedElement.duration;
			}
			
			return 0;
		}
		
		public function get pausedElements():INodeList
		{
			return null;
		}
		
		public function get selectedElement():IElement
		{
			if (this._selectedElement == null)
			{
				this.recheck();
			}
			
			return (this._selectedElement as IElement);
		}
	}
}