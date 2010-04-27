package org.smilkit.spec
{
	import org.smilkit.spec.tests.BostonDOMParserTestCase;
	import org.smilkit.spec.tests.DocumentTestCase;
	import org.smilkit.spec.tests.ElementTestCase;
	import org.smilkit.spec.tests.EventTestCase;
	import org.smilkit.spec.tests.TimeTestCase;
	
	/**
	 * DOM test suite, contains <code>TestCases</code> for testing SMILKits implemented DOM.
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class DOMSuite
	{
		public var documentTest:DocumentTestCase;
		public var elementTest:ElementTestCase;
		public var bostonDOMParserTest:BostonDOMParserTestCase;
		public var eventTest:EventTestCase;
		public var timeTest:TimeTestCase;
	}
}