package org.smilkit.dom.smil
{
	import flash.errors.IllegalOperationError;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.w3c.dom.IAttr;
	import org.smilkit.w3c.dom.IDocument;
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
			
			this.addEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, this.onDOMAttributeModified, false);
			this.addEventListener(MutationEvent.DOM_ATTR_MODIFIED, this.onDOMAttributeModified, false);
		}
		
		public function get handler():SMILKitHandler
		{
			return this._handler;
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
			return this.getAttribute("src");
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
			if (this.hasAttribute("region") && this._region == null)
			{
				var regionId:String = this.getAttribute("region");
				
				this._region = (this.ownerDocument.getElementById(regionId) as SMILRegionElement);
			}
			
			return this._region;
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
		
		protected function onDOMAttributeModified(e:MutationEvent):void
		{
			if (e.attrName == "src" || e.attrName == "type")
			{
				this._handler = SMILKit.createElementHandlerFor(this);
			}
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
	}
}