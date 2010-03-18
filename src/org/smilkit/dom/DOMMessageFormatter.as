package org.smilkit.dom
{
	/**
	 * Creates formatted DOM messages for DOM2.0, SMIL3.0 and XML.
	 * 
	 * @see org.smilkit.w3c.dom.DOMException
	 */
	public class DOMMessageFormatter
	{
		public static var DOM_DOMAIN:String = "http://www.w3.org/dom/DOMTR";
		public static var XML_DOMAIN:String = "http://www.w3.org/TR/1998/REC-xml-19980210";
		public static var SMIL_DOMAIN:String = "";
		
		/**
		 * Formats a DOM message with the specified arguments and information.
		 * 
		 * @param domain DOM domain from which the error occured.
		 * @param key The message / error key.
		 * 
		 * @return The formatted message as a String.
		 */
		public static function formatMessage(domain:String, key:String):String
		{
			// TODO: should use a bundle to format the key into a human readable format
			return key +" on "+ domain;
		}
	}
}