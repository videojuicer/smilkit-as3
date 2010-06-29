package org.smilkit.dom.events
{
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.events.IMutationEvent;
	
	public class MutationEvent extends DOMEvent implements IMutationEvent
	{
		public static var MODIFICATION:int = 1;
		public static var ADDITION:int = 2;
		public static var REMOVAL:int = 3;
		
		public static var DOM_SUBTREE_MODIFIED:String = "DOMSubtreeModified";
		public static var DOM_NODE_INSERTED:String = "DOMNodeInserted";
		public static var DOM_NODE_REMOVED:String = "DOMNodeRemoved";
		public static var DOM_NODE_REMOVED_FROM_DOCUMENT:String = "DOMNodeRemovedFromDocument";
		public static var DOM_NODE_INSERTED_INTO_DOCUMENT:String = "DOMNodeInsertedIntoDocument";
		public static var DOM_ATTR_MODIFIED:String = "DOMAttrModified";
		public static var DOM_CHARACTER_DATA_MODIFIED:String = "DOMCharacterDataModified";
		
		protected var _relatedNode:INode;
		protected var _prevValue:String;
		protected var _newValue:String;
		protected var _attrName:String;
		protected var _attrChange:uint;
		
		public function get relatedNode():INode
		{
			return this._relatedNode;
		}
		
		public function get prevValue():String
		{
			return this._prevValue;
		}
		
		public function get newValue():String
		{
			return this._newValue;
		}
		
		public function get attrName():String
		{
			return this._attrName;
		}
		
		public function get attrChange():uint
		{
			return this._attrChange;
		}
		
		public function initMutationEvent(type:String, bubbles:Boolean, cancelable:Boolean, relatedNode:INode, prevValue:String, newValue:String, attrName:String, attrChange:uint):void
		{
			this._relatedNode = relatedNode;
			this._prevValue = prevValue;
			this._newValue = newValue;
			this._attrName = attrName;
			this._attrChange = attrChange;
			
			super.initEvent(type, bubbles, cancelable);
		}
	}
}