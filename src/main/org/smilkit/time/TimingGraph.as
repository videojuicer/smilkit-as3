package org.smilkit.time
{
	import flash.events.EventDispatcher;
	
	import org.smilkit.dom.events.EventListener;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.events.TimingGraphEvent;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class TimingGraph extends EventDispatcher
	{
		protected var _elements:Vector.<ResolvedTimeElement>;
		protected var _document:SMILDocument;
		
		protected var _eventListener:EventListener;
		
		public function TimingGraph(document:ISMILDocument)
		{
			this._elements = new Vector.<ResolvedTimeElement>();
			this._document = document as SMILDocument;
			
			this._eventListener = new EventListener(this.onMutationEvent);
			
			this._document.addEventListener(MutationEvent.DOM_ATTR_MODIFIED, this._eventListener, false);
			this._document.addEventListener(MutationEvent.DOM_CHARACTER_DATA_MODIFIED, this._eventListener, false);
			this._document.addEventListener(MutationEvent.DOM_NODE_INSERTED, this._eventListener, false);
			this._document.addEventListener(MutationEvent.DOM_NODE_INSERTED_INTO_DOCUMENT, this._eventListener, false);
			this._document.addEventListener(MutationEvent.DOM_NODE_REMOVED, this._eventListener, false);
			this._document.addEventListener(MutationEvent.DOM_NODE_REMOVED_FROM_DOCUMENT, this._eventListener, false);
			this._document.addEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, this._eventListener, false);
		}
		
		public function get elements():Vector.<ResolvedTimeElement>
		{
			return this._elements;
		}
		
		public function get document():ISMILDocument
		{
			return this._document;
		}
		
		public function rebuild():void
		{
			// only go from the body, no point running through the other parts of a smil document
			this.iterateTree(this._document.getElementsByTagName("body").item(0) as INode);
			
			this.dispatchEvent(new TimingGraphEvent(TimingGraphEvent.REBUILD));
		}
		
		protected function iterateTree(node:INode):void
		{
			var nodes:INodeList = node.childNodes;
			
			for (var i:int = 0; i < nodes.length; i++)
			{
				var child:INode = nodes.item(i);
				
				if (child.hasChildNodes())
				{
					this.iterateTree(child);
				}
				
				if (child is ISMILMediaElement)
				{
					var el:SMILMediaElement = (child as SMILMediaElement);
					
					// check if element is resolved
					if (true)
					{
						var resolvedTimeElement:ResolvedTimeElement = new ResolvedTimeElement(el, 0, 0);
						
						this._elements.push(resolvedTimeElement);
						
						this.dispatchEvent(new TimingGraphEvent(TimingGraphEvent.ELEMENT_ADDED));
					}
				}
			}
		}
		
		protected function onMutationEvent(e:MutationEvent):void
		{
			this.rebuild();
		}
	}
}