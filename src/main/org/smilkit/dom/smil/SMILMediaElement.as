package org.smilkit.dom.smil
{
	import flash.errors.IllegalOperationError;
	
	import org.smilkit.SMILKit;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.w3c.dom.IAttr;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.smilkit.w3c.dom.smil.ITimeList;
	
	public class SMILMediaElement extends ElementTimeContainer implements ISMILMediaElement
	{
		protected var _handler:SMILKitHandler;
		
		public function SMILMediaElement(owner:IDocument, name:String)
		{
			super(owner, name);
			
			this._handler = SMILKit.createElementHandlerFor(this);
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