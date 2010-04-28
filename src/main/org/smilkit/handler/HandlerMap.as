package org.smilkit.handler
{
	import flash.net.URLRequest;
	
	import org.smilkit.util.URLParser;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class HandlerMap
	{
		protected var _protocols:Array;
		protected var _mimeMap:Object;
		protected var _urlRegex:RegExp;
		
		public function HandlerMap(protocols:Array, mimeMap:Object, urlRegex:RegExp = null)
		{
			this._protocols = protocols;
			this._mimeMap = mimeMap;
			this._urlRegex = urlRegex;
		}
		
		public function match(element:ISMILMediaElement):Boolean
		{
			var req:URLParser = new URLParser();
			
			if (element.src != null || element.src != "")
			{
				req.parse(element.src);
				
				if (this._protocols.indexOf(req.protocol) != -1)
				{
					for (var i:String in this._mimeMap)
					{
						var extensions:Array = this._mimeMap[i];
						
						for each (var ext:String in extensions)
						{
							if (ext == req.extension)
							{
								return true;
							}
						}
						
						extensions = null;
					}
				}
				
				if (this._urlRegex != null && this._urlRegex.test(req.url))
				{
					return true;
				}
			}
			
			return false;
		}
	}
}