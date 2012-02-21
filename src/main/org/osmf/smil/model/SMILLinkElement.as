package org.osmf.smil.model
{
	public class SMILLinkElement extends SMILElement
	{
		public function SMILLinkElement()
		{
			super(SMILElementType.LINK);
		}
		
		public function get src():String
		{
			return this._src;
		}
		
		public function set src(value:String):void
		{
			this._src = value;
		}
		
		private var _src:String;
	}
}