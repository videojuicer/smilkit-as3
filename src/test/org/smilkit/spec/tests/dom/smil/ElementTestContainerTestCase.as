package org.smilkit.spec.tests.dom.smil
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILDocumentVariables;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;

	public class ElementTestContainerTestCase
	{
		protected var _document:SMILDocument;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			
			this._document = (parser.parse(Fixtures.ELEMENT_TEST_SMIL_XML) as SMILDocument);
			
			this._document.variables.set(SMILDocumentVariables.SYSTEM_AUDIO_DESC, "off");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_BASE_PROFILE, "");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_BITRATE, 58000);
			this._document.variables.set(SMILDocumentVariables.SYSTEM_CAPTIONS, "off");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_COMPONENT, "");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_CONTENT_LOCATION, "");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_CPU, "x64");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_LANGUAGE, "");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_OPERATING_SYSTEM, "linux");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_OVERDUB_OR_CAPTION, "caption");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_OVERDUB_OR_SUBTITLE, "subtitle");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_REQUIRED, "");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_SCREEN_DEPTH, "32");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_SCREEN_SIZE, "1680x1520");
			this._document.variables.set(SMILDocumentVariables.SYSTEM_VERSION, 3.0);
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
		}
		
		[Test(description="Tests that the renderState is set correctly during tests")]
		public function testRenderState():void
		{
			var element:ElementTestContainer = (this._document.getElementById("booleanExpression") as ElementTestContainer);
			
			element.updateRenderState();
			
			Assert.assertEquals(ElementTestContainer.RENDER_STATE_ACTIVE, element.renderState);
			
			element = (this._document.getElementById("fail_booleanExpression") as ElementTestContainer);
			
			element.updateRenderState();
			
			Assert.assertEquals(ElementTestContainer.RENDER_STATE_HIDDEN, element.renderState);
		}
		
		[Test(description="Tests that an element can match against a custom boolean expression")]
		public function testAgainstBooleanExpression():void
		{
			var element:ElementTestContainer = (this._document.getElementById("booleanExpression") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_booleanExpression") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.expression);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.expression);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.expression);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests that an element can match against systemAudioDesc")]
		public function testAgainstSystemAudioDesc():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemAudioDesc") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemAudioDesc") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemAudioDesc);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemAudioDesc);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemAudioDesc);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemBaseProfile")]
		public function testAgainstSystemBaseProfile():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemBaseProfile") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemBaseProfile") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemBaseProfile);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemBaseProfile);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemBaseProfile);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemBitrate")]
		public function testAgainstSystemBitrate():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemBitrate") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemBitrate") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemBitrate);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemBitrate);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemBitrate);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemCaptions")]
		public function testAgainstSystemCaptions():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemCaptions") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemCaptions") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemCaptions);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemCaptions);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemCaptions);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemComponent")]
		public function testAgainstSystemComponent():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemComponent") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemComponent") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemComponent);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemComponent);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemComponent);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemContentLocation")]
		public function testAgainstSystemContentLocation():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemContentLocation") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemContentLocation") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemContentLocation);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemContentLocation);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemContentLocation);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemCPU")]
		public function testAgainstSystemCPU():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemCPU") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemCPU") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemCPU);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemCPU);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemCPU);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemLanguage")]
		public function testAgainstSystemLanguage():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemLanguage") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemLanguage") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemLanguage);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemLanguage);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemLanguage);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemOperatingSystem")]
		public function testAgainstSystemOperatingSystem():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemOperatingSystem") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemOperatingSystem") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemOperatingSystem);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemOperatingSystem);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemOperatingSystem);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}

		[Test(description="Tests than an element can match against systemOverdubOrCaption")]
		public function testAgainstSystemOverdubOrCaption():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemOverdubOrCaption") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemOverdubOrCaption") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemOverdubOrCaption);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemOverdubOrCaption);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemOverdubOrCaption);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemOverdubOrSubtitle")]
		public function testAgainstSystemOverdubOrSubtitle():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemOverdubOrSubtitle") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemOverdubOrSubtitle") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemOverdubOrSubtitle);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemOverdubOrSubtitle);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemOverdubOrSubtitle);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemRequired")]
		public function testAgainstSystemRequired():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemRequired") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemRequired") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemRequired);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemRequired);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemRequired);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}

		[Test(description="Tests than an element can match against systemScreenDepth")]
		public function testAgainstSystemScreenDepth():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemScreenDepth") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemScreenDepth") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemScreenDepth);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemScreenDepth);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemScreenDepth);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemScreenSize")]
		public function testAgainstSystemScreenSize():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemScreenSize") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemScreenSize") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemScreenSize);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemScreenSize);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemScreenSize);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
		
		[Test(description="Tests than an element can match against systemVersion")]
		public function testAgainstSystemVersion():void
		{
			var element:ElementTestContainer = (this._document.getElementById("systemVersion") as ElementTestContainer);
			var failed:ElementTestContainer = (this._document.getElementById("fail_systemVersion") as ElementTestContainer);
			var empty:ElementTestContainer = (this._document.getElementById("empty") as ElementTestContainer);
			
			Assert.assertEquals(ElementTestContainer.TEST_PASSED, element.systemVersion);
			Assert.assertEquals(ElementTestContainer.TEST_SKIPPED, empty.systemVersion);
			Assert.assertEquals(ElementTestContainer.TEST_FAILED, failed.systemVersion);
			
			Assert.assertTrue(element.test());
			Assert.assertFalse(failed.test());
		}
	}
}