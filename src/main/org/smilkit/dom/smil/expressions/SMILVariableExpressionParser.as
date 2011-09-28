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
package org.smilkit.dom.smil.expressions
{
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.dom.smil.SMILDocument;
	
	public class SMILVariableExpressionParser extends SMILReferenceExpressionParser
	{
		protected var _variables:SMILDocumentVariables = null;
		
		public function SMILVariableExpressionParser(relatedContainer:ElementTestContainer)
		{
			super(relatedContainer);
			
			if (this.relatedContainer != null)
			{
				this._variables = (this.relatedContainer.ownerDocument as SMILDocument).variables;
			
				this.configuration.functions.setItem("smil-audioDesc", this.systemAudioDesc);
				this.configuration.functions.setItem("smil-bitrate", this.systemBitrate);
				this.configuration.functions.setItem("smil-captions", this.systemCaptions);
				this.configuration.functions.setItem("smil-component", this.systemComponent);
				this.configuration.functions.setItem("smil-CPU", this.systemCPU);
				this.configuration.functions.setItem("smil-language", this.systemLanguage);
				this.configuration.functions.setItem("smil-operatingSystem", this.systemOperatingSystem);
				this.configuration.functions.setItem("smil-overdubOrSubtitle", this.systemOverdubOrSubtitle);
				this.configuration.functions.setItem("smil-required", this.systemRequired);
				this.configuration.functions.setItem("smil-screenDepth", this.systemScreenDepth);
				this.configuration.functions.setItem("smil-screenHeight", this.systemScreenHeight);
				this.configuration.functions.setItem("smil-screenWidth", this.systemScreenWidth);
				
				this.configuration.functions.setItem("smil-customTest", this.customTest);
			}
		}
		
		public function get variables():SMILDocumentVariables
		{
			return this._variables;
		}
		
		protected function systemAudioDesc():Boolean
		{
			return false;
		}
		
		protected function systemBitrate():Number
		{
			return (this.variables.get(SMILDocumentVariables.SYSTEM_BITRATE) as Number);
		}
		
		protected function systemCaptions():Boolean
		{
			return false;
		}
		
		protected function systemComponent(uri:String):Boolean
		{
			return false;
		}
		
		protected function systemCPU():String
		{
			return (this.variables.get(SMILDocumentVariables.SYSTEM_CPU) as String);
		}
		
		protected function systemLanguage(lang:String):Number
		{
			return 0;
		}
		
		protected function systemOperatingSystem():String
		{
			return (this.variables.get(SMILDocumentVariables.SYSTEM_OPERATING_SYSTEM) as String);
		}
		
		protected function systemOverdubOrSubtitle():String
		{
			return null;
		}
		
		protected function systemRequired(uri:String):Boolean
		{
			return false;
		}
		
		protected function systemScreenDepth():Number
		{
			return (this.variables.get(SMILDocumentVariables.SYSTEM_SCREEN_DEPTH) as Number);
		}
		
		protected function systemScreenHeight():Number
		{
			return 0;
		}
		
		protected function systemScreenWidth():Number
		{
			return 0;
		}
		
		protected function customTest(name:String):Boolean
		{
			return false;
		}
	}
}