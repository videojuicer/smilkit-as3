package org.smilkit
{
	/**
	 * SMILKit's main static API object, allows the creation of SMIL3.0 DOM documents from SMIL XML.
	 * Implements the W3C DOM Level 2 specification and SMIL 3.0 Boston DOM specification.
	 * 
	 * @see Document Object Model (DOM) Level 2 Views Specification (http://www.w3.org/TR/2000/REC-DOM-Level-2-Views-20001113)
	 * @see SMIL Boston DOM (http://www.w3.org/TR/smil-boston-dom/)
	 */
	public class SMILKit
	{
		private static var __version:String = "0.1.0";
		
		/**
		 * Retrieve's the current SMILKit version.
		 */
		public static function get version():String
		{
			return SMILKit.__version;
		}
	}
}