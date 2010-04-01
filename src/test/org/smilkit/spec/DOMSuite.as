package org.smilkit.spec
{
	import org.smilkit.spec.tests.DocumentTestCase;
	import org.smilkit.spec.tests.ElementTestCase;
	
	/**
	 * DOM test suite, contains <code>TestCases</code> for testing SMILKits implemented DOM.
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class DOMSuite
	{
		public var documentTest:DocumentTestCase;
		public var elementTest:ElementTestCase;
	}
}