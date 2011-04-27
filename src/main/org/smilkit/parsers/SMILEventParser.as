package org.smilkit.parsers
{
	import org.smilkit.w3c.dom.INode;

	public class SMILEventParser
	{
		protected var _parentNode:INode;
		protected var _eventString:String = null;
		
		public function SMILEventParser(parentNode:INode, eventString:String = null)
		{
			this._parentNode = parentNode;
			
			if (eventString != null)
			{
				this.parse(eventString);
			}
		}
		
		public function parse(eventString:String):void
		{
			this._eventString = eventString;
		}
	}
}