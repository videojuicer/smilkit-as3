package org.smilkit.spec.tests.load
{
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	import flexunit.framework.AsyncTestHelper;
	
	import org.flexunit.async.Async;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.view.Viewport;

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
		}
		
		[After]
		public function tearDown():void
		{
			this._viewport = null;
			this._scheduler = null;
		}
	}
	
	// Pending tests:
	
	
}