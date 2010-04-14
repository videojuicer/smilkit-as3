package org.smilkit.dom
{
	import flash.events.IEventDispatcher;
	
	import mx.events.EventListenerRequest;
	
	import org.smilkit.dom.events.Event;
	import org.smilkit.event.EventException;
	import org.smilkit.event.ListenerCount;
	import org.smilkit.util.CollectionList;
	import org.smilkit.util.Hashtable;
	import org.smilkit.util.ListenerEntry;
	import org.smilkit.util.ObjectManager;
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.IDocumentType;
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
		
		public function Document(documentType:IDocumentType)
		{
			super(documentType);
		}
		
		public override function addNodeEventListener(node:INode, type:String, listener:IEventListener, useCapture:Boolean):void
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
		
		public override function removeNodeEventListener(node:INode, type:String, listener:IEventListener, useCapture:Boolean):void
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
		
		public override function dispatchNodeEvent(node:INode, event:IEvent):Boolean
		{
			if (event == null)
			{
				return false;
			}
			
			var e:Event = (event as Event);
			
			if (e.initialized || e.type == null || e.type == "")
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
						var listeners:Vector.<ListenerEntry> = ObjectManager.clone(nodeListeners) as Vector.<ListenerEntry>;
						
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
					listeners = ObjectManager.clone(nodeListeners) as Vector.<ListenerEntry>;
					
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
							var tlisteners:Vector.<ListenerEntry> = ObjectManager.clone(nodeListeners) as Vector.<ListenerEntry>;
							
							for (var t:int = 0; j < tlisteners.length; j++)
							{
								var tle:ListenerEntry = tlisteners[j];
								
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
		
		protected function getEventListeners(node:INode):Vector.<ListenerEntry>
		{
			if (this._eventListeners == null)
			{
				return null;
			}
			
			return (this._eventListeners.getItem(node) as Vector.<ListenerEntry>);
		}
		
		protected function setEventListeners(node:INode, listeners:Vector.<ListenerEntry>):void
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
	}
}