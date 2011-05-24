package org.smilkit.dom.smil
{
	import flash.errors.IllegalOperationError;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Document;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.view.ViewportObjectPool;
	import org.smilkit.w3c.dom.IDocumentType;
	import org.smilkit.w3c.dom.INode;
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
	
	public class SMILCoreDocument extends Document implements ISMILDocument
	{
		protected var _elementBodyContainer:ElementBodyTimeContainer;
		
		protected var _viewportObjectPool:ViewportObjectPool;
		
		public function SMILCoreDocument(documentType:IDocumentType)
		{
			super(documentType);
			
			this.addEventListener(MutationEvent.DOM_NODE_INSERTED, this.onDOMNodeInserted, false);
			this.addEventListener(MutationEvent.DOM_NODE_REMOVED, this.onDOMNodeRemoved, false);
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
		
		public function get timeDescendants():INodeList
		{
			return new ElementTimeDescendantNodeList(this);
		}
		
		public function activeChildrenAt(instant:Number):INodeList
		{
			return null;
		}
		
		public function get begin():ITimeList
		{
			return new TimeList(null, true, "0ms");
		}
		
		public function set begin(begin:ITimeList):void
		{
			throw new IllegalOperationError("Unable to write begin property on SMILDocument.");
		}
		
		public function get end():ITimeList
		{
			return new TimeList(null, false);
		}
		
		public function set end(end:ITimeList):void
		{
			throw new IllegalOperationError("Unable to write end property on SMILDocument.");
		}
		
		public function get dur():String
		{
			if (this._elementBodyContainer != null)
			{
				return this._elementBodyContainer.dur;
			}
			
			return "unresolved";
		}
		
		public function set dur(dur:String):void
		{
			throw new IllegalOperationError("Unable to write duration property on SMILDocument.");
		}
		
		public function get duration():Number
		{
			if (this._elementBodyContainer != null)
			{
				return this._elementBodyContainer.duration;
			}
			
			return Time.UNRESOLVED;
		}
		
		public function get durationResolved():Boolean
		{
			if (this._elementBodyContainer != null)
			{
				return this._elementBodyContainer.durationResolved;
			}
			
			return false
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
			if (this._elementBodyContainer != null)
			{
				this._elementBodyContainer.pauseElement();
			}
			
			throw new IllegalOperationError("Unable to perform pauseElement() when no body container is present.");
		}
		
		public function resumeElement():void
		{
			if (this._elementBodyContainer != null)
			{
				this._elementBodyContainer.resumeElement();
			}
			
			throw new IllegalOperationError("Unable to perform resumeElement() when no body container is present.");
		}
		
		public function seekElement(seekTo:Number):void
		{
			if (this._elementBodyContainer != null)
			{
				this._elementBodyContainer.seekElement(seekTo);
			}
			
			throw new IllegalOperationError("Unable to perform seekElement() when no body container is present.");
		}
		
		public function createSMILElement(tagName:String):ISMILElement
		{
			return new SMILElement(this, tagName);
		}
		
		public function createMediaElement(tagName:String):ISMILMediaElement
		{
			return new SMILMediaElement(this, tagName);
		}
		
		public function createBodyElement(tagName:String = "body"):IElementSequentialTimeContainer
		{
			return new ElementBodyTimeContainer(this, tagName);
		}
		
		public function createSequentialElement(tagName:String = "seq"):IElementSequentialTimeContainer
		{
			return new ElementSequentialTimeContainer(this, tagName);
		}
		
		public function createParallelElement(tagName:String = "par"):IElementParallelTimeContainer
		{
			return new ElementParallelTimeContainer(this, tagName);
		}
		
		public function createExclusiveElement(tagName:String = "excl"):IElementExclusiveTimeContainer
		{
			return new ElementExclusiveTimeContainer(this, tagName);
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

		protected override function beforeDispatchAggregateEvents():void
		{
			
		}
		
		protected function onDOMNodeInserted(e:MutationEvent):void
		{
			// should cache this abit better
			this._elementBodyContainer = (this.getElementsByTagName("body").item(0) as ElementBodyTimeContainer);
		}
		
		protected function onDOMNodeRemoved(e:MutationEvent):void
		{
			
		}
	}
}