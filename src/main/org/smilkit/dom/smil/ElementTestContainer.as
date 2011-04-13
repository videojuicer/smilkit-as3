package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.IElementTest;
	
	public class ElementTestContainer extends ElementTimeContainer implements IElementTest
	{	
		public static const TEST_PASSED:uint = 1;
		public static const TEST_SKIPPED:uint = 2;
		public static const TEST_FAILED:uint = 0;
		
		public function ElementTestContainer(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		protected function get variables():SMILDocumentVariables
		{
			return (this.ownerDocument as SMILDocument).variables;
		}
		
		public function get systemAudioDesc():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_AUDIO_DESC);
		}
		
		public function get systemBaseProfile():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_BASE_PROFILE);
		}
		
		public function get systemBitrate():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_BITRATE);
		}
		
		public function get systemCaptions():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_CAPTIONS);
		}
		
		public function get systemComponent():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_COMPONENT);
		}
		
		public function get systemContentLocation():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_CONTENT_LOCATION);
		}
		
		public function get systemCPU():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_CPU);
		}
		
		public function get systemLanguage():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_LANGUAGE);
		}
		
		public function get systemOperatingSystem():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_OPERATING_SYSTEM);
		}
		
		public function get systemOverdubOrCaption():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_OVERDUB_OR_CAPTION);
		}
		
		public function get systemOverdubOrSubtitle():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_OVERDUB_OR_SUBTITLE);
		}
		
		public function get systemRequired():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_REQUIRED);
		}
		
		public function get systemScreenDepth():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_SCREEN_DEPTH);
		}
		
		public function get systemScreenSize():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_SCREEN_SIZE);
		}
		
		public function get systemVersion():uint
		{
			return this.testAttribute(SMILDocumentVariables.SYSTEM_VERSION);
		}
		
		public function get customTest():uint
		{
			// look up the custom test and evaluate it, for SMILKit-as3 0.4
			
			return ElementTestContainer.TEST_SKIPPED;
		}
		
		public function test():Boolean
		{
			var results:Vector.<uint> = new Vector.<uint>();
			results.push(this.systemAudioDesc);
			results.push(this.systemBaseProfile);
			results.push(this.systemBitrate);
			results.push(this.systemCaptions);
			results.push(this.systemComponent);
			results.push(this.systemContentLocation);
			results.push(this.systemCPU);
			results.push(this.systemLanguage);
			results.push(this.systemOperatingSystem);
			results.push(this.systemOverdubOrCaption);
			results.push(this.systemOverdubOrSubtitle);
			results.push(this.systemRequired);
			results.push(this.systemScreenDepth);
			results.push(this.systemScreenSize);
			results.push(this.systemVersion);
			results.push(this.customTest);
			
			// run the tests on the Element
			var skips:uint = 0;
			var fails:uint = 0;
			var passes:uint = 0;
			
			for (var i:uint = 0; i < results.length; i++)
			{
				var result:uint = results[i];
				
				if (result == ElementTestContainer.TEST_FAILED)
				{
					fails++;
				}
				else if (result == ElementTestContainer.TEST_SKIPPED)
				{
					skips++;
				}
			}
			
			passes = (results.length - (fails + skips));
			
			return (fails == 0);
		}
		
		public function testAttribute(attributeName:String):uint
		{
			var attributeValue:String = this.getAttribute(attributeName);
			
			if (attributeValue != null)
			{
				var documentValue:Object = (this.variables.get(attributeName) as Object);
				
				// set a null value to an empty string so we can still validate
				if (documentValue == null)
				{
					documentValue = "";
				}
				
				if (documentValue is Number)
				{
					if (attributeValue <= documentValue)
					{
						return ElementTestContainer.TEST_PASSED;
					}
				}
				else
				{
					if (attributeValue == documentValue)
					{
						return ElementTestContainer.TEST_PASSED;
					}
				}
			}
			else
			{
				return ElementTestContainer.TEST_SKIPPED;
			}
			
			return ElementTestContainer.TEST_FAILED;
		}
	}
}