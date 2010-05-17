package org.smilkit.dom
{
	import mx.controls.Text;
	
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.ICharacterData;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IText;
	
	public class Text extends CharacterData implements ICharacterData, IText
	{
		public function Text(owner:IDocument, data:String)
		{
			super(owner, data);
		}
		
		public override function get nodeType():int
		{
			return Node.TEXT_NODE;
		}
		
		public override function get nodeName():String
		{
			return "#text";
		}
		
		public function splitText(offset:int):IText
		{
			if (offset < 0 || offset > this._data.length)
			{
				throw new DOMException(DOMException.INDEX_SIZE_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "INDEX_SIZE_ERR"));
			}
			
			var text:IText = this.ownerDocument.createTextNode(this._data.substr(offset));
			
			this.nodeValue = this._data.substr(0, offset);
			
			if (this.parentNode != null)
			{
				this.parentNode.insertBefore(text, this.nextSibling);
			}
			
			return text;
		}
	}
}