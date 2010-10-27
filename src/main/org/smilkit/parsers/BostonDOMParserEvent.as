package org.smilkit.parsers
{
	import flash.events.Event;
	
	import org.smilkit.w3c.dom.INode;
	
	public class BostonDOMParserEvent extends Event
	{
		public static var PARSER_COMPLETE:String = "onBostonDOMParserComplete";
		
		protected var _parsedNode:INode;
		
		public function BostonDOMParserEvent(type:String, parsedNode:INode, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this._parsedNode = parsedNode;
		}
		
		public function get parsedNode():INode
		{
			return this._parsedNode;
		}
	}
}