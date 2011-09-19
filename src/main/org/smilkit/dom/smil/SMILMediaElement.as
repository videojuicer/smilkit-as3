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
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.smilkit.w3c.dom.smil.ISMILRegionElement;
	import org.smilkit.w3c.dom.smil.ISMILRegionInterface;
	
	public class SMILMediaElement extends ElementTestContainer implements ISMILMediaElement, ISMILRegionInterface
	{
		protected var _handler:SMILKitHandler;
		protected var _region:SMILRegionElement;
		
		protected var _handlerState:uint = ElementTimeContainer.PLAYBACK_STATE_PLAYING;
		
		public function SMILMediaElement(owner:IDocument, name:String)
		{
			super(owner, name);
			
			//this.addEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, this.onDOMSubtreeModified, false);
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
			
			if (src != null && src != "" && src.indexOf("://") == -1)
			{
				var root:Element = this.getClosestParentElementByTagName("smil") as Element;
				
				if (root != null)
				{
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
				}
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
			if (this.currentBeginInterval == null && this.currentEndInterval == null)
			{
				return false;
			}

			return true;
		}
		
		/**
		 * Finds all the param tags that are direct children of this element and
		 * composes them into a dictionary of objects. 
		 */
		public function get params():Object
		{
			var dict:Object = {};
			// Get defaults
			var paramGroup:String = this.getAttribute("paramGroup");
			if(paramGroup != null) {
				var paramGroupElement:IElement = this.ownerSMILDocument.getElementById(paramGroup);
				if(paramGroupElement != null && paramGroupElement.tagName.toLowerCase() == "paramgroup")
				{
					// Group element exists - merge into dict
					dict = this.paramNodeListToObject(paramGroupElement.getElementsByTagName("param"), dict);
				}
			}
			// Get params on this element
			dict = this.paramNodeListToObject(this.getElementsByTagName("param"), dict, this);
			return dict;
		}
		
		protected function paramNodeListToObject(list:INodeList, mergeInto:Object = null, onlyParent:Element=null):Object
		{
			var dict:Object = (mergeInto != null)? mergeInto : {};
			for(var i:uint=0; i<list.length; i++)
			{
				var n:IElement = list.item(i) as IElement;
				if(onlyParent == null || onlyParent == n.parentNode)
				{
					var name:String = n.getAttribute("name");
					var value:String = n.getAttribute("value");
					if(name != null)
					{
						dict[name] = value;
					}
				}
			}
			return dict;
		}
		
		public function getParam(name:String):String
		{
			return this.params[name];
		}
		
		public function setParam(name:String, value:String):void
		{
			// TODO
		}
		
		public override function ancestorChanged(newAncestor:ParentNode=null):void
		{
			super.ancestorChanged(newAncestor);
			
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

		protected function onDOMAttributeModified(e:MutationEvent):void
		{
			if (e.attrName == "src" || e.attrName == "type")
			{
				if (!this.orphaned && e.prevValue != e.newValue)
				{
					this.updateHandler();
				
					(this.ownerDocument as Document).handlerModified(this, null, this._handler);
				}
			}
		}
		
		public override function beginElement():Boolean
		{	
			return super.beginElement();
		}
		
		public override function endElement():Boolean
		{
			return super.endElement();
		}
		
		public override function get renderState():uint
		{
			var state:uint = super.renderState;
			return state;
			if (this._handlerState == ElementTimeContainer.PLAYBACK_STATE_PAUSED)
			{
				return ElementTestContainer.RENDER_STATE_HIDDEN;
			}
			else
			{
				return ElementTestContainer.RENDER_STATE_ACTIVE;
			}
		}
		
		public override function pauseElement():void
		{
			super.pauseElement();
		}
		
		public override function resumeElement():void
		{
			super.resumeElement();
		}
		
		public override function seekElement(seekTo:Number):void
		{
			super.seekElement(seekTo);
			// this._handler.seek(seekTo);
		}
		
		private function updateHandler():void
		{
			if (this._handler != null)
			{
				this._handler.removeEventListener(HandlerEvent.PAUSE_NOTIFY, this.onHandlerPaused);
				this._handler.removeEventListener(HandlerEvent.RESUME_NOTIFY, this.onHandlerResumed);
				this._handler.removeEventListener(HandlerEvent.STOP_NOTIFY, this.onHandlerStopped);
				
				this._handler.destroy();
				
				this._handler = null;
			}
			
			if (!this.orphaned)
			{
				this._handler = SMILKit.createElementHandlerFor(this);
				this._handlerState = ElementTimeContainer.PLAYBACK_STATE_PAUSED;
				
				SMILKit.logger.debug("SMILMediaElement is not orphaned created new handler ...");
			}
			else
			{
				SMILKit.logger.debug("SMILMediaElement is orphaned skipping handler creation ...");
			}
			
			if (this._handler != null)
			{
				this._handler.addEventListener(HandlerEvent.PAUSE_NOTIFY, this.onHandlerPaused);
				this._handler.addEventListener(HandlerEvent.RESUME_NOTIFY, this.onHandlerResumed);
				this._handler.addEventListener(HandlerEvent.STOP_NOTIFY, this.onHandlerStopped);
			}
		}

		private function onHandlerPaused(e:HandlerEvent):void
		{
			this._handlerState = ElementTimeContainer.PLAYBACK_STATE_PAUSED;
		}

		private function onHandlerResumed(e:HandlerEvent):void
		{
			this._handlerState = ElementTimeContainer.PLAYBACK_STATE_PLAYING;
		}
		
		private function onHandlerStopped(e:HandlerEvent):void
		{
			this.onMediaDurationEnd();
		}
		
		protected override function display():void
		{
			// if we dont have a handler, what can we display ... nothing!
			if (this.handler != null)
			{
				//SMILKit.logger.info("DISPLAYING -> "+this.src);
				
				super.display();
			}
		}
	}
}