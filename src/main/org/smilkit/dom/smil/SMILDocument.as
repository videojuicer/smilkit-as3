package org.smilkit.dom.smil
{
	import flash.errors.IllegalOperationError;
	
	import org.smilkit.dom.Document;
	import org.smilkit.dom.Element;
	import org.smilkit.view.ViewportObjectPool;
	import org.smilkit.w3c.dom.IDocumentType;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementExclusiveTimeContainer;
	import org.smilkit.w3c.dom.smil.IElementParallelTimeContainer;
	import org.smilkit.w3c.dom.smil.IElementSequentialTimeContainer;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.smilkit.w3c.dom.smil.ISMILRefElement;
	import org.smilkit.w3c.dom.smil.ISMILRegionElement;
	import org.smilkit.w3c.dom.smil.ISMILSwitchElement;
	import org.smilkit.w3c.dom.smil.ITimeList;
	
	public class SMILDocument extends Document implements ISMILDocument
	{
		protected var _beginList:ITimeList;
		protected var _endList:ITimeList;
		
		protected var _viewportObjectPool:ViewportObjectPool;
		
		public function SMILDocument(documentType:IDocumentType)
		{
			super(documentType);
		}
		
		public function get viewportObjectPool():ViewportObjectPool
		{
			return this._viewportObjectPool;
		}
		
		public function set viewportObjectPool(viewportObjectPool:ViewportObjectPool):void
		{
			this._viewportObjectPool = viewportObjectPool;
		}
		
		public function get timeChildren():INodeList
		{
			return new ElementTimeNodeList(this);
		}
		
		public function activeChildrenAt(instant:Number):INodeList
		{
			return null;
		}
		
		public function get begin():ITimeList
		{
			if (this._beginList == null)
			{
				this._beginList = ElementTime.parseTimeAttribute("0", this, true);
			}
			
			return this._beginList;
		}
		
		public function set begin(begin:ITimeList):void
		{
			throw new IllegalOperationError("Unable to write begin property on SMILDocument.");
		}
		
		public function get end():ITimeList
		{
			if (this._endList == null)
			{
				this._endList = ElementTime.parseTimeAttribute(null, (this as IElement), false);
			}
			return this._endList;
		}
		
		public function set end(end:ITimeList):void
		{
			throw new IllegalOperationError("Unable to write end property on SMILDocument.");
		}
		
		public function get dur():Number
		{
			var body:ElementTimeContainer = (this.getElementsByTagName("body").item(0) as ElementTimeContainer);
			
			if (body != null)
			{
				return body.dur;
			}
			
			return 0;
		}
		
		public function set dur(dur:Number):void
		{
			throw new IllegalOperationError("Unable to write duration property on SMILDocument.");
		}
		
		public function get restart():uint
		{
			return 0;
		}
		
		public function set restart(restart:uint):void
		{
			throw new IllegalOperationError("Unable to write restart property on SMILDocument.");
		}
		
		public function get fill():uint
		{
			return 0;
		}
		
		public function set fill(fill:uint):void
		{
			throw new IllegalOperationError("Unable to write fill property on SMILDocument.");
		}
		
		public function get repeatCount():Number
		{
			return 0;
		}
		
		public function set repeatCount(repeatCount:Number):void
		{
			throw new IllegalOperationError("Unable to write repeatCount property on SMILDocument.");
		}
		
		public function get repeatDur():Number
		{
			return 0;
		}
		
		public function set repeatDur(repeatDur:Number):void
		{
			throw new IllegalOperationError("Unable to write repeatDur property on SMILDocument.");
		}
		
		public function beginElement():Boolean
		{
			return false;
		}
		
		public function endElement():Boolean
		{
			return false;
		}
		
		public function pauseElement():void
		{
			// pause children
		}
		
		public function resumeElement():void
		{
			// resume children
		}
		
		public function seekElement(seekTo:Number):void
		{
			// seek children
		}
		
		public function createSMILElement(tagName:String):ISMILElement
		{
			return new SMILElement(this, tagName);
		}
		
		public function createMediaElement(tagName:String):ISMILMediaElement
		{
			return new SMILMediaElement(this, tagName);
		}
		
		public function createSequentialElement(tagName:String = "seq"):IElementSequentialTimeContainer
		{
			return new ElementSequentialTimeContainer(this, tagName);
		}
		
		public function createParallelElement(tagName:String = "par"):IElementParallelTimeContainer
		{
			return new ElementParallelTimeContainer(this, tagName);
		}
		
		public function createSwitchElement(tagName:String = "switch"):ISMILSwitchElement
		{
			return new SMILSwitchElement(this, tagName);
		}
		
		public function createReferenceElement(tagName:String = "ref"):ISMILRefElement
		{
			return new SMILRefElement(this, tagName);
		}
		
		public function createRegionElement(tagName:String = "region"):ISMILRegionElement
		{
			return new SMILRegionElement(this, tagName);
		}
		
		public function createExclusiveElement(tagName:String = "excl"):IElementExclusiveTimeContainer
		{
			return null;
		}
	}
}