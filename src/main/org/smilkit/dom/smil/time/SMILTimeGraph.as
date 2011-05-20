package org.smilkit.dom.smil.time
{
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

	public class SMILTimeGraph
	{
		protected var _ownerDocument:SMILDocument;
		
		protected var _elements:Vector.<SMILTimeInstance>;
		
		protected var _waitingCallbacks:Hashtable;
		protected var _intervalTriggered:Boolean = false;
		
		public function SMILTimeGraph(ownerDocument:SMILDocument)
		{
			this._ownerDocument = ownerDocument;
			
			this._waitingCallbacks = new Hashtable();

			// dom mutations
			
			this.ownerDocument.addEventListener(MutationEvent.DOM_ATTR_MODIFIED, this.onMutationEvent, false);
			this.ownerDocument.addEventListener(MutationEvent.DOM_CHARACTER_DATA_MODIFIED, this.onMutationEvent, false);
			this.ownerDocument.addEventListener(MutationEvent.DOM_NODE_INSERTED, this.onMutationEvent, false);
			this.ownerDocument.addEventListener(MutationEvent.DOM_NODE_INSERTED_INTO_DOCUMENT, this.onMutationEvent, false);
			this.ownerDocument.addEventListener(MutationEvent.DOM_NODE_REMOVED, this.onMutationEvent, false);
			this.ownerDocument.addEventListener(MutationEvent.DOM_NODE_REMOVED_FROM_DOCUMENT, this.onMutationEvent, false);
			this.ownerDocument.addEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, this.onMutationEvent, false);
			
			// smil mutations
			this.ownerDocument.addEventListener(SMILMutationEvent.DOM_VARIABLES_INSERTED, this.onSMILMutationEvent, false);
			this.ownerDocument.addEventListener(SMILMutationEvent.DOM_VARIABLES_MODIFIED, this.onSMILMutationEvent, false);
			this.ownerDocument.addEventListener(SMILMutationEvent.DOM_VARIABLES_REMOVED, this.onSMILMutationEvent, false);
			
			this.ownerDocument.addEventListener(SMILMutationEvent.DOM_CURRENT_INTERVAL_MODIFIED, this.onSMILMutationEvent, false);
			
			if (this._ownerDocument.viewportObjectPool != null && this._ownerDocument.viewportObjectPool.viewport != null)
			{
				// heartbeat
				this._ownerDocument.viewportObjectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.RUNNING_OFFSET_CHANGED, this.onHeartbeat);
			}
			
			this.rebuild();
		}
		
		public function waitUntil(offset:Number, callback:Function):Boolean
		{			
			if (offset >= this._ownerDocument.offset)
			{
				if (!this._waitingCallbacks.hasItem(offset))
				{
					this._waitingCallbacks.setItem(offset, new Vector.<Function>());
				}
				
				(this._waitingCallbacks.getItem(offset) as Vector.<Function>).push(callback);
				
				return true;
			}
			
			// already happened
			return false;
		}
		
		public function removeWaiting(callback:Function):void
		{
			for (var i:uint = 0; i < this._waitingCallbacks.length; i++)
			{
				var offset:Number = (this._waitingCallbacks.getKeyAt(i) as Number);
				var callbacks:Vector.<Function> = (this._waitingCallbacks.getItemAt(i) as Vector.<Function>);
				
				if (callbacks != null)
				{
					var newCallbacks:Vector.<Function> = new Vector.<Function>();
					
					for (var k:uint = 0; k < callbacks.length; k++)
					{
						if (callbacks[k] != callback)
						{
							newCallbacks.push(callbacks[k]);
						}
					}
					
					this._waitingCallbacks.setItemAt(newCallbacks, i);
				}
			}
		}
		
		protected function onHeartbeat(e:HeartbeatEvent):void
		{
			for (var i:uint = 0; this._waitingCallbacks.length; i++)
			{
				var offset:Number = (this._waitingCallbacks.getKeyAt(i) as Number);
				var callbacks:Vector.<Function> = (this._waitingCallbacks.getItemAt(i) as Vector.<Function>);

				if (Math.abs(e.runningOffset - offset) < SharedTimer.DELAY)
				{
					for (var k:uint = 0; callbacks.length; k++)
					{
						callbacks[k].call();
					}
				}
			}
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
			
			begin = (node.currentBeginInterval);
			end = (node.currentEndInterval);
			
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
				this.ownerDocument.removeEventListener(MutationEvent.DOM_CHARACTER_DATA_MODIFIED, this.onMutationEvent, false);
				this.ownerDocument.removeEventListener(MutationEvent.DOM_NODE_INSERTED, this.onMutationEvent, false);
				this.ownerDocument.removeEventListener(MutationEvent.DOM_NODE_INSERTED_INTO_DOCUMENT, this.onMutationEvent, false);
				this.ownerDocument.removeEventListener(MutationEvent.DOM_NODE_REMOVED, this.onMutationEvent, false);
				this.ownerDocument.removeEventListener(MutationEvent.DOM_NODE_REMOVED_FROM_DOCUMENT, this.onMutationEvent, false);
				this.ownerDocument.removeEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, this.onMutationEvent, false);
				
				container.startup();
				
				this.rebuild();
			}
		}
	}
}