package org.smilkit.spec
{
	import flash.media.Video;
	
	import org.smilkit.handler.HTTPVideoHandler;
	import org.smilkit.render.DrawingBoard;
	import org.smilkit.render.RenderTree;
	import org.smilkit.spec.tests.dom.BostonDOMParserTestCase;
	import org.smilkit.spec.tests.dom.DocumentTestCase;
	import org.smilkit.spec.tests.dom.ElementTestCase;
	import org.smilkit.spec.tests.dom.EventTestCase;
	import org.smilkit.spec.tests.dom.TimeTestCase;
	import org.smilkit.spec.tests.handler.HTTPVideoHandlerTestCase;
	import org.smilkit.spec.tests.handler.HandlerTestCase;
	import org.smilkit.spec.tests.handler.RTMPVideoHandlerTestCase;
	import org.smilkit.spec.tests.load.LoadSchedulerTestCase;
	import org.smilkit.spec.tests.load.WorkerTestCase;
	import org.smilkit.spec.tests.render.DrawingBoardTestClass;
	import org.smilkit.spec.tests.render.RenderTreeTestCase;
	import org.smilkit.spec.tests.time.HeartbeatTestCase;
	import org.smilkit.spec.tests.time.TimingGraphTestCase;
	import org.smilkit.spec.tests.view.ViewportTestCase;
	import org.smilkit.time.TimingGraph;
	
	/**
	 * DOM test suite, contains <code>TestCases</code> for testing SMILKits implemented DOM.
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class SMILKitSuite
	{
		// SMIL DOM Tests
		public var documentTest:DocumentTestCase;
		public var elementTest:ElementTestCase;
		public var bostonDOMParserTest:BostonDOMParserTestCase;
		public var eventTest:EventTestCase;
		public var timeTest:TimeTestCase;
		
		// Asset Handler Tests
		public var handlerTest:HandlerTestCase;
		public var httpVideoHandlerTest:HTTPVideoHandlerTestCase;
		
		// TODO: need a testable rtmp stream (not highwinds because of the url signing)
		//public var rtmpVideoHandlerTest:RTMPVideoHandlerTestCase;
		
		// View Tests
		public var viewportTest:ViewportTestCase;
		public var drawingBoardTest:DrawingBoardTestClass;
		public var heartbeatTest:HeartbeatTestCase;
		public var renderTreeTest:RenderTreeTestCase;
		public var timingGraph:TimingGraphTestCase;
		public var loadSchedulerTest:LoadSchedulerTestCase;
		public var workerTest:WorkerTestCase;
	}
}