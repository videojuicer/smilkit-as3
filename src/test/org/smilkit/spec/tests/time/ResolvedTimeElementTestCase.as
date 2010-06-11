package org.smilkit.spec.tests.time
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.DocumentType;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.time.TimingNode;

	public class ResolvedTimeElementTestCase
	{		
		private var resolvedTimeElement:TimingNode;
			
		[Before]
		public function setUp():void
		{
			resolvedTimeElement= new TimingNode(
				new SMILMediaElement(new SMILDocument(new DocumentType(null, "smil", "-//W3C//DTD SMIL 3.0 Language//EN", "http://www.w3.org/2008/SMIL30/SMIL30Language.dtd")), "tester"), 
				0, 
				10);

		}
		
		[After]
		public function tearDown():void
		{
			resolvedTimeElement = null;
		}
		
		[Test(description="Tests that a ResolvedTimeElement is populated")]
		public function isPopulated():void
		{
			// test has a start
			Assert.assertEquals(0, resolvedTimeElement.begin);
			// test has an end
			Assert.assertEquals(10, resolvedTimeElement.end);
			// test reports active true
			Assert.assertTrue(resolvedTimeElement.activeAt(1));
			// test reports active false
			Assert.assertFalse(resolvedTimeElement.activeAt(12));
		}
		
		
	}
}