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