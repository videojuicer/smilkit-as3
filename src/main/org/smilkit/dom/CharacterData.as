package org.smilkit.dom
{
	import org.smilkit.w3c.dom.IDocument;
	
	public class CharacterData extends ChildNode
	{
		protected var _data:String;
		
		public function CharacterData(owner:IDocument, data:String)
		{
			super(owner);
			
			this._data = data;
		}
		
		public override function get nodeValue():String
		{
			return this._data;
		}
		
		public override function set nodeValue(value:String):void
		{
			this.setNodeValue(value, false);
			
			(this.ownerDocument as Document).replacedText(this);
		}
		
		public function get data():String
		{
			return this._data;
		}
		
		public function set data(value:String):void
		{
			this.nodeValue = value;
		}
		
		public override function get length():int
		{
			return this._data.length;
		}
		
		public function appendData(data:String):void
		{
			if (data == null)
			{
				return;
			}
			
			this.nodeValue = this._data + data;
		}
		
		protected function setNodeValue(value:String, replace:Boolean):void
		{
			var oldValue:String = this._data;
			
			(this.ownerDocument as Document).modifyingCharacterData(this, replace);
			
			this._data = value;
			
			(this.ownerDocument as Document).modifiedCharacterData(this, oldValue, value, replace);
		}
		
		public function deleteData(offset:int, count:int):void
		{
			if (count < 0)
			{
				throw new DOMException(DOMException.INDEX_SIZE_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "INDEX_SIZE_ERR"));
			}
			
			try
			{
				var tailLength:int = Math.max(this._data.length - count - offset, 0);
				var tailValue:String = tailLength > 0 ? this._data.substr(offset + count, offset + count + tailLength) : "";
				var value:String = this._data.substr(0, offset);
				
				this.setNodeValue(value, false);
				
				(this.ownerDocument as Document).deletedText(this, offset, count);
			}
			catch (e:ArgumentError)
			{
				throw new DOMException(DOMException.INDEX_SIZE_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "INDEX_SIZE_ERR"));
			}
		}
		
		public function insertData(offset:int, data:String):void
		{
			// insert data
		}
		
		public function replaceData(offset:int, count:int, data:String):void
		{
			
		}
		
		public function substringData(offset:int, count:int):String
		{
			if (count < 0 || offset < 0 || offset > this.length - 1)
			{
				throw new DOMException(DOMException.INDEX_SIZE_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "INDEX_SIZE_ERR"));
			}
			
			return this._data.substr(offset, Math.min(offset + count, this.length));
		}
	}
}