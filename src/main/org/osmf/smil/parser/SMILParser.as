/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.smil.parser
{
	import flash.errors.IllegalOperationError;
	
	import org.osmf.smil.model.SMILDocument;
	import org.osmf.smil.model.SMILElement;
	import org.osmf.smil.model.SMILElementType;
	import org.osmf.smil.model.SMILLinkElement;
	import org.osmf.smil.model.SMILMediaElement;
	import org.osmf.smil.model.SMILMetaElement;
	import org.osmf.smil.model.SMILRegionElement;
	import org.osmf.utils.TimeUtil;
	import org.smilkit.SMILKit;

	/**
	 * Parses a SMIL file and creates a document object
	 * model.
	 */
	public class SMILParser
	{
		/**
		 * Parses a SMIL file and returns a <code>SMILDocument</code>.
		 */
		public function parse(rawData:String):SMILDocument
		{
			if (rawData == null || rawData == "")
			{
				throw new ArgumentError();
			}

			var smilDocument:SMILDocument = new SMILDocument();

			try
			{			
				var xml:XML = new XML(rawData);
				
				parseHead(smilDocument, xml);
				parseBody(smilDocument, xml);
			}
			catch (err:Error)
			{
				SMILKit.logger.debug("Unhandled exception in SMILParser : "+err.message);
				throw err;
			}
			
			return smilDocument;
		}
		
		private function parseHead(doc:SMILDocument, xml:XML):void
		{
			var ns:Namespace = xml.namespace();
			var head:XMLList = xml..ns::head;
			
			if (head.length() > 0)
			{
				parseElement(doc, head.children());
			}
		}
		
		private function parseBody(doc:SMILDocument, xml:XML):void
		{
			var ns:Namespace = xml.namespace();
			var body:XMLList = xml..ns::body;
			
			// The <body> tag is required
			if (body.length() <= 0)
			{
				SMILKit.logger.debug(INVALID_FILE_MISSING_BODY_TAG);
				
				throw new IllegalOperationError(INVALID_FILE_MISSING_BODY_TAG);
			}
			else
			{
				parseElement(doc, body.children());
			}
		}
		
		/**
		 * Recursive function that parses all elements in a SMIL file.
		 */
		private function parseElement(doc:SMILDocument, children:XMLList, parent:SMILElement=null):void
		{
			for (var i:uint = 0; i < children.length(); i++)
			{
				var childNode:XML = children[i];
				var element:SMILElement;
				
				switch (childNode.nodeKind())
				{
					case "element":
						switch (childNode.localName())
						{
							case SMILElementType.SEQUENCE:
								element = new SMILElement(SMILElementType.SEQUENCE);
								break;
							case SMILElementType.PARALLEL:
								element = new SMILElement(SMILElementType.PARALLEL);
								break;
							case SMILElementType.SWITCH:
								element = new SMILElement(SMILElementType.SWITCH);
								break;
							case SMILElementType.IMAGE:
							case SMILElementType.VIDEO:
							case SMILElementType.AUDIO:
							case SMILElementType.REFERENCE:
								element = parseMediaElement(childNode);
								break;
							case SMILElementType.META:
								element = parseMetaElement(childNode);
								
								doc.addMetadata((element as SMILMetaElement));
								break;
							case SMILElementType.REGION:
								element = parseRegionElement(childNode);
								
								doc.addRegion((element as SMILRegionElement));
								break;
							case SMILElementType.LINK:
								element = parseLinkElement(childNode);
								break;
						}
						break;
				}
				
				parseElement(doc, childNode.children(), element);
				
				if (element != null)
				{
					if (parent != null)
					{
						parent.addChild(element);
					}
					else
					{
						doc.addElement(element);
					}
				}
			}	
		}
		
		private function parseMediaElement(node:XML):SMILMediaElement
		{
			var element:SMILMediaElement;
			
			switch (node.nodeKind())
			{
				case "element":
					switch (node.localName())
					{
						case SMILElementType.VIDEO:
							element = new SMILMediaElement(SMILElementType.VIDEO);
							break;
						case SMILElementType.IMAGE:
							element = new SMILMediaElement(SMILElementType.IMAGE);
							break;
						case SMILElementType.AUDIO:
							element = new SMILMediaElement(SMILElementType.AUDIO);
							break;
						case SMILElementType.REFERENCE:
							element = new SMILMediaElement(SMILElementType.REFERENCE);
							break;
					}
					break;
			}
			
			if (element != null)
			{
				element.src = node.@[ATTRIB_SOURCE];
				
				if (node.@[ATTRIB_BITRATE] != null)
				{
					element.bitrate = node.@[ATTRIB_BITRATE];
				}
				
				if (node.@[ATTRIB_DURATION] != null)
				{
					element.duration = TimeUtil.parseTime(node.@[ATTRIB_DURATION]);
				}
				
				if (node.@[ATTRIB_CLIP_BEGIN] != null)
				{
					element.clipBegin = TimeUtil.parseTime(node.@[ATTRIB_CLIP_BEGIN]);
				}
				
				if (node.@[ATTRIB_CLIP_END] != null)
				{
					element.clipEnd = TimeUtil.parseTime(node.@[ATTRIB_CLIP_END]);
				}
				
				if (node.@[ATTRIB_REGION] != null)
				{
					element.region = node.@[ATTRIB_REGION];
				}
				
				for (var i:uint = 0; i < node.children().length(); i++)
				{
					var el:XML = node.children()[i];
					
					if (el.localName() == "param")
					{
						element.addParam(el.@[ATTRIB_NAME], el.@[ATTRIB_VALUE]);
					}
				}
			}
			
			return element;
		}
		
		private function parseMetaElement(node:XML):SMILMetaElement
		{
			var element:SMILMetaElement;
			
			switch (node.nodeKind())
			{
				case "element":
					switch (node.localName())
					{
						case SMILElementType.META:
							element = new SMILMetaElement();
							element.base = node.@[ATTRIB_META_BASE];
							element.name = node.@[ATTRIB_NAME];
							element.content = node.@[ATTRIB_CONTENT];
							break;
					}
					break;
			}
			
			return element;
		}
		
		private function parseLinkElement(node:XML):SMILLinkElement
		{
			var element:SMILLinkElement;
			
			switch (node.nodeKind())
			{
				case "element":
					switch (node.localName())
					{
						case SMILElementType.LINK:
							element = new SMILLinkElement();
							element.src = node.@[ATTRIB_HREF];
							break;
					}
					break;
			}
			
			return element;
		}
		
		private function parseRegionElement(node:XML):SMILRegionElement
		{
			var element:SMILRegionElement;
			
			switch (node.nodeKind())
			{
				case "element":
					switch (node.localName())
					{
						case SMILElementType.REGION:
							element = new SMILRegionElement();
							
							var id:String = node.@[ATTRIB_ID];
							
							if (id == null || id == "")
							{
								for each (var attr:XML in node.attributes())
								{
									if (attr.localName() == "id")
									{
										id = attr.toString();
									}
								}
							}
							
							element.id = id;
							element.width = node.@[ATTRIB_WIDTH];
							element.height = node.@[ATTRIB_HEIGHT];
							element.left = node.@[ATTRIB_LEFT];
							element.right = node.@[ATTRIB_RIGHT];
							element.top = node.@[ATTRIB_TOP];
							element.bottom = node.@[ATTRIB_BOTTOM];
							element.index = node.@[ATTRIB_INDEX];
							break;
					}
					break;
			}
			
			return element;
		}
		
		// SMIL tag attributes
		private static const ATTRIB_SOURCE:String = "src";
		private static const ATTRIB_BITRATE:String = "system-bitrate";
		private static const ATTRIB_DURATION:String = "dur";
		private static const ATTRIB_META_BASE:String = "base";
		private static const ATTRIB_CLIP_BEGIN:String = "clipBegin";
		private static const ATTRIB_CLIP_END:String = "clipEnd";
		private static const ATTRIB_ID:String = "id";
		private static const ATTRIB_WIDTH:String = "width";
		private static const ATTRIB_HEIGHT:String = "height";
		private static const ATTRIB_LEFT:String = "left";
		private static const ATTRIB_RIGHT:String = "right";
		private static const ATTRIB_TOP:String = "top";
		private static const ATTRIB_BOTTOM:String = "bottom";
		private static const ATTRIB_REGION:String = "region";
		private static const ATTRIB_INDEX:String = "z-index";
		private static const ATTRIB_NAME:String = "name";
		private static const ATTRIB_CONTENT:String = "content";
		private static const ATTRIB_BACKGROUND_COLOR:String = "backgroundColor";
		private static const ATTRIB_VALUE:String = "value";
		private static const ATTRIB_HREF:String = "href";
		
		// Error messages
		private static const INVALID_FILE_MISSING_BODY_TAG:String = "Invalid SMIL file: <body> tag is missing.";
	}
}
