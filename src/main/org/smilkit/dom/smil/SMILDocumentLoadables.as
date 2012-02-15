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
package org.smilkit.dom.smil
{
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	
	import org.smilkit.SMILKit;
	
	public class SMILDocumentLoadables extends EventDispatcher
	{
		protected var _document:SMILDocument;
		
		protected var _childrenBytesLoaded:int = 0;
		protected var _childrenBytesTotal:int = 0;
		
		public function SMILDocumentLoadables(doc:SMILDocument)
		{
			this._document = doc;
		}
		
		public function get bytesLoaded():int
		{
			return this._childrenBytesLoaded;
		}
		
		public function get bytesTotal():int
		{
			return this._childrenBytesTotal;
		}
		
		public function set childrenBytesLoaded(l:int):void
		{
			if(this._childrenBytesLoaded != l)
			{
				this._childrenBytesLoaded = l;
				SMILKit.logger.debug("Document loadables at "+((this.bytesLoaded == FileSize.UNRESOLVED)? "UNRESOLVED" : this.bytesLoaded)+"/"+((this.bytesTotal == FileSize.UNRESOLVED)? "UNRESOLVED" : this.bytesTotal), this);
				this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, this.bytesLoaded, this.bytesTotal));
			}
		}
		
		public function set childrenBytesTotal(t:int):void
		{
			if(this._childrenBytesTotal != t)
			{
				this._childrenBytesTotal = t;
				SMILKit.logger.debug("Document loadables at "+((this.bytesLoaded == FileSize.UNRESOLVED)? "UNRESOLVED" : this.bytesLoaded)+"/"+((this.bytesTotal == FileSize.UNRESOLVED)? "UNRESOLVED" : this.bytesTotal), this);
				this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, this.bytesLoaded, this.bytesTotal));
			}
		}
		
		public function resolveChildLoadableSizes():void
		{
			// Grabs the body and pulls the ElementLoadableContainer properties from it
			var root:ElementLoadableContainer = this._document.getElementsByTagName("body").item(0) as ElementLoadableContainer;
			if(root != null)
			{
				this.childrenBytesLoaded = root.bytesLoaded;
				this.childrenBytesTotal = root.bytesTotal;
			}
			else
			{
				SMILKit.logger.error("Document loadables couldn't resolve body tag when trying to total load progress", this);
			}
		}
		
		
	}
}