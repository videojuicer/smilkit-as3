package org.smilkit.dom.smil
{
	import flash.errors.IllegalOperationError;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Document;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.ParentNode;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.w3c.dom.IAttr;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.smilkit.w3c.dom.smil.ISMILRegionElement;
	import org.smilkit.w3c.dom.smil.ISMILRegionInterface;
	import org.smilkit.w3c.dom.smil.ITimeList;
	
	public class SMILMediaElement extends ElementTimeContainer implements ISMILMediaElement, ISMILRegionInterface
	{
		protected var _handler:SMILKitHandler;
		protected var _region:SMILRegionElement;
		
		public function SMILMediaElement(owner:IDocument, name:String)
		{
			super(owner, name);
			
			this.addEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, this.onDOMSubtreeModified, false);
			this.addEventListener(MutationEvent.DOM_ATTR_MODIFIED, this.onDOMAttributeModified, false);
		}
		
		public function get handler():SMILKitHandler
		{
			return this._handler;
		}
		
		/**
		* Returns the parent <a /> tag, if one exists.
		*/
		public function get linkContextElement():Element
		{
			var p:Element = (this.parentNode as Element);
			while(p != null && p.nodeName.toLowerCase() != "a")
			{
				p = (p.parentNode as Element);
			}
			return p;
		}
		
		public function get abstractAttr():String
		{
			return this.getAttribute("abstract");
		}
		
		public function set abstractAttr(abstractAttr:String):void
		{
			this.setAttribute("abstract", abstractAttr);
		}
		
		public function get alt():String
		{
			return this.getAttribute("alt");
		}
		
		public function set alt(alt:String):void
		{
			this.setAttribute("alt", alt);
		}
		
		public function get author():String
		{
			return this.getAttribute("author");
		}
		
		public function set author(author:String):void
		{
			this.setAttribute("author", author);
		}
		
		public function get clipBegin():String
		{
			return this.getAttribute("clipBegin");
		}
		
		public function set clipBegin(clipBegin:String):void
		{
			this.setAttribute("clipBegin", copyright);
		}
		
		public function get clipEnd():String
		{
			return this.getAttribute("clipEnd");
		}
		
		public function set clipEnd(clipEnd:String):void
		{
			this.setAttribute("clipEnd", clipEnd);
		}
		
		public function get copyright():String
		{
			return this.getAttribute("copyright");
		}
		
		public function set copyright(copyright:String):void
		{
			this.setAttribute("copyright", copyright);
		}
		
		public function get longdesc():String
		{
			return this.getAttribute("longdesc");
		}
		
		public function set longdesc(longdesc:String):void
		{
			this.setAttribute("longdesc", longdesc);
		}
		
		public function get port():String
		{
			return this.getAttribute("port");
		}
		
		public function set port(port:String):void
		{
			this.setAttribute("port", port);
		}
		
		public function get readIndex():String
		{
			return this.getAttribute("readIndex");
		}
		
		public function set readIndex(readIndex:String):void
		{
			this.setAttribute("readIndex", readIndex);
		}
		
		public function get rtpFormat():String
		{
			return this.getAttribute("rtpFormat");
		}
		
		public function set rtpFormat(rtpFormat:String):void
		{
			this.setAttribute("rtpFormat", rtpFormat);
		}
		
		public function get src():String
		{
			var src:String = this.getAttribute("src");
			
			if (src.indexOf("://") == -1)
			{
				var root:Element = this.getClosestParentElementByTagName("smil") as Element;
				
				//if (root != null)
				//{
					// find src
					var metas:INodeList = root.getElementsByTagName("meta");
					var base:String = "";
				
					for (var i:int = 0; i < metas.length; i++)
					{
						var node:Element = (metas.item(i) as Element);
					
						if (node.hasAttributes() && node.attributes.getNamedItem("base") != null)
						{
							base = node.attributes.getNamedItem("base").nodeValue;
						
							break;
						}
					}
				
					src = base + "/" + src;
				//}
			}
			
			return src;
		}
		
		protected function getClosestParentElementByTagName(tagName:String):INode
		{
			var parent:INode = this.parentNode;
			var found:INode = null;
			
			while (parent != null)
			{
				if (parent.nodeName == tagName)
				{
					found = parent;
					break;
				}
				
				parent = parent.parentNode;
			}
			
			return found;
		}
		
		public function set src(src:String):void
		{
			this.setAttribute("src", src);
		}
		
		public function get stripRepeat():String
		{
			return this.getAttribute("stripRepeat");
		}
		
		public function set stripRepeat(stripRepeat:String):void
		{
			this.setAttribute("stripRepeat", stripRepeat);
		}
		
		public function get title():String
		{
			return this.getAttribute("title");
		}
		
		public function set title(title:String):void
		{
			this.setAttribute("title", title);
		}
		
		public function get transport():String
		{
			return this.getAttribute("transport");
		}
		
		public function set transport(transport:String):void
		{
			this.setAttribute("transport", transport);
		}
		
		public function get type():String
		{
			return this.tagName;
		}
		
		public function set type(type:String):void
		{
			throw new IllegalOperationError("Unable to change 'type' on 'SMILMediaElement'");
		}
		
		public function get region():ISMILRegionElement
		{
			if (this._region == null)
			{
				var regionId:String = ""
				
				if (this.hasAttribute("region"))
				{
					regionId = this.getAttribute("region");
				}
				else
				{
					regionId = this.findParentRegionID();
				}
				
				this._region = (this.ownerDocument.getElementById(regionId) as SMILRegionElement);
			}
			
			return this._region;
		}
		
		protected function findParentRegionID():String
		{
			var parent:Element = (this.parentNode as Element);
			var regionId:String = "";
			
			while ((regionId == null || regionId == "") && parent != null)
			{
				if (parent.hasAttribute("region"))
				{
					regionId = parent.getAttribute("region");
				}
				else
				{
					parent = (parent.parentNode as Element);
				}
			}
			
			return regionId;
		}

		public function set region(region:ISMILRegionElement):void
		{
			this.setAttribute("region", region.id);
	
			if (this._region.id == this.getAttribute("region"))
			{
				this._region = null;
			}
		}
		
		/**
		 * NON-DOM
		 */
		public function get resolved():Boolean
		{
			if (this._beginList == null || this._endList == null)
			{
				return false;
			}
			
			if (!(this._beginList as TimeList).resolved || !(this._endList as TimeList).resolved)
			{
				return false;
			}
			
			return true;
		}
		
		/*
		public override function ancestorChanged(newAncestor:ParentNode=null):void
		{
			// ancestor was removed, so were now an orphan?
			if (newAncestor == null)
			{
				if (this._handler != null)
				{
					this._handler.cancel();
				}
				
				this._handler = null;
			}
			// ancestor was added
			else
			{
				this.updateHandler();
				
				if (this.handler != null)
				{
					(this.ownerDocument as Document).handlerModified(this, null, this._handler);
				}
			}
		}
		*/
		
		protected function onDOMSubtreeModified(e:MutationEvent):void
		{
			this.onDOMAttributeModified(e);
		}

		protected function onDOMAttributeModified(e:MutationEvent):void
		{
			if (e.attrName == "src" || e.attrName == "type")
			{
				if (e.prevValue != e.newValue)
				{
					this.updateHandler();
				
					(this.ownerDocument as Document).handlerModified(this, null, this._handler);
				}
			}
		}
		
		public override function resolve():void
		{
			if (this._handler == null)
			{
				this.updateHandler();
			}
			
			super.resolve();
		}
		
		public override function beginElement():Boolean
		{
			return false;
		}
		
		public override function endElement():Boolean
		{
			return false;
		}
		
		public override function pauseElement():void
		{
			this._handler.pause();
		}
		
		public override function resumeElement():void
		{
			this._handler.resume();
		}
		
		public override function seekElement(seekTo:Number):void
		{
			this._handler.seek(seekTo);
		}
		
		private function updateHandler():void
		{
			if (this._handler != null)
			{
				this._handler.removeEventListener(HandlerEvent.DURATION_RESOLVED, this.onHandlerDurationResolved);
			}
			
			this._handler = SMILKit.createElementHandlerFor(this);
			
			if (this._handler != null)
			{
				this._handler.addEventListener(HandlerEvent.DURATION_RESOLVED, this.onHandlerDurationResolved);
			}
		}
		
		private function onHandlerDurationResolved(e:HandlerEvent):void
		{
			//(this.ownerDocument as SMILDocument).invalidateCachedTimes();
		}
	}
}