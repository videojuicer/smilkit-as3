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
	import org.smilkit.view.Viewport;
	import org.smilkit.events.WorkerEvent;
	import org.smilkit.events.WorkUnitEvent;
	import org.smilkit.events.ViewportEvent;
	
	import org.smilkit.spec.mock.MockHandler;

	
	public class LoadSchedulerTestCase
	{		
		protected var _viewport:Viewport;
		protected var _scheduler:LoadScheduler;
		protected var _document:ISMILDocument;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.MP4_VIDEO_SMIL_XML) as ISMILDocument);
			
			this._viewport = new Viewport();
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