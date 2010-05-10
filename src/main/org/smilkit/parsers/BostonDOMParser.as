package org.smilkit.parsers
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.xml.XMLDocument;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Document;
	import org.smilkit.dom.DocumentType;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.Node;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.smil.IElementTime;
	import org.smilkit.w3c.dom.smil.ISMILDocument;

	public class BostonDOMParser
	{
		public function BostonDOMParser()
		{
			
		}

		public function load(systemId:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				this.parse(loader.data);
			});
		}
		
		public function parse(document:String):IDocument
		{
			var xml:XML = new XML(document);
			var doc:IDocument = new SMILDocument(new DocumentType(null, "smil", "-//W3C//DTD SMIL 3.0 Language//EN", "http://www.w3.org/2008/SMIL30/SMIL30Language.dtd"));
			
			this.parseNode(doc, xml);
			
			return doc;
		}
		
		protected function parseNode(parent:INode, node:XML):INode
		{
			var child:INode = null;
			var doc:IDocument = null;
			
			if (parent == null)
			{
				
			}
			else if (parent.ownerDocument == null && parent is IDocument)
			{
				doc = parent as IDocument;
			}
			else
			{
				doc = parent.ownerDocument;
			}
			
			switch (node.localName().toString())
			{
				case "smil":
					child = (doc as ISMILDocument).createSMILElement("smil");
					break;
				case "switch":
					child = (parent.ownerDocument as ISMILDocument).createSwitchElement();
					break;
				case "par":
					child = (parent.ownerDocument as ISMILDocument).createParallelElement() as INode;
					break;
				case "seq":
					child = (doc as ISMILDocument).createSequentialElement() as INode;
					break;
				case "body":
					child = (doc as ISMILDocument).createSequentialElement("body") as INode;
					break;
				case "video": case "img": case "audio": case "text":
					child = (doc as ISMILDocument).createMediaElement(node.localName());
					break;
				case "ref":
					child = (doc as ISMILDocument).createReferenceElement() as INode;
				default:					
					child = (doc as ISMILDocument).createElement(node.localName());
					break;
			}
			
			if (child == null)
			{
				throw new IllegalOperationError("Failed to create node of type '"+node.localName().toString()+"'.");
			}
			
			var el:IElement = (child as IElement);

			// parse attributes
			if (node.attributes().length() > 0)
			{
				for each (var a:XML in node.attributes())
				{
					if (a.localName() == "id")
					{
						(el as Element).setIdAttribute(a.toString());
					}
					else
					{
						el.setAttribute(a.localName(), a.toString());
					}
				}
			}
			
			if (node.valueOf() != null)
			{
				child.nodeValue = node.valueOf();
			}
			
			// stack the child on the node
			if (parent != null)
			{
				parent.appendChild(child);
			}
			
			// and then transverse 
			for each (var n:XML in node.children())
			{
				this.parseNode(child, n);
			}
			
			return child;
		}
	}
}