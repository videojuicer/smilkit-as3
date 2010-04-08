package org.smilkit
{
	import mx.core.ClassFactory;
	
	import org.smilkit.dom.Document;
	import org.smilkit.dom.DocumentType;
	import org.smilkit.handler.ImageHandler;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.handler.VideoHandler;
	import org.smilkit.util.HashMap;
	import org.smilkit.util.KeyPairHashMap;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	/**
	 * SMILKit's main static API object, allows the creation, manipulation and browsing of SMIL3.0 DOM documents.
	 * 
	 * Implements the W3C DOM Level 2 specification and SMIL 3.0 Boston DOM specification.
	 * 
	 * @see Document Object Model (DOM) Level 2 Views Specification: http://www.w3.org/TR/2000/REC-DOM-Level-2-Views-20001113
	 * @see SMIL Boston DOM: http://www.w3.org/TR/smil-boston-dom/
	 */
	public class SMILKit
	{
		private static var __version:String = "0.1.0";
		private static var __handlers:KeyPairHashMap = new KeyPairHashMap();
		
		/**
		 * Retrieve's the current SMILKit version.
		 */
		public static function get version():String
		{
			return SMILKit.__version;
		}
		
		/**
		 * Create's a new SMIL 3.0 DOM <code>Document</code>.
		 * 
		 * @see org.smilkit.dom.Document
		 * @see org.smilkit.w3c.dom.IDocument
		 */
		public static function createSMILDocument():IDocument
		{
			return new Document(new DocumentType(null, "smil"));
		}
		
		public static function loadSMILDocument(smilURI:String):IDocument
		{
			return null;
		}
		
		private static function registerDefaultHandlers():void
		{
			SMILKit.registerHandler("animation", null);
			SMILKit.registerHandler("audio", null);
			SMILKit.registerHandler("img", org.smilkit.handler.ImageHandler);
			SMILKit.registerHandler("text", null);
			SMILKit.registerHandler("video", org.smilkit.handler.VideoHandler);
		}
		
		public static function handlerRegisteredFor(type:String):Boolean
		{
			return SMILKit.__handlers.hasItem(type);
		}
		
		public static function registerHandler(type:String, handlerClass:Class):void
		{
			SMILKit.__handlers.setItem(type, handlerClass);
		}
		
		public static function findHandler(type:String):Class
		{
			return SMILKit.__handlers.getItem(type) as Class;
		}
		
		public static function createElementHandler(type:String, element:ISMILMediaElement):SMILKitHandler
		{
			var klass:Class = SMILKit.findHandler(type);
			var factory:ClassFactory = new ClassFactory(klass);
			
			return factory.newInstance();
		}
		
		public static function removeHandler(type:String):void
		{
			SMILKit.__handlers.removeItem(type);
		}
	}
}