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
package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;

	public class ElementTime
	{
		public static var RESTART_ALWAYS:int = 0;
		public static var RESTART_NEVER:int = 1;
		public static var RESTART_WHEN_NOT_ACTIVE:int = 2;
		
		public static var FILL_REMOVE:int = 0;
		public static var FILL_FREEZE:int = 1;
		
		public static function timeAttributeToTimeType(value:String, baseElement:IElementTimeContainer, baseBegin:Boolean):int
		{
			var type:int = Time.SMIL_TIME_SYNC_BASED;
			
			// we only care if the duration is indefinite if were at the end, as the begin node will always
			// follow its parent or previous sibling
			if (baseElement.dur == "indefinite" && !baseBegin)
			{
				type = Time.SMIL_TIME_INDEFINITE;
			}
			
			return type;
		}
	}
}