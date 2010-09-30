package org.smilkit
{
	import mx.core.ClassFactory;
	
	import org.smilkit.collections.Hashtable;
	import org.smilkit.collections.List;
	import org.smilkit.dom.Document;
	import org.smilkit.dom.DocumentType;
	import org.smilkit.handler.HTTPVideoHandler;
	import org.smilkit.handler.HandlerMap;
	import org.smilkit.handler.ImageHandler;
	import org.smilkit.handler.RTMPVideoHandler;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.view.Viewport;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.utilkit.logger.ApplicationLog;
	import org.utilkit.logger.Logger;
	
	/**
	 * SMILKit's main static API object, allows the creation, manipulation and browsing of SMIL3.0 DOM documents.
	 * 
	 * Implements the W3C DOM Level 2 specification and SMIL 3.0 Boston DOM specification.
	 * 
	 * @see http://www.w3.org/TR/2000/REC-DOM-Level-2-Views-20001113
	 * @see http://www.w3.org/TR/smil-boston-dom/
	 */
	public class SMILKit
	{
		private static var __version:String = "0.1.0";
		private static var __handlers:Hashtable = new Hashtable();
		private static var __applicationLog:ApplicationLog = new ApplicationLog("smilkit-as3");
		
		/**
		 * Retrieve's the current SMILKit version.
		 */
		public static function get version():String
		{
			return SMILKit.__version;
		}
		
		public static function get logger():ApplicationLog
		{
			return SMILKit.__applicationLog;
		}
		
		/**
		 * Create's a new SMIL 3.0 DOM <code>Document</code>.
		 * 
		 * @return The generated <code>IDocument</code>.
		 * 
		 * @see org.smilkit.dom.Document
		 * @see org.smilkit.w3c.dom.IDocument
		 */
		public static function createSMILDocument():IDocument
		{
			return new Document(new DocumentType(null, "smil", "-//W3C//DTD SMIL 3.0 Language//EN", "http://www.w3.org/2008/SMIL30/SMIL30Language.dtd"));
		}
		
		/**
		 * Create's a new empty SMILKit <code>Viewport</code>.
		 * 
		 * @return The generated <code>Viewport</code>.
		 * 
		 * @see org.smilkit.view.Viewport
		 */
		public static function createEmptyViewport():Viewport
		{
			return new Viewport();
		}
		
		/**
		 * Load's and generates a SMIL document from the specified SMIL XML string.
		 *
		 * @param smil SMIL XML string to generate a document from.
		 * 
		 * @return Created <code>IDocument</code> instance. 
		 */
		public static function loadSMILDocument(smil:String):IDocument
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:IDocument = parser.parse(smil);
			
			return document;
		}
		
		/**
		 * Register the default setup for SMILKit.
	     */
		public static function defaults():void
		{
			// load default logger renderers
			Logger.defaultRenderers();
			
			// load the default smilkit handlers
			SMILKit.defaultHandlers();
		}
		
		/**
		 * Register the default set of SMILKit handlers
		 *
		 * @see org.smilkit.handler.Handler
		 * @see org.smilkit.handler.HandlerMap
		 */
		public static function defaultHandlers():void
		{
			SMILKit.registerHandler(org.smilkit.handler.ImageHandler, ImageHandler.toHandlerMap());
			SMILKit.registerHandler(org.smilkit.handler.RTMPVideoHandler, RTMPVideoHandler.toHandlerMap());
			SMILKit.registerHandler(org.smilkit.handler.HTTPVideoHandler, HTTPVideoHandler.toHandlerMap());
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
			SMILKit.__handlers.setItem(handlerMap, handlerClass);
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
			for (var i:int = (SMILKit.__handlers.length-1); i >= 0; i--)
			{
				var handler:HandlerMap = SMILKit.__handlers.getKeyAt(i) as HandlerMap;
				
				if (handler.match(element))
				{
					return SMILKit.__handlers.getItemAt(i) as Class;
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
			var klass:Class = SMILKit.findHandlerClassFor(element);
			
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
				SMILKit.__handlers.removeAll();
			}
			else
			{
				for (var i:int = SMILKit.__handlers.length; i > 0; i--)
				{
					var hClass:Class = SMILKit.__handlers.getItemAt(i) as Class;
					var hMap:HandlerMap = SMILKit.__handlers.getKeyAt(i) as HandlerMap;
					
					if (handlerClass == hClass)
					{
						if (handlerMap == null || hMap == handlerMap)
						{
							SMILKit.__handlers.removeItemAt(i);
						}	
					}
				}
			}
		}
	}
}