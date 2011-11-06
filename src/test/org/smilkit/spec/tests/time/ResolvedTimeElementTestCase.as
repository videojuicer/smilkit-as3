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
package org.smilkit.spec.tests.time
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.DocumentType;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.time.SMILTimeInstance;
	import org.smilkit.dom.smil.Time;

	public class ResolvedTimeElementTestCase
	{		
		private var resolvedTimeElement:SMILTimeInstance;
			
		[Before]
		public function setUp():void
		{
			this.resolvedTimeElement = new SMILTimeInstance(
				new SMILMediaElement(new SMILDocument(new DocumentType(null, "smil", "-//W3C//DTD SMIL 3.0 Language//EN", "http://www.w3.org/2008/SMIL30/SMIL30Language.dtd")), "tester"), 
				new Time(null, true, "0ms"),
				new Time(null, false, "10s"));
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
			Assert.assertEquals(0, resolvedTimeElement.begin.resolvedOffset);
			// test has an end
			Assert.assertEquals(10, resolvedTimeElement.end.resolvedOffset);
			// test reports active true
			Assert.assertTrue(resolvedTimeElement.activeAt(1));
			// test reports active false
			Assert.assertFalse(resolvedTimeElement.activeAt(12));
		}
		
		
	}
}