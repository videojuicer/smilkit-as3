package org.smilkit.handler
{
	import flash.net.URLRequest;
	
	import org.utilkit.util.ObjectUtil;
	import org.utilkit.parser.URLParser;
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
		
		public function get protocols():Array
		{
			return this._protocols;
		}
		
		public function get mimeMap():Object
		{
			return this._mimeMap;
		}
		
		public function get urlRegex():RegExp
		{
			return this._urlRegex;
		}
		
		/**
		 * Merges the specified <code>HandlerMap</code> instance with the current instance,
		 * this instance can be overwritten by members of the specified <code>HandlerMap</code>.
		 *
		 * @param handlerMap The <code>HandlerMap</code> instance to merge with the current.
		 * 
		 * @return The combined <code>HandlerMap</code> instance.
		 */
		public function merge(handlerMap:HandlerMap):HandlerMap
		{
			var mergedMap:HandlerMap = new HandlerMap(null, null, null);
			
			mergedMap._protocols = this._protocols.concat(handlerMap._protocols);
			mergedMap._mimeMap = ObjectUtil.merge(this._mimeMap, handlerMap._mimeMap);
			
			return mergedMap;
		}
		
		/**
		 * Run's a match test against this <code>HandlerMap</code> instance for the specified
		 * <code>ISMILMediaElement</code> instance.
		 * 
		 * @param element The <code>ISMILMediaElement</code> instance to run the test against.
		 * 
		 * @return True if this <code>HandlerMap</code> matches against the specified
		 * <code>ISMILMediaElement</code>, false if the test failed to match.
		 * 
		 * @see org.smilkit.w3c.dom.smil.ISMILMediaElement
		 */
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