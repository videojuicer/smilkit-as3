package org.smilkit.dom.smil
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.parsers.BostonDOMParserEvent;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.ISMILRefElement;
	
	public class SMILRefElement extends SMILMediaElement implements ISMILRefElement
	{
		protected var _parser:BostonDOMParser;
		
		public function SMILRefElement(owner:IDocument, name:String)
		{
			super(owner, name);
			
			this._parser = new BostonDOMParser();
			
			this._parser.addEventListener(BostonDOMParserEvent.PARSER_COMPLETE, this.onParserComplete);
			this._parser.addEventListener(IOErrorEvent.IO_ERROR, this.onParserIOError);
			this._parser.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onParserSecurityError);
			this._parser.addEventListener(Event.COMPLETE, this.onParserLoadComplete);
		}
		
		public function get parser():BostonDOMParser
		{
			return this._parser;
		}
		
		public override function resumeElement():void
		{
			SMILKit.logger.debug("RESUMED REF");
		}
		
		public function refresh():void
		{
			if (this.hasChildNodes() && this.getElementsByTagName("smil").length > 0)
			{
				for (var i:int = 0; i < this.getElementsByTagName("smil").length; i++)
				{
					this.removeChild(this.getElementsByTagName("smil").item(i));
				}
			}
			
			var smilURI:String = this.getAttribute("src");
			
			SMILKit.logger.debug("Reference element refreshing from "+smilURI);
			
			this._parser.load(smilURI, this);
		}
		
		protected function onParserLoadComplete(e:Event):void
		{
			SMILKit.logger.debug("Reference element successfully loaded content, starting to parse");
		}
		
		protected function onParserComplete(e:BostonDOMParserEvent):void
		{
			//this.appendChild(e.parsedNode);
			
			SMILKit.logger.debug("Parser completed loading reference document");
			
			// unresolve the entire document
			((this.ownerDocument as SMILDocument).timeChildren as ElementTimeNodeList).unresolve();
		}
		
		protected function onParserIOError(e:IOErrorEvent):void
		{
			SMILKit.logger.debug("IO error occured whilst loading reference document");
		}
		
		protected function onParserSecurityError(e:SecurityErrorEvent):void
		{
			SMILKit.logger.debug("Security error occured whilst loading reference document");
		}

		protected override function onDOMAttributeModified(e:MutationEvent):void
		{
			if (e.attrName == "src" || e.attrName == "type")
			{
				if (e.prevValue != e.newValue)
				{
					this.refresh();
				}
			}
		}
		
		public override function get durationResolved():Boolean
		{
			SMILKit.logger.debug("REF->DURATION->");
			
			if(super.durationResolved)
			{
				return true;
			}
			
			for (var i:int = (this.timeDescendants.length-1); i >= 0; i--)
			{
				if (this.timeDescendants.item(i) is ElementTimeContainer)
				{
					if(!(this.timeDescendants.item(i) as ElementTimeContainer).durationResolved)
					{
						return false;
					}
				}
			}
			return true;
		}
		
		public override function get duration():Number
		{
			var duration:Number = super.duration;
			
			if (this.hasChildNodes() && duration == 0)
			{
				var childDuration:Number = 0;
				
				for (var i:int = 0; i < this.timeDescendants.length; i++)
				{
					if (this.timeDescendants.item(i) is ElementTimeContainer)
					{
						childDuration += (this.timeDescendants.item(i) as ElementTimeContainer).duration;
					}
				}
				
				if (childDuration != 0)
				{
					return childDuration;
				}
			}
			return duration;
		}
	}
}