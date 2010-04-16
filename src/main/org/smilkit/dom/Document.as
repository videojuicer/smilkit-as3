package org.smilkit.dom
{
	import flash.events.IEventDispatcher;
	
	import mx.events.EventListenerRequest;
	import mx.utils.ObjectUtil;
	
	import org.smilkit.collections.Hashtable;
	import org.smilkit.collections.List;
	import org.smilkit.collections.ListenerEntry;
	import org.smilkit.dom.events.Event;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.events.EventException;
	import org.smilkit.events.ListenerCount;
	import org.smilkit.util.ObjectManager;
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.IAttr;
	import org.smilkit.w3c.dom.IDocumentType;
	import org.smilkit.w3c.dom.INamedNodeMap;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.events.IEvent;
	import org.smilkit.w3c.dom.events.IEventListener;
	import org.smilkit.w3c.dom.events.IEventTarget;
	
	/**
	 * The document class represents an XML document via the W3C DOM Level 2 standard.
	 * The document provides factory methods for the creation of child objects that link
	 * to the document they were created on, this is the only method for child creation
	 * as objects must always exist on a <code>IDocument</code>.
	 * 
	 * @see org.smilkit.dom.CoreDocument
	 * @see org.smilkit.w3c.dom.IDocument
	 */ 
	public class Document extends CoreDocument
	{
		protected var _eventListeners:Hashtable;
		protected var _mutationEvents:Boolean = false;
		protected var _savedEnclosingAttr:EnclosingAttr;
		protected var _iterators:Array;
		protected var _ranges:Array;
		protected var _changes:int = 0;
		
		public function Document(documentType:IDocumentType)
		{
			super(documentType);
		}
		
		/**
		 * Specifies whether mutation events should be fired.
		 */
		internal function get mutationEvents():Boolean
		{
			return this._mutationEvents;
		}
		
		/**
		 * Specifies whether mutation events should be fired.
		 */
		internal function set mutationEvents(value:Boolean):void
		{
			this._mutationEvents = value;
		}
		
		/**
		 * Returns the number of changes that have occured on this node.
		 */
		public override function get changes():int
		{
			return this._changes;
		}
		
		/**
		 * Create a new <code>IEvent</code> instance with the specified type.
		 * 
		 * @param type The specified type of <code>IEvent</code> to create.
		 * 
		 * @return The newly created <code>IEvent</code> instance.
		 * 
		 * @exception DOMException.NOT_SUPPORTED_ERR, raised if the <code>IEvent</code> type is unsupported.
		 */
		public function createEvent(type:String):IEvent
		{
			if (type == "Events" || type == "Event")
			{
				return new Event();
			}
			else if (type == "MutationEvents" || type == "MutationEvent")
			{
				return new MutationEvent();
			}
			else if (type == "UIEvents" || type == "UIEvent")
			{
				throw new DOMException(DOMException.NOT_SUPPORTED_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_SUPPORTED_ERR"));
			}
			else if (type == "MouseEvents" || type == "MouseEvent")
			{
				throw new DOMException(DOMException.NOT_SUPPORTED_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_SUPPORTED_ERR"));
			}
			else
			{
				throw new DOMException(DOMException.NOT_SUPPORTED_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_SUPPORTED_ERR"));
			}
		}
		
		/**
		 * Increments the number of changes on this <code>Node</code>
		 */
		protected override function changed():void
		{
			this._changes++;
		}
		
		/**
		 * Add the specified <code>IEventListener</code> to the stack of registered listeners for the <code>INode</code>.
		 * 
		 * @param node The <code>INode</code> instance to register the event for.
		 * @param type The event name to listen for.
		 * @param listener The <code>IEventListener</code> to execute when the event is dispatched.
		 * @param useCapture True to register the listener on the capturing phase rather than at-target or bubbling.
		 */
		internal override function addNodeEventListener(node:INode, type:String, listener:IEventListener, useCapture:Boolean):void
		{
			if (type == null || type == "" || listener == null)
			{
				return;
			}
			
			this.removeNodeEventListener(node, type, listener, useCapture);
			
			var nodeListeners:Vector.<ListenerEntry> = this.getEventListeners(node);
			
			if (nodeListeners == null)
			{
				nodeListeners = new Vector.<ListenerEntry>();
				
				this.setEventListeners(node, nodeListeners);
			}

			nodeListeners.push(new ListenerEntry(type, listener, useCapture));
			
			var listenerCount:ListenerCount = ListenerCount.lookup(type);
			
			if (useCapture)
			{
				listenerCount.captures++;
				listenerCount.total++;
			}
			else
			{
				listenerCount.bubbles++;
				listenerCount.total++;
			}
		}
		
		/**
		 * Remove the specified <code>IEventListener</code> from the stack of registered listeners.
		 * 
		 * @param node The <code>INode</code> to remove the listener from.
		 * @param type The event name to listen for.
		 * @param listener The <code>IEventListener</code> to execute when the event is dispatched.
		 * @param useCapture True to register the listener on the capturing phase rather than at-target or bubbling.
		 */
		internal override function removeNodeEventListener(node:INode, type:String, listener:IEventListener, useCapture:Boolean):void
		{
			if (type == null || type == "" || listener == null)
			{
				return;
			}
			
			var nodeListeners:Vector.<ListenerEntry> = this.getEventListeners(node);
			
			if (nodeListeners == null)
			{
				return;
			}
			
			var newListeners:Vector.<ListenerEntry> = new Vector.<ListenerEntry>();
			
			for (var i:int = nodeListeners.length - 1; i >= 0; i--)
			{
				var entry:ListenerEntry = nodeListeners[i];
				
				if (entry.useCapture == useCapture && entry.listener == listener && entry.type == type)
				{
					var listenerCount:ListenerCount = ListenerCount.lookup(type);
					
					if (useCapture)
					{
						listenerCount.captures--;
						listenerCount.total--;
					}
					else
					{
						listenerCount.bubbles--;
						listenerCount.total--;
					}
				}
				else
				{
					newListeners.push(entry);
				}
			}
			
			if (newListeners.length == 0)
			{
				this.setEventListeners(node, null);
			}
			else
			{
				this.setEventListeners(node, newListeners);
			}
		}
		
		/**
		 * Dispatch the specified <code>IEvent</code> through the DOM.
		 * 
		 * @param node The <code>INode> to dispatch the event on.
		 * @param event The <code>IEvent</code> instance to dispatch.
		 * 
		 * @return Returns <code>true</code> if the event's <code>preventDefault</code> was invoked, otherwise <code>false</code>.
		 */
		internal override function dispatchNodeEvent(node:INode, event:IEvent):Boolean
		{
			if (event == null)
			{
				return false;
			}
			
			var e:Event = (event as Event);
			
			if (!e.initialized || e.type == null || e.type == "")
			{
				throw new EventException(EventException.UNSPECIFIED_EVENT_TYPE_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "UNSPECIFIED_EVENT_TYPE_ERR"));
			}
			
			var count:ListenerCount = ListenerCount.lookup(e.type);
			
			if (count.total == 0)
			{
				return e.preventDefaultEvent;
			}
			
			e.target = (node as IEventTarget);
			e.stopPropagationEvent = false;
			e.preventDefaultEvent = false;
			
			var pv:Array = new Array(10);
			var p:INode = node;
			var n:INode = p.parentNode;
			
			while (n != null)
			{
				pv.push(n);
				
				p = n;
				n = n.parentNode;
			}
			
			// needs capturing ....
			if (count.captures > 0)
			{
				e.eventPhase = Event.CAPTURING_PHASE;
				
				for (var r:int = pv.length - 1; r >= 0; r--)
				{
					if (e.stopPropagationEvent)
					{
						break;
					}
					
					var rn:INode = (pv[r] as INode);
					e.currentTarget = (rn as IEventTarget);
					
					var nodeListeners:Vector.<ListenerEntry> = this.getEventListeners(node);
					
					if (nodeListeners != null)
					{
						var listeners:Vector.<ListenerEntry> = nodeListeners.concat();
						
						for (var i:int = 0; i < listeners.length; i++)
						{
							var entry:ListenerEntry = listeners[i];
							
							if (entry.useCapture && entry.type == e.type && (nodeListeners.indexOf(entry)))
							{
								try
								{
									entry.listener.handleEvent(e);
								}
								catch (e:Error)
								{
									// catch all
								}
							}
						}
					}
				}
			}
			
			// bubbling ....
			if (count.bubbles > 0)
			{
				e.eventPhase = Event.AT_TARGET;
				e.currentTarget = (node as IEventTarget);
				
				nodeListeners = this.getEventListeners(node);
				
				if (!e.stopPropagationEvent && nodeListeners != null)
				{
					listeners = nodeListeners.concat();
					
					for (var k:int = 0; k < listeners.length; k++)
					{
						var le:ListenerEntry = listeners[k];
						
						if (!le.useCapture && le.type == e.type && (nodeListeners.indexOf(le) != -1))
						{
							try
							{
								le.listener.handleEvent(e);
							}
							catch (e:Error)
							{
								// catch all
							}
						}
					}
				}
				
				if (e.bubbles)
				{
					e.eventPhase = Event.BUBBLING_PHASE;
					
					for (var j:int = 0; j < pv.length; j++)
					{
						if (e.stopPropagationEvent)
						{
							break;
						}
						
						var nn:INode = pv[j] as INode;
						e.currentTarget = (nn as IEventTarget);
						nodeListeners = this.getEventListeners(nn);
						
						if (nodeListeners != null)
						{
							var tlisteners:Vector.<ListenerEntry> = nodeListeners.concat();
							
							for (var t:int = 0; t < tlisteners.length; t++)
							{
								var tle:ListenerEntry = tlisteners[t];
								
								if (!tle.useCapture && tle.type == e.type && (nodeListeners.indexOf(tle) != -1))
								{
									try
									{
										tle.listener.handleEvent(e);
									}
									catch(e:Error)
									{
										// catch all
									}
								}
							}
						}
					}
				}
			}
			
			if (count.defaults > 0 && (!e.cancelable || !e.preventDefaultEvent)) {
				e.eventPhase = Event.DEFAULT_PHASE;
				e.currentTarget = (node as IEventTarget);
			}
			
			return e.preventDefaultEvent;
		}
		
		internal function dispatchEventToSubtree(node:INode, event:IEvent):void
		{
			(node as Node).dispatchEvent(event);
			
			if (node.nodeType == Node.ELEMENT_NODE)
			{
				var a:INamedNodeMap = node.attributes;
				
				for (var i:int = a.length - 1; i >= 0; i--)
				{
					this.dispatchingEventToSubtree(a.item(i), event);
				}
			}
			
			this.dispatchingEventToSubtree(node.firstChild, event);
		}
		
		internal function dispatchingEventToSubtree(node:INode, event:IEvent):void
		{
			if (node == null)
			{
				return;
			}
			
			(node as Node).dispatchEvent(event);
			
			if (node.nodeType == Node.ELEMENT_NODE)
			{
				var a:INamedNodeMap = node.attributes;
				
				for (var i:int = a.length - 1; i >= 0; i--)
				{
					this.dispatchingEventToSubtree(a.item(i), event);
				}
			}
			
			this.dispatchEventToSubtree(node.firstChild, event);
			this.dispatchEventToSubtree(node.nextSibling, event);
		}
		
		internal function saveEnclosingAttr(node:INode):void
		{
			this._savedEnclosingAttr = null;
			
			var lc:ListenerCount = ListenerCount.lookup(MutationEvent.DOM_ATTR_MODIFIED);
			
			if (lc.total > 0)
			{
				var eventAncestor:INode = node;
				
				while (true)
				{
					if (eventAncestor == null)
					{
						return;
					}
					
					var type:int = eventAncestor.nodeType;
					
					if (type == Node.ATTRIBUTE_NODE)
					{
						var retval:EnclosingAttr = new EnclosingAttr();
						retval.node = eventAncestor as IAttr;
						retval.oldValue = retval.node.nodeValue;
						
						this._savedEnclosingAttr = retval;
						
						return;
					}
					else if (type == Node.ENTITY_REFERENCE_NODE)
					{
						eventAncestor = eventAncestor.parentNode;
					}
					else if (type == Node.TEXT_NODE)
					{
						eventAncestor = eventAncestor.parentNode;
					}
					else
					{
						return;
					}
				}
			}
		}
		
		internal function getEventListeners(node:INode):Vector.<ListenerEntry>
		{
			if (this._eventListeners == null)
			{
				return null;
			}
			
			return (this._eventListeners.getItem(node) as Vector.<ListenerEntry>);
		}
		
		internal function setEventListeners(node:INode, listeners:Vector.<ListenerEntry>):void
		{
			if (this._eventListeners == null)
			{
				this._eventListeners = new Hashtable();
			}
			
			if (listeners == null)
			{
				this._eventListeners.removeItem(node);
				
				if (this._eventListeners.isEmpty)
				{
					this._mutationEvents = false;
				}
			}
			else
			{
				this._eventListeners.setItem(node, listeners);
				this._mutationEvents = true;
			}
		}
		
		internal function insertingNode(node:INode, replace:Boolean):void
		{
			if (this.mutationEvents)
			{
				if (!replace)
				{
					this.saveEnclosingAttr(node);
				}
			}
		}
		
		internal function insertedNode(node:INode, newInternal:INode, replace:Boolean):void
		{
			if (this.mutationEvents)
			{
				this.mutationEventsInsertedNode(node, newInternal, replace);
			}
			
			if (this._ranges != null)
			{
				this.notifyRangesInsertedNode(newInternal);
			}
		}
		
		internal function mutationEventsInsertedNode(node:INode, newInternal:INode, replace:Boolean):void
		{
			var lc:ListenerCount = ListenerCount.lookup(MutationEvent.DOM_NODE_INSERTED);
			
			if (lc.total > 0)
			{
				var me:MutationEvent = new MutationEvent();
				me.initMutationEvent(MutationEvent.DOM_NODE_INSERTED, true, false, node, null, null, null, 0);
				
				this.dispatchNodeEvent(node, me);
			}
			
			lc = ListenerCount.lookup(MutationEvent.DOM_NODE_INSERTED_INTO_DOCUMENT);
			
			if (lc.total > 0)
			{
				var eventAncestor:INode = node;
				
				if (this._savedEnclosingAttr != null)
				{
					eventAncestor = (this._savedEnclosingAttr.node.ownerDocument as INode);
				}
				
				if (eventAncestor != null)
				{
					var p:INode = eventAncestor;
					
					while (p != null)
					{
						eventAncestor = p;
						
						if (p.nodeType == Node.ATTRIBUTE_NODE)
						{
							p = p.ownerDocument;
						}
						else
						{
							p = p.parentNode;
						}
					}
					
					if (eventAncestor.nodeType == Node.DOCUMENT_NODE)
					{
						me = new MutationEvent();
						me.initMutationEvent(MutationEvent.DOM_NODE_INSERTED_INTO_DOCUMENT, false, false, null, null, null, null, 0);
						
						this.dispatchEventToSubtree(newInternal, me);
					}
				}
			}
			
			if (!replace)
			{
				this.dispatchAggregateEvent(node, this._savedEnclosingAttr);
			}
		}
		
		internal function notifyRangesInsertedNode(newInternal:INode):void
		{
			//this.removeStaleRangeReferences();
			
		}
		
		internal function removingNode(node:INode, oldChild:INode, replace:Boolean):void
		{
			if (this._ranges != null)
			{
				this.notifyRangesRemovingNode(oldChild);
			}
			
			if (this.mutationEvents)
			{
				this.mutationEventsRemovingNode(node, oldChild, replace);
			}
		}
		
		internal function notifyIteratorsRemovingNode(oldChild:INode):void
		{
			
		}
		
		internal function notifyRangesRemovingNode(oldChild:INode):void
		{
			
		}
		
		internal function mutationEventsRemovingNode(node:INode, oldChild:INode, replace:Boolean):void
		{
			if (!replace)
			{
				this.saveEnclosingAttr(node);
			}
			
			var lc:ListenerCount = ListenerCount.lookup(MutationEvent.DOM_NODE_REMOVED);
			
			if (lc.total > 0)
			{
				var me:MutationEvent = new MutationEvent();
				me.initMutationEvent(MutationEvent.DOM_NODE_REMOVED, true, false, node, null, null, null, 0);
				
				this.dispatchNodeEvent(oldChild, me);
			}
			
			lc = ListenerCount.lookup(MutationEvent.DOM_NODE_REMOVED_FROM_DOCUMENT);
			
			if (lc.total > 0)
			{
				var eventAncestor:INode = this;
				
				if (this._savedEnclosingAttr != null)
				{
					eventAncestor = this._savedEnclosingAttr.node.ownerDocument;
				}
				
				if (eventAncestor != null)
				{
					for (var p:INode = eventAncestor.parentNode; p != null; p = p.parentNode)
					{
						eventAncestor = p;
					}
					
					if (eventAncestor.nodeType == Node.DOCUMENT_NODE)
					{
						me = new MutationEvent();
						me.initMutationEvent(MutationEvent.DOM_NODE_REMOVED_FROM_DOCUMENT, false, false, null, null, null, null, 0);
						
						this.dispatchEventToSubtree(oldChild, me);
					}
				}
			}
		}
		
		internal function removedNode(node:INode, replace:Boolean):void
		{
			if (this.mutationEvents)
			{
				if (!replace)
				{
					this.dispatchAggregateEvent(node, this._savedEnclosingAttr);
				}
			}
		}
		
		internal function replacingNode(node:INode):void
		{
			if (this.mutationEvents)
			{
				this.saveEnclosingAttr(node);
			}
		}
		
		internal function replacedNode(node:INode):void
		{
			if (this.mutationEvents)
			{
				this.saveEnclosingAttr(node);
			}
		}
		
		internal function replacingData(node:INode):void
		{
			if (this.mutationEvents)
			{
				this.dispatchAggregateEvent(node, this._savedEnclosingAttr);
			}
		}
		
		internal function modifiedAttrValue(attr:IAttr, oldValue:String):void
		{
			if (this.mutationEvents)
			{
				this.dispatchAggregateEvents(attr, attr, oldValue, MutationEvent.MODIFICATION);
			}
		}
		
		internal function dispatchAggregateEvent(node:INode, enclosingAttr:EnclosingAttr):void
		{
			if (enclosingAttr != null)
			{
				this.dispatchAggregateEvents(node, enclosingAttr.node, enclosingAttr.oldValue, MutationEvent.MODIFICATION);	
			}
			else
			{
				this.dispatchAggregateEvents(node, null, null, 0);
			}
		}
		
		internal function dispatchAggregateEvents(node:INode, enclosingAttr:IAttr, oldValue:String, change:int):void
		{
			var owner:Node = null;
			
			if (enclosingAttr != null)
			{
				var lc:ListenerCount = ListenerCount.lookup(MutationEvent.DOM_ATTR_MODIFIED);
				owner = (enclosingAttr.ownerElement as Node);
				
				if (lc.total > 0)
				{
					if (owner != null)
					{
						var me:MutationEvent = new MutationEvent();
						me.initMutationEvent(MutationEvent.DOM_ATTR_MODIFIED, true, false, enclosingAttr, oldValue, enclosingAttr.nodeValue, enclosingAttr.nodeName, change);
						
						owner.dispatchEvent(me);
					}
				}
			}
			
			lc = ListenerCount.lookup(MutationEvent.DOM_SUBTREE_MODIFIED);
			
			if (lc.total > 0)
			{
				me = new MutationEvent();
				me.initMutationEvent(MutationEvent.DOM_SUBTREE_MODIFIED, true, false, null, null, null, null, 0);
				
				if (enclosingAttr != null)
				{
					this.dispatchNodeEvent(enclosingAttr, me);
					
					if (owner != null)
					{
						this.dispatchNodeEvent(owner, me);
					}
				}
				else
				{
					this.dispatchNodeEvent(node, me);
				}
			}
		}
	}
}