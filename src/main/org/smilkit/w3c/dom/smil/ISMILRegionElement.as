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
package org.smilkit.w3c.dom.smil
{
	public interface ISMILRegionElement extends ISMILElement, IElementLayout
	{		
		/* added by smilkit */		
		function get backgroundOpacity():String;
		
		function get fit():String;
		function set fit(fit:String):void;
		
		function get top():String;
		function set top(top:String):void;
		
		/* added by smilkit */
		function get bottom():String;
		function set bottom(bottom:String):void;
		
		/* added by smilkit */
		function get left():String;
		function set left(left:String):void;
		
		/* added by smilkit */
		function get right():String;
		function set right(right:String):void;
		
		function get zIndex():String;
		function set zIndex(zIndex:String):void;
	}
}