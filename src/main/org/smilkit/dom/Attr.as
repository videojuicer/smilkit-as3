package org.smilkit.dom
{
	import org.smilkit.w3c.dom.IAttr;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	
	/**
	 * Attributes representats an XML attribute that usually appears on a
	 * <code>Element</code>. 
	 * 
	 * Attributes may have multiple children, XML allows attributes to contain
	 * entity references and tokenied attribute types. The getter <code>value</code>
	 * returns the String version of the attribute's value.
	 * 
	 * Attributes do not directly belong to a <code>parent</code> and have no valid
	 * reference back to there parent. They do however have an <code>ownerElement</code>, 
	 * which holds a reference to the <code>Element</code> that holds the attribute.
	 * 
	 * Elements do not permit for <code>Attributes</code> to be shared so we do not 
	 * need to worry about the object's mutability.
	 */
	public class Attr extends Node implements IAttr
	{
		private static const DTD:String = "http://www.w3.org/TR/REC-xml";
		
		protected var _ownerNode:INode = null;
		protected var _value:Object = null;
		protected var _name:String;
		protected var _isAttributeNode:Boolean = false;
		
		public function Attr(owner:IDocument, name:String)
		{
			super(owner);
			
			this._name = name;
		}
		
		public function get name():String
		{
			return this._name;
		}
		
		public override function get nodeName():String
		{
			return this.name;
		}
		
		public function get specified():Boolean
		{
			return false;
		}
		
		public function get value():String
		{
			if (this._value == null)
			{
				return null;
			}
			
			return this._value.toString();
		}
		
		public function set value(value:String):void
		{
			var oldValue:String = this.value;
			var document:Document = (this.ownerDocument as Document);
			
			this._value = value;
				
			if (document.mutationEvents)
			{
				document.modifiedAttrValue(this, oldValue);
			}
			else
			{
				this.changed();
			}
		}
		
		public override function get nodeValue():String
		{
			return this.value;
		}
		
		public override function set nodeValue(nodeValue:String):void
		{
			this.value = nodeValue;
		}
		
		public function get ownerElement():IElement
		{
			return super._ownerDocument as IElement;
		}
		
		public function get ownerNode():INode
		{
			return this._ownerNode;
		}
		
		public function set ownerNode(ownerNode:INode):void
		{
			this._ownerNode = ownerNode;
		}
		
		public function get isAttributeNode():Boolean
		{
			return this._isAttributeNode;
		}
		
		public function set isAttributeNode(value:Boolean):void
		{
			this._isAttributeNode = value;
		}
	}
}