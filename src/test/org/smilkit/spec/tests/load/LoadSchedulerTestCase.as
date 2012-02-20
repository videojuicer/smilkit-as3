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
package org.smilkit.spec.tests.load
{
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	import flexunit.framework.AsyncTestHelper;
	
	import org.flexunit.async.Async;
	
	import org.smilkit.spec.Fixtures;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.dom.Element;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.load.LoadScheduler;
	import org.smilkit.load.Worker;
	import org.smilkit.view.extensions.SMILViewport;
	import org.smilkit.events.WorkerEvent;
	import org.smilkit.events.WorkUnitEvent;
	import org.smilkit.events.ViewportEvent;
	
	import org.smilkit.spec.mock.MockHandler;

	
	public class LoadSchedulerTestCase
	{		
		protected var _viewport:SMILViewport;
		protected var _scheduler:LoadScheduler;
		protected var _document:ISMILDocument;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.MP4_VIDEO_SMIL_XML) as ISMILDocument);
			
			this._viewport = new SMILViewport();
			// dont want to actually load
			this._viewport.autoRefresh = false;
			//this._scheduler = this._viewport._objectPool.loadScheduler;
		}
		
		[After]
		public function tearDown():void
		{
			this._viewport = null;
			this._scheduler = null;
		}
		
		[Test(description="TODO - empty test cases fail")]
		public function replaceWithTests():void
		{
			
		}
	}
	
	// Pending tests:
	
	// Has all three workers instantiated on creation
	
	// Starting when stopped returns true and causes the master worker to start
	
	// Stopping when started returns true and causes the master worker to stop
	
	// When notified that a work unit was cancelled or queued, checks all other workers for active instances of that handler and broadcasts 
	// removedFromLoadScheduler if not existent elsewhere
	
	// When rebuilding the JIT list, remove elements from the other queues first
	
	// When rebuilding the resolve queue, remove elements from the preload queue first
	
	// When rebuilding the queues, includes only unresolved resolvables in the resolve queue
	
	// When rebuilding the queues, includes only unloaded preloadables in the preload queue
	
}