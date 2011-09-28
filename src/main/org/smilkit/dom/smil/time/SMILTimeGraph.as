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
package org.smilkit.dom.smil.time
{
	import org.smilkit.SMILKit;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.dom.smil.events.SMILMutationEvent;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.time.SharedTimer;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.utilkit.collection.Hashtable;
	import org.utilkit.util.Platform;

	public class SMILTimeGraph
	{
		protected var _ownerDocument:SMILDocument;
		
		protected var _elements:Vector.<SMILTimeInstance>;
		
		protected var _intervalTriggered:Boolean = false;
		
		public function SMILTimeGraph(ownerDocument:SMILDocument)
		{
			this._ownerDocument = ownerDocument;
			
			// default blank vector
			this._elements = new Vector.<SMILTimeInstance>();
			
			// dom mutations (only used until the body is ready)
			this.ownerDocument.addEventListener(MutationEvent.DOM_ATTR_MODIFIED, this.onMutationEvent, false);
			this.ownerDocument.addEventListener(MutationEvent.DOM_NODE_INSERTED, this.onMutationEvent, false);
			this.ownerDocument.addEventListener(MutationEvent.DOM_NODE_REMOVED, this.onMutationEvent, false);
			
			// smil mutations (should be removed, modifications should trigger new intervals if needed
			//this.ownerDocument.addEventListener(SMILMutationEvent.DOM_VARIABLES_INSERTED, this.onSMILMutationEvent, false);
			//this.ownerDocument.addEventListener(SMILMutationEvent.DOM_VARIABLES_MODIFIED, this.onSMILMutationEvent, false);
			//this.ownerDocument.addEventListener(SMILMutationEvent.DOM_VARIABLES_REMOVED, this.onSMILMutationEvent, false);
			
			// interval mutations
			this.ownerDocument.addEventListener(SMILMutationEvent.DOM_CURRENT_INTERVAL_MODIFIED, this.onSMILMutationEvent, false);
			
			//this.rebuild();
		}		
		
		public function get ownerDocument():SMILDocument
		{
			return this._ownerDocument;
		}
		
		public function get elements():Vector.<SMILTimeInstance>
		{
			return this._elements;
		}
		
		public function get mediaElements():Vector.<SMILTimeInstance>
		{
			var elements:Vector.<SMILTimeInstance> = new Vector.<SMILTimeInstance>();
			
			for (var i:uint = 0; i < this.elements.length; i++)
			{
				if (this.elements[i].element is SMILMediaElement)
				{
					elements.push(this.elements[i])
				}
			}
			
			if (elements.length == 0)
			{
				elements = null;
			}
			
			return elements;
		}
		
		public function get activeElements():Vector.<SMILTimeInstance>
		{
			return this.activeElementsAt(this.ownerDocument.offset);
		}
		
		public function activeElementsAt(offset:Number):Vector.<SMILTimeInstance>
		{
			var elements:Vector.<SMILTimeInstance> = new Vector.<SMILTimeInstance>();
			
			for (var i:uint = 0; i < this.elements.length; i++)
			{
				var node:SMILTimeInstance = this.elements[i];
				
				if (node.activeAt(offset))
				{
					elements.push(node);
				}
			}
			
			return elements;
		}
		
		public function rebuild():void
		{
			var memoryFreed:uint = Platform.garbageCollection();
			SMILKit.logger.info("Rebuilding time graph, freed "+memoryFreed+"bytes of memory");
			
			this._elements = new Vector.<SMILTimeInstance>();
				
			this.rebuildTimeGraph(this.ownerDocument);
			
			var event:SMILMutationEvent = new SMILMutationEvent();
			event.initMutationEvent(SMILMutationEvent.DOM_TIMEGRAPH_MODIFIED, true, false, null, null, null, null, 1);

			this.ownerDocument.dispatchEvent(event);
		}
		
		protected function rebuildTimeGraph(node:INode):void
		{
			var childNodes:INodeList = node.childNodes;
			
			for (var i:uint = 0; i < childNodes.length; i++)
			{
				var childNode:INode = childNodes.item(i);
				var childContainer:ElementTimeContainer = (childNode as ElementTimeContainer);
				
				if (childContainer != null)
				{
					// found a container that should be able to give us an interval,
				 	// these means we can stop listening for mutations on the DOM as
					// an interval changed event will trigger
					this.buildTimeNode(childContainer);
					
					this._intervalTriggered = true;
				}
				
				if (childNode.hasChildNodes())
				{
					this.rebuildTimeGraph(childNode);
				}
			}
		}
		
		protected function buildTimeNode(node:ElementTimeContainer):void
		{
			var begin:Time = (node.currentBeginInterval);
			var end:Time = (node.currentEndInterval);

			if (begin != null)
			{
				this._elements.push(new SMILTimeInstance(node, begin, end));
			}
		}
		
		protected function onSMILMutationEvent(e:SMILMutationEvent):void
		{
			this.rebuild();
		}
		
		protected function onMutationEvent(e:MutationEvent):void
		{
			var body:INode = this.ownerDocument.getElementsByTagName("body").item(0);
			
			if (body != null)
			{
				var container:ElementTimeContainer = (body as ElementTimeContainer);
				
				this.ownerDocument.removeEventListener(MutationEvent.DOM_ATTR_MODIFIED, this.onMutationEvent, false);
				this.ownerDocument.removeEventListener(MutationEvent.DOM_NODE_INSERTED, this.onMutationEvent, false);
				this.ownerDocument.removeEventListener(MutationEvent.DOM_NODE_REMOVED, this.onMutationEvent, false);
				
				//container.startup();
				
				this.rebuild();
			}
		}
	}
}