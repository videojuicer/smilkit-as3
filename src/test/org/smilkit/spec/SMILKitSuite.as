package org.smilkit.spec
{
	import flash.media.Video;
	
	import org.smilkit.handler.HTTPVideoHandler;
	import org.smilkit.spec.tests.dom.BostonDOMParserTestCase;
	import org.smilkit.spec.tests.dom.DocumentTestCase;
	import org.smilkit.spec.tests.dom.ElementTestCase;
	import org.smilkit.spec.tests.dom.EventTestCase;
	import org.smilkit.spec.tests.dom.TimeTestCase;
	import org.smilkit.spec.tests.handler.HTTPVideoHandlerTestCase;
	import org.smilkit.spec.tests.handler.HandlerTestCase;
	import org.smilkit.spec.tests.view.ViewportTestCase;
	
	/**
	 * DOM test suite, contains <code>TestCases</code> for testing SMILKits implemented DOM.
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class SMILKitSuite
	{
		// SMIL DOM Tests
		public var documentTest:DocumentTestCase;
		public var elementTest:ElementTestCase;
		public var bostonDOMParserTest:BostonDOMParserTestCase;
		public var eventTest:EventTestCase;
		public var timeTest:TimeTestCase;
		
		// Asset Handler Tests
		public var handlerTest:HandlerTestCase;
		public var httpVideoHandlerTest:HTTPVideoHandlerTestCase;
		
		// View Tests
		public var viewportTest:ViewportTestCase;
	}
}