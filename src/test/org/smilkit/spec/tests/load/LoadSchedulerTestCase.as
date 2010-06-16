package org.smilkit.spec.tests.load
{
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	import flexunit.framework.AsyncTestHelper;
	
	import org.flexunit.async.Async;
	
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.view.Viewport;
	import org.smilkit.load.LoadScheduler;

	public class LoadSchedulerTestCase
	{		
		protected var _viewport:Viewport;
		protected var _scheduler:LoadScheduler;
		
		[Before]
		public function setUp():void
		{
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
	
	// When rebuilding the queues, includes only unresolved resolvables in the resolve queue
	// When rebuilding the queues, includes only unloaded preloadables in the preload queue
	
}