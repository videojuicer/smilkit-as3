package org.smilkit.handler.state
{
	import org.smilkit.util.URLParser;

	public class HandlerState
	{
		protected var _src:String;
		protected var _handlerOffset:int;
		
		protected var _extractedSrc:URLParser;
		
		public function HandlerState(src:String, handlerOffset:int)
		{
			this._src = src;
			this._handlerOffset = handlerOffset;
			
			this._extractedSrc = new URLParser(this._src);
		}
		
		public function get src():String
		{
			return this._src;
		}
		
		public function get extractedSrc():URLParser
		{
			return this._extractedSrc;
		}
		
		public function get handlerOffset():int
		{
			return this._handlerOffset;
		}
		
		public function get type():String
		{
			return "generic";
		}
		
		public function compatibleWith(handlerState:HandlerState):Boolean
		{
			if (this.type == handlerState.type)
			{
				if (this.extractedSrc.protocol == handlerState.extractedSrc.protocol)
				{
					return true;
				}
			}
			
			return false;
		}
	}
}