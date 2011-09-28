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
	public interface IElementTest
	{
		function get systemBitrate():uint;
		
		
		function get systemCaptions():uint;
		
		
		function get systemLanguage():uint;
		
		
		function get systemRequired():uint;
		function get systemScreenSize():uint;
		function get systemScreenDepth():uint;
		
		function get systemOverdubOrSubtitle():uint;
		
		
		function get systemAudioDesc():uint;
		
		
		// not really sure why the Boston DOM implements this class with both boolean
		// and string properties, to clean up the class we have made every property
		// read only and returns the result of the test. If the attribute is null
		// the properties return false, so the tests should only be ran if the attribute exists.
		
		//function set systemBitrate(systemBitrate:int):void;
		//function set systemCaptions(systemCaptions:Boolean):void;
		//function set systemLanguage(systemLanguage:String):void;
		//function set systemOverdubOrSubtitle(systemOverdubOrSubtitle:String):void;
		//function set systemAudioDesc(systemAudioDesc:Boolean):void;
	}
}