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
	import org.smilkit.w3c.dom.IDocument;
	
	public class CharacterData extends ChildNode
	{
		protected var _data:String;
		
		public function CharacterData(owner:IDocument, data:String)
		{
			super(owner);
			
			this._data = data;
		}
		
		public override function get nodeValue():String
		{
			return this._data;
		}
		
		public override function set nodeValue(value:String):void
		{
			this.setNodeValue(value, false);
			
			(this.ownerDocument as Document).replacedText(this);
		}
		
		public function get data():String
		{
			return this._data;
		}
		
		public function set data(value:String):void
		{
			this.nodeValue = value;
		}
		
		public override function get length():int
		{
			return this._data.length;
		}
		
		public function appendData(data:String):void
		{
			if (data == null)
			{
				return;
			}
			
			this.nodeValue = this._data + data;
		}
		
		protected function setNodeValue(value:String, replace:Boolean):void
		{
			var oldValue:String = this._data;
			
			(this.ownerDocument as Document).modifyingCharacterData(this, replace);
			
			this._data = value;
			
			(this.ownerDocument as Document).modifiedCharacterData(this, oldValue, value, replace);
		}
		
		public function deleteData(offset:int, count:int):void
		{
			if (count < 0)
			{
				throw new DOMException(DOMException.INDEX_SIZE_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "INDEX_SIZE_ERR"));
			}
			
			try
			{
				var tailLength:int = Math.max(this._data.length - count - offset, 0);
				var tailValue:String = tailLength > 0 ? this._data.substr(offset + count, offset + count + tailLength) : "";
				var value:String = this._data.substr(0, offset);
				
				this.setNodeValue(value, false);
				
				(this.ownerDocument as Document).deletedText(this, offset, count);
			}
			catch (e:ArgumentError)
			{
				throw new DOMException(DOMException.INDEX_SIZE_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "INDEX_SIZE_ERR"));
			}
		}
		
		public function insertData(offset:int, data:String):void
		{
			// insert data
		}
		
		public function replaceData(offset:int, count:int, data:String):void
		{
			
		}
		
		public function substringData(offset:int, count:int):String
		{
			if (count < 0 || offset < 0 || offset > this.length - 1)
			{
				throw new DOMException(DOMException.INDEX_SIZE_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "INDEX_SIZE_ERR"));
			}
			
			return this._data.substr(offset, Math.min(offset + count, this.length));
		}
	}
}