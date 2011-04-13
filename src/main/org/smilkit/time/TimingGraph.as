package org.smilkit.time
{
	import flash.events.EventDispatcher;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.SMILSwitchElement;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.dom.smil.TimeList;
	import org.smilkit.dom.smil.events.SMILMutationEvent;
	import org.smilkit.events.TimingGraphEvent;
	import org.smilkit.view.ViewportObjectPool;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.utilkit.logger.Logger;

	/**
	 * An instance of TimingGraph is used to store the timings of the elements that are to be displayed
	 * 
	 * The TimingGraph listens for changes in the ISMILDocument that is past to it and rebuilds itself should the ISMILdocument change
	 * 
	 */	
	public class TimingGraph extends EventDispatcher
	{
		protected var _elements:Vector.<TimingNode>;
		protected var _objectPool:ViewportObjectPool;
		
		/**
		 * Create the instance of the _element, and stores the reference to ISMILdocument in _document
		 * Adds listeners to _document to listener for MutationEvents.
		 * 
		 * @param document
		 * @constructor
		 */		
		public function TimingGraph(objectPool:ViewportObjectPool)
		{
			this._elements = new Vector.<TimingNode>();
			this._objectPool = objectPool;
			
			// non-dom mutation events
			this.document.addEventListener(MutationEvent.NON_DOM_HANDLER_MODIFIED, this.onHandlerModified, false);
			
			// dom mutation events
			this.document.addEventListener(MutationEvent.DOM_ATTR_MODIFIED, this.onMutationEvent, false);
			this.document.addEventListener(MutationEvent.DOM_CHARACTER_DATA_MODIFIED, this.onMutationEvent, false);
			this.document.addEventListener(MutationEvent.DOM_NODE_INSERTED, this.onMutationEvent, false);
			this.document.addEventListener(MutationEvent.DOM_NODE_INSERTED_INTO_DOCUMENT, this.onMutationEvent, false);
			this.document.addEventListener(MutationEvent.DOM_NODE_REMOVED, this.onMutationEvent, false);
			this.document.addEventListener(MutationEvent.DOM_NODE_REMOVED_FROM_DOCUMENT, this.onMutationEvent, false);
			this.document.addEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, this.onMutationEvent, false);
		
			// smil dom mutation events
			this.document.addEventListener(SMILMutationEvent.DOM_VARIABLES_INSERTED, this.onDocumentVariablesModified, false);
			this.document.addEventListener(SMILMutationEvent.DOM_VARIABLES_MODIFIED, this.onDocumentVariablesModified, false);
			this.document.addEventListener(SMILMutationEvent.DOM_VARIABLES_REMOVED, this.onDocumentVariablesModified, false);
		}
		
		public function get elements():Vector.<TimingNode>
		{
			return this._elements;
		}
		
		public function get document():ISMILDocument
		{
			return this._objectPool.document;
		}
		
		public function get viewportObjectPool():ViewportObjectPool
		{
			return this._objectPool;
		}
		
		/**
		 * Public function used to rebuild the list of ResolvedTimeElements 
		 */		
		public function rebuild():void
		{
			SMILKit.logger.debug("Starting TimingGraph rebuild", this);
			
			this._elements = new Vector.<TimingNode>();
			
			// only go from the body, no point running through the other parts of a smil document
			this.iterateTree(this.document.getElementsByTagName("body").item(0) as INode);
			this.dispatchEvent(new TimingGraphEvent(TimingGraphEvent.REBUILD));
		}
		
		/**
		 * Recursive function used to parse ISMILdocument creating a list of value objects of ResolvedTimeElements 
		 * @param node
		 * 
		 */		
		protected function iterateTree(node:INode):void
		{
			var nodes:INodeList = node.childNodes;
			var containers:Vector.<ElementTimeContainer> = new Vector.<ElementTimeContainer>();
			
			for (var i:int = 0; i < nodes.length; i++)
			{
				var child:INode = nodes.item(i);
				
				containers = this.processNode(containers, child);
			}
			
			if (containers.length > 0)
			{
				for (var j:int = containers.length-1; j >= 0; j--)
				{
					var timeContainer:ElementTimeContainer = containers[j];
					
					timeContainer.resolve();
				}
			}
		}
		
		protected function processNode(containers:Vector.<ElementTimeContainer>, child:INode):Vector.<ElementTimeContainer>
		{
			if (child is ElementTimeContainer)
			{
				var container:ElementTimeContainer = (child as ElementTimeContainer);
				
				SMILKit.logger.debug("Found ElementTimeContainer "+(container.hasAttribute("id") ? container.getAttribute("id") : ""));
				
				containers.push(container);
			}
			
			if (child is ISMILMediaElement)
			{
				var el:SMILMediaElement = (child as SMILMediaElement);
				
				el.resolve();
				
				if (el.handler != null)
				{ 
					var begin:int = Time.UNRESOLVED;
					var end:int = Time.UNRESOLVED;
					
					if ((el.begin as TimeList).resolved)
					{
						begin = el.begin.first.resolvedOffset;
					}
					
					if ((el.end as TimeList).resolved)
					{
						end = el.end.first.resolvedOffset;
					}
					
					SMILKit.logger.debug("TimingGraph rebuild: Adding "+el.tagName+" ("+el.src+") Begin: "+
						((begin == Time.UNRESOLVED)? "UNRESOLVED" : ((begin == Time.INDEFINITE)? "INDEFINITE" : begin))+
						", end: "+
						((end == Time.UNRESOLVED)? "UNRESOLVED" : ((end == Time.INDEFINITE)? "INDEFINITE" : end)), 
						this);
					
					var timeElement:TimingNode = new TimingNode(el, begin, end);
					
					this._elements.push(timeElement);
					
					this.dispatchEvent(new TimingGraphEvent(TimingGraphEvent.ELEMENT_ADDED));
				}
			}
			
			if (child is SMILSwitchElement)
			{
				var switchElement:SMILSwitchElement = (child as SMILSwitchElement);
				var selectedElement:IElement = switchElement.selectedElement;
				
				if (selectedElement != null)
				{
					(selectedElement as ElementTimeContainer).resolve();
					
					containers = this.processNode(containers, selectedElement);
				}
			}
			else if (child.hasChildNodes())
			{
				this.iterateTree(child);
			}
			
			return containers;
		}
		
		/**
		 * Called when the document dispatches the MutationEvents for which the listeners are added in the contructor
		 * @param e
		 * 
		 */		
		protected function onMutationEvent(e:MutationEvent):void
		{
			SMILKit.logger.debug("Received mutation event of type "+e.type+". Attr name: "+e.attrName+", new value: "+e.newValue+" prev value: "+e.prevValue, this);
			this.rebuild();
		}
		
		protected function onHandlerModified(e:MutationEvent):void
		{
			SMILKit.logger.debug("A handler was modified - about to rebuild TimingGraph", this);
			this.rebuild();
		}
		
		protected function onDocumentVariablesModified(e:SMILMutationEvent):void
		{
			SMILKit.logger.debug("Received SMIL Mutation event of type "+e.type+". Attr name: "+e.attrName+", new value: "+e.newValue+" prev value: "+e.prevValue, this);
			this.rebuild();
		}
	}
}