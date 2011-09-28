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
		public static var SMIL3_DOMAIN:String = "http://www.w3.org/TR/2008/REC-SMIL3-20081201/";
		
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