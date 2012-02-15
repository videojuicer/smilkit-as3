/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
package org.smilkit.handler
{
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.utilkit.collection.Hashtable;
	import org.utilkit.parser.URLParser;
	import org.utilkit.util.ObjectUtil;

	public class HandlerMap
	{
		private static const __handlers:Hashtable = new Hashtable();
		
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
			
			if (element.src != null && element.src != "" && (element.src.indexOf("://") < 5 && element.src.indexOf("://") != -1))
			{
				req.parse(element.src);
				
				if (this._protocols.indexOf(req.protocol) != -1)
				{
					var elementExtension:String = req.extension;
					
					if (elementExtension == null || elementExtension == "")
					{
						elementExtension = req.inlineExtension;
						
						if (elementExtension != null && elementExtension != "")
						{
							elementExtension = "."+elementExtension;
						}
					}
					
					for (var i:String in this._mimeMap)
					{
						var extensions:Array = this._mimeMap[i];
						
						for each (var ext:String in extensions)
						{
							if (ext == "*" || (elementExtension != null && ext == elementExtension.toString().toLowerCase()))
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
		
		/**
		 * Register the default set of SMILKit handlers
		 *
		 * @see org.smilkit.handler.Handler
		 * @see org.smilkit.handler.HandlerMap
		 */
		public static function defaultHandlers():void
		{
			HandlerMap.registerHandler(org.smilkit.handler.SMILReferenceHandler, SMILReferenceHandler.toHandlerMap());
			
			HandlerMap.registerHandler(org.smilkit.handler.ImageHandler, ImageHandler.toHandlerMap());
			
			HandlerMap.registerHandler(org.smilkit.handler.RTMPVideoHandler, RTMPVideoHandler.toHandlerMap());
			HandlerMap.registerHandler(org.smilkit.handler.RTMPAudioHandler, RTMPAudioHandler.toHandlerMap());
			
			HandlerMap.registerHandler(org.smilkit.handler.HTTPAudioHandler, HTTPAudioHandler.toHandlerMap());
			HandlerMap.registerHandler(org.smilkit.handler.HTTPVideoHandler, HTTPVideoHandler.toHandlerMap());
		}
		
		/**
		 * Register the specified <code>Handler</code> class with the <code>HandlerMap</code>, handlers are registered
		 * on the global SMILKit scope.
		 * 
		 * @param handlerClass The <code>Handler</code> class reference to register the map.
		 * @param handlerMap A <code>HandlerMap</code> instance used for matching against the handler.
		 *
		 * @see org.smilkit.handler.Handler
		 * @see org.smilkit.handler.HandlerMap
		 */
		public static function registerHandler(handlerClass:Class, handlerMap:HandlerMap):void
		{
			HandlerMap.__handlers.setItem(handlerMap, handlerClass);
		}
		
		/**
		 * Finds a <code>Handler</code> class for the specified <code>ISMILMediaElement</code>, loops over
		 * the registered handlers to find a match through the <code>HandlerMap</code>.
		 * 
		 * @param element The <code>ISMILMediaElement</code> instance to find a handler for.
		 *
		 * @return The matching <code>Handler</code> class, or null if not found.
		 */
		public static function findHandlerClassFor(element:ISMILMediaElement):Class
		{
			for (var i:int = (HandlerMap.__handlers.length-1); i >= 0; i--)
			{
				var handler:HandlerMap = HandlerMap.__handlers.getKeyAt(i) as HandlerMap;
				
				if (handler.match(element))
				{
					return HandlerMap.__handlers.getItemAt(i) as Class;
				}
			}
			
			return null;
		}
		
		/**
		 * Create a <code>SMILKitHandler</code> instance for the specified <code>ISMILMediaElement</code>
		 * object.
		 * 
		 * @param element The <code>ISMILMediaElement</code> to find a matching hander for.
		 * 
		 * @return <code>SMILKitHandler</code> instance.
		 *
		 * @see org.smilkit.handler.Handler
		 * @see org.smilkit.handler.HandlerMap
		 */
		public static function createElementHandlerFor(element:ISMILMediaElement):SMILKitHandler
		{
			var klass:Class = HandlerMap.findHandlerClassFor(element);
			
			if (klass != null)
			{
				var handler:SMILKitHandler = new klass(element);
				
				return handler;
			}
			
			return null;
		}
		
		/**
		 * Remove the specified registered handler.
		 *
		 * @param handlerClass The <code>Class</code> to find the registered handlers to remove.
		 * @param handlerMap A <code>HandlerMap</code> instance to match against, if not specified will remove all handlers that match on the handlerClass.
		 *
		 * @see org.smilkit.handler.Handler
		 * @see org.smilkit.handler.HandlerMap
		 */
		public static function removeHandlers(handlerClass:Class = null, handlerMap:HandlerMap = null):void
		{
			if (handlerClass == null)
			{
				// clear all
				HandlerMap.__handlers.removeAll();
			}
			else
			{
				for (var i:int = HandlerMap.__handlers.length; i > 0; i--)
				{
					var hClass:Class = HandlerMap.__handlers.getItemAt(i) as Class;
					var hMap:HandlerMap = HandlerMap.__handlers.getKeyAt(i) as HandlerMap;
					
					if (handlerClass == hClass)
					{
						if (handlerMap == null || hMap == handlerMap)
						{
							HandlerMap.__handlers.removeItemAt(i);
						}	
					}
				}
			}
		}
	}
}