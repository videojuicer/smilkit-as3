package org.smilkit.dom.smil
{
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.ElementLoadableContainer;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	
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
				this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, this.bytesLoaded, this.bytesTotal));
			}
		}
		
		public function set childrenBytesTotal(t:int):void
		{
			if(this._childrenBytesTotal != t)
			{
				this._childrenBytesTotal = t;
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