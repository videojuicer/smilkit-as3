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
package org.smilkit.dom
{
	import org.smilkit.w3c.dom.ICharacterData;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IText;
	
	public class Text extends CharacterData implements ICharacterData, IText
	{
		public function Text(owner:IDocument, data:String)
		{
			super(owner, data);
		}
		
		public override function get nodeType():int
		{
			return Node.TEXT_NODE;
		}
		
		public override function get nodeName():String
		{
			return "#text";
		}
		
		public function splitText(offset:int):IText
		{
			if (offset < 0 || offset > this._data.length)
			{
				throw new DOMException(DOMException.INDEX_SIZE_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "INDEX_SIZE_ERR"));
			}
			
			var text:IText = this.ownerDocument.createTextNode(this._data.substr(offset));
			
			this.nodeValue = this._data.substr(0, offset);
			
			if (this.parentNode != null)
			{
				this.parentNode.insertBefore(text, this.nextSibling);
			}
			
			return text;
		}
	}
}