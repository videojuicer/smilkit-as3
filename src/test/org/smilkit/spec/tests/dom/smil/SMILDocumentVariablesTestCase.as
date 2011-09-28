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
	
	import org.flexunit.async.Async;
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.expressions.SMILDocumentVariables;
	import org.smilkit.dom.smil.events.SMILMutationEvent;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	
	public class SMILDocumentVariablesTestCase
	{
		protected var _document:SMILDocument;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			
			this._document = (parser.parse(Fixtures.ELEMENT_TEST_SMIL_XML) as SMILDocument);
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
		}
		
		[Test(async,description="Tests that variables stored in the DOM can be inserted and admit a INSERTED event")]
		public function variablesCanBeStored():void
		{
			var listen:Function = Async.asyncHandler(this, this.onVariableSet, 1000, null, this.onVariableSetTimeout);
			
			this._document.variables.set("hello", "world");
			
			this._document.addEventListener(SMILMutationEvent.DOM_VARIABLES_INSERTED, listen, false);
			
			this._document.variables.set("int", 50);
		}
		
			protected function onVariableSet(e:SMILMutationEvent, passThru:Object = null):void
			{
				Assert.assertEquals("world", this._document.variables.get("hello"));
				Assert.assertEquals(50, this._document.variables.get("int"));
			}
			
			protected function onVariableSetTimeout(passThru:Object = null):void
			{
				Assert.fail("Timeout occured whilst waiting for the DOM_VARIABLES_INSERTED event");
			}
		
		[Test(async,description="Tests that variables stored in the DOM can be removed and admit a REMOVED event")]
		public function variablesCanBeUnset():void	
		{
			var listen:Function = Async.asyncHandler(this, this.onVariableUnset, 1000, null, this.onVariableUnsetTimeout);
			
			this._document.variables.set("hello", "world");

			Assert.assertEquals("world", this._document.variables.get("hello"));
			
			this._document.addEventListener(SMILMutationEvent.DOM_VARIABLES_REMOVED, listen, false);
			
			this._document.variables.set("hello", null);
		}
		
			protected function onVariableUnset(e:SMILMutationEvent, passThru:Object = null):void
			{
				Assert.assertNull(this._document.variables.get("hello"));
			}
			
			protected function onVariableUnsetTimeout(passThru:Object = null):void
			{
				Assert.fail("Timeout occured whilst waiting for the DOM_VARIABLES_REMOVED event");
			}
		
		[Test(description="Tests that variables that dont exist return null")]
		public function variablesThatDontExistReturnNull():void
		{
			Assert.assertNull(this._document.variables.get("nothing"));
			Assert.assertNull(this._document.variables.get("int"));
			Assert.assertNull(this._document.variables.get("hello"));}
		
		[Test(async,description="Tests that variables stored in the DOM can be modified and admit a MODIFIED event")]
		public function variablesCanBeModified():void	
		{
			var listen:Function = Async.asyncHandler(this, this.onVariableModified, 1000, null, this.onVariableModifiedTimeout);
			
			this._document.variables.set("hello", "world");
			this._document.variables.set("int", 50);
			
			Assert.assertEquals("world", this._document.variables.get("hello"));
			
			this._document.variables.set("hello", "smilkit");
			
			this._document.addEventListener(SMILMutationEvent.DOM_VARIABLES_MODIFIED, listen, false);
			
			this._document.variables.set("int", 100);
		}
		
			protected function onVariableModified(e:SMILMutationEvent, passThru:Object = null):void
			{
				Assert.assertEquals("smilkit", this._document.variables.get("hello"));
				Assert.assertEquals(100, this._document.variables.get("int"));
			}
			
			protected function onVariableModifiedTimeout(passThru:Object = null):void
			{
				Assert.fail("Timeout occured whilst waiting for the DOM_VARIABLES_MODIFIED event");
			}
	}
}