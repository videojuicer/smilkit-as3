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
package org.smilkit.parsers
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.smilkit.dom.DocumentType;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.utilkit.util.UrlUtil;

	public class BostonDOMParser extends EventDispatcher
	{
		protected var _initialParent:INode = null;
		protected var _loader:URLLoader;
		
		public function BostonDOMParser()
		{
			
		}

		public function load(systemID:String, parent:INode = null):void
		{
			this._initialParent = parent;
			
			this._loader = new URLLoader();
			
			this._loader.addEventListener(Event.COMPLETE, this.onLoaderComplete);
			this._loader.addEventListener(IOErrorEvent.IO_ERROR, this.onLoaderIOError);
			this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoaderSecurityError);
			
			this._loader.load(new URLRequest(UrlUtil.addCacheBlocking(systemID)));
		}

		protected function onLoaderComplete(e:Event):void
		{
			this.dispatchEvent(e.clone());
			
			this.parse(this._loader.data);
		}
		
		protected function onLoaderIOError(e:IOErrorEvent):void
		{
			this.dispatchEvent(e.clone());
		}
		
		protected function onLoaderSecurityError(e:SecurityErrorEvent):void
		{
			this.dispatchEvent(e.clone());
		}
		
		public function parse(document:String, parent:INode = null):INode
		{
			var xml:XML = new XML(document);
			var root:XML = xml;
			
			if (parent == null && this._initialParent == null)
			{
				this._initialParent = new SMILDocument(new DocumentType(null, "smil", "-//W3C//DTD SMIL 3.0 Language//EN", "http://www.w3.org/2008/SMIL30/SMIL30Language.dtd"));
			
				//root = (xml.child("smil")[0] as XML);
			}

			this.parseNode(this._initialParent, root);
			
			this.dispatchEvent(new BostonDOMParserEvent(BostonDOMParserEvent.PARSER_COMPLETE, this._initialParent));
			
			return this._initialParent;
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
			
			if (node.nodeKind() == "text")
			{
				child = parent.ownerDocument.createTextNode(node.toString());
			}
			else
			{
				switch (node.localName().toString())
				{
					case "smil":
						child = (doc as ISMILDocument).createSMILElement("smil");
						break;
					case "switch":
						child = (parent.ownerDocument as ISMILDocument).createSwitchElement();
						break;
					case "excl":
						child = (parent.ownerDocument as ISMILDocument).createExclusiveElement() as INode;
						break;
					case "par":
						child = (parent.ownerDocument as ISMILDocument).createParallelElement() as INode;
						break;
					case "seq":
						child = (doc as ISMILDocument).createSequentialElement() as INode;
						break;
					case "body":
						child = (doc as SMILDocument).createBodyElement("body") as INode;
						break;
					case "video": case "img": case "audio": case "text":
						child = (doc as ISMILDocument).createMediaElement(node.localName());
						break;
					case "ref":
						child = (doc as ISMILDocument).createReferenceElement() as INode;
						break;
					case "region":
						child = (doc as ISMILDocument).createRegionElement("region");
						break;
					default:					
						child = (doc as ISMILDocument).createElement(node.localName());
						break;
				}
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
			
			// and then transverse 
			for each (var n:XML in node.children())
			{
				this.parseNode(child, n);
			}
			
			// stack the child on the node
			if (parent != null)
			{
				parent.appendChild(child);
			}
			
			return child;
		}
	}
}