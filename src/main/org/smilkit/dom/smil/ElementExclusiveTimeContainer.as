/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
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
			child.addEventListener(SMILMutationEvent.DOM_NODE_RENDER_STATE_MODIFIED, this.onDOMNodeRenderStateModified, false);
			
			return child;
		}
		
		public override function removeChild(oldChild:INode):INode
		{
			var child:INode = super.removeChild(oldChild);
			
			child.removeEventListener(SMILMutationEvent.DOM_NODE_RENDER_STATE_MODIFIED, this.onDOMNodeRenderStateModified, false);
		
			return child;
		}
		
		protected function onDOMNodeRenderStateModified(e:SMILMutationEvent):void
		{
			this.recheck();
		}
		
		public function recheck():void
		{
			var children:INodeList = this.timeDescendants;
			
			for (var i:uint = 0; i < children.length; i++)
			{
				var child:ElementTestContainer = (children.item(i) as ElementTestContainer);
				
				child.updateRenderState();
				
				if (child.renderState == ElementTestContainer.RENDER_STATE_ACTIVE)
				{
					this.updateSelectedElement(child);
					
					return;
				}
			}
			
			this.updateSelectedElement(null);
		}
		
		public override function startChildren():void
		{
			var element:ElementTimeContainer = (this.selectedElement as ElementTimeContainer);
			
			if (element != null)
			{
				element.startup();
			}
		}
		
		protected function updateSelectedElement(element:ElementTestContainer):void
		{
			var previous:ElementTestContainer = this._selectedElement;
	
			if (previous != element)
			{
				if (previous != null)
				{
					previous.deactivate();
					
					previous.resetElementState();
				}
				
				this._selectedElement = element;
				
				if (this._selectedElement != null)
				{
					this._selectedElement.startup();
				}
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
			if (this._selectedElement != null && this._selectedElement.currentEndInterval != null)
			{
				return this._selectedElement.currentEndInterval.resolvedOffset;
			}
			
			return 0;
		}
		
		public override function computeImplicitDuration():Time
		{
			var duration:Number = 0;
			
			if (this.selectedTimeContainer != null)
			{
				if (this.selectedTimeContainer.currentEndInterval == null || !this.selectedTimeContainer.currentEndInterval.resolved)
				{
					return new Time(this, false, "unresolved");
				}
				else if (this.selectedTimeContainer.currentEndInterval.indefinite)
				{
					return new Time(this, false, "indefinite");
				}
				else
				{
					duration = this.selectedTimeContainer.currentEndInterval.resolvedOffset;
				}
			}
			
			return new Time(this, false, int(duration * 1000) + "ms");
		}
		
		public override function resolveChildLoadableSizes(e:INode=null):Array
		{
			var selected:ElementTimeContainer = (this.selectedElement as ElementTimeContainer);
			
			if (selected != null)
			{
				if (selected.bytesLoaded == FileSize.UNRESOLVED)
				{
					this.childrenBytesLoaded = FileSize.UNRESOLVED;
				}
				else
				{
					this.childrenBytesLoaded = selected.bytesLoaded;
				}
				
				if (selected.bytesTotal == FileSize.UNRESOLVED)
				{
					this.childrenBytesTotal = FileSize.UNRESOLVED;
				}
				else
				{
					this.childrenBytesTotal = selected.bytesTotal;
				}
			}
			
			return [ this.bytesLoaded, this.bytesTotal ];
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
		
		public function get selectedTimeContainer():ElementTimeContainer
		{
			if (this.selectedElement != null)
			{
				return (this.selectedElement as ElementTimeContainer);
			}
			
			return null;
		}
	}
}