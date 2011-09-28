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
package org.smilkit.spec.tests.dom.smil
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.expressions.SMILDocumentVariables;
	import org.smilkit.dom.smil.SMILSwitchElement;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	
	public class SMILSwitchElementTestCase
	{
		protected var _document:SMILDocument;
		protected var _extendedDocument:SMILDocument;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			
			this._document = (parser.parse(Fixtures.BASIC_SWITCH_SMIL_XML) as SMILDocument);
			this._document.variables.set(SMILDocumentVariables.SYSTEM_VERSION, 3.0);
			
			this._extendedDocument = (parser.parse(Fixtures.EXTENDED_SWITCH_SMIL_XML) as SMILDocument);
			this._extendedDocument.variables.set(SMILDocumentVariables.SYSTEM_VERSION, 3.0);
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
			this._extendedDocument = null;
		}
		
		[Test(description="Tests that a document with a switch block resolves to the correct time (using only the selected child duration)")]
		public function documentWithSwitchResolvesCorrectly():void
		{
			var element:SMILSwitchElement = (this._document.getElementById("switch_block") as SMILSwitchElement);
			var selected:ElementTestContainer = (element.selectedElement as ElementTestContainer);
			
			Assert.assertNotNull(element);
			Assert.assertNotNull(selected);
		
			selected.startup();
			
			Assert.assertEquals(5, element.currentEndInterval.resolvedOffset);
			Assert.assertEquals(5, (element.parentTimeContainer as ElementTimeContainer).currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Tests that a switch block selects the correct element based on the first child to pass the tests")]
		public function switchSelectsCorrectElement():void
		{
			var element:SMILSwitchElement = (this._document.getElementById("switch_block") as SMILSwitchElement);
			
			Assert.assertNotNull(element);
			
			Assert.assertEquals(3.0, (element.selectedElement as ElementTestContainer).getAttribute(SMILDocumentVariables.SYSTEM_VERSION));
			
			this._document.variables.set(SMILDocumentVariables.SYSTEM_VERSION, 2.0);
			
			Assert.assertEquals(2.0, (element.selectedElement as ElementTestContainer).getAttribute(SMILDocumentVariables.SYSTEM_VERSION));
			
			this._document.variables.set(SMILDocumentVariables.SYSTEM_VERSION, null);
			
			Assert.assertEquals(null, (element.selectedElement as ElementTestContainer).getAttribute(SMILDocumentVariables.SYSTEM_VERSION));
		}
		
		[Test(description="Tests that a switch block with non-testable elements still works and selects the first element that is testable and passes")]
		public function switchIgnoresNonTestContainers():void
		{
			var element:SMILSwitchElement = (this._document.getElementById("switch_block") as SMILSwitchElement);
			var selected:ElementTestContainer = (element.selectedElement as ElementTestContainer);
			
			Assert.assertNotNull(element);
			Assert.assertNotNull(selected);
			
			selected.startup();
			
			Assert.assertEquals(3.0, selected.getAttribute(SMILDocumentVariables.SYSTEM_VERSION));
			Assert.assertEquals(5, selected.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(5, element.currentEndInterval.resolvedOffset);
		}
	}
}