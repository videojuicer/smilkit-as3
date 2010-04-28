package org.smilkit.spec
{
	import org.smilkit.spec.tests.HandlerTestCase;
	import org.smilkit.spec.tests.dom.BostonDOMParserTestCase;
	import org.smilkit.spec.tests.dom.DocumentTestCase;
	import org.smilkit.spec.tests.dom.ElementTestCase;
	import org.smilkit.spec.tests.dom.EventTestCase;
	import org.smilkit.spec.tests.dom.TimeTestCase;
	
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
	}
}