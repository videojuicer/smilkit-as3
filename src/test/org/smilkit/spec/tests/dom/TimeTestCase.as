package org.smilkit.spec.tests.dom
{
	import flexunit.framework.Assert;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.smil.ElementSequentialTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.view.Viewport;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementParallelTimeContainer;
	import org.smilkit.w3c.dom.smil.IElementSequentialTimeContainer;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.smilkit.w3c.dom.smil.ITimeList;

	public class TimeTestCase
	{		
		protected var _seqDocument:ISMILDocument;
		protected var _parDocument:ISMILDocument;
		protected var _unresolvedDocument:ISMILDocument;
		
		protected var _viewport:Viewport;
		
		[Before]
		public function setUp():void
		{
			SMILKit.defaults();
			
			this._viewport = new Viewport();
			this._viewport.location = "data:text/plain;charset=utf-8,"+Fixtures.BASIC_UNRESOLVED_SMIL_XML;
			
			var parser:BostonDOMParser = new BostonDOMParser();
			this._seqDocument = (parser.parse(Fixtures.BASIC_SEQ_SMIL_XML) as ISMILDocument);
			this._parDocument = (parser.parse(Fixtures.BASIC_PAR_SMIL_XML) as ISMILDocument);
		}
		
		private function get document():SMILDocument
		{
			return (this._viewport.document as SMILDocument);
		}
		
		[Test(description="Tests a document is unresolved and that the elements can resolve over time.")]
		public function unresolvedAssetsResolvedCorrectly():void
		{
			var sequenceLeft:ElementSequentialTimeContainer = (this.document.getElementById("left") as ElementSequentialTimeContainer);
			var sequenceRight:ElementSequentialTimeContainer = (this.document.getElementById("right") as ElementSequentialTimeContainer);
			
			var prerollLeft:ISMILMediaElement = (this.document.getElementById("preroll_left") as ISMILMediaElement);
			var contentLeft:ISMILMediaElement = (this.document.getElementById("content_left") as ISMILMediaElement);
			var prerollRight:ISMILMediaElement = (this.document.getElementById("preroll_right") as ISMILMediaElement);
			var contentRight:ISMILMediaElement = (this.document.getElementById("content_right") as ISMILMediaElement);
			
			Assert.assertEquals(0, sequenceLeft.duration);
			Assert.assertEquals(false, sequenceLeft.durationResolved);
			Assert.assertEquals(0, sequenceRight.duration);
			Assert.assertEquals(false, sequenceRight.durationResolved);
			
			Assert.assertEquals(0, prerollLeft.begin.first.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.begin.first.resolved);
			Assert.assertEquals(0, prerollLeft.end.first.resolvedOffset);
			Assert.assertEquals(false, prerollLeft.end.first.resolved);
			
			Assert.assertEquals(0, contentLeft.begin.first.resolvedOffset);
			Assert.assertEquals(false, contentLeft.begin.first.resolved);
			Assert.assertEquals(0, contentLeft.end.first.resolvedOffset);
			Assert.assertEquals(false, contentLeft.end.first.resolved);
			
			Assert.assertEquals(0, prerollRight.begin.first.resolvedOffset);
			Assert.assertEquals(true, prerollRight.begin.first.resolved);
			Assert.assertEquals(0, prerollRight.end.first.resolvedOffset);
			Assert.assertEquals(true, prerollRight.end.first.resolved);
			
			Assert.assertEquals(0, contentRight.begin.first.resolvedOffset);
			Assert.assertEquals(true, contentRight.begin.first.resolved);
			Assert.assertEquals(0, contentRight.end.first.resolvedOffset);
			Assert.assertEquals(false, contentRight.end.first.resolved);
			
			prerollLeft.dur = "10000ms";
			prerollRight.dur = "10000ms";
			
			Assert.assertEquals(10000, sequenceLeft.duration);
			Assert.assertEquals(false, sequenceLeft.durationResolved);
			Assert.assertEquals(10000, sequenceRight.duration);
			Assert.assertEquals(false, sequenceRight.durationResolved);
			
			Assert.assertEquals(0, prerollLeft.begin.first.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.begin.first.resolved);
			Assert.assertEquals(10000, prerollLeft.end.first.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.end.first.resolved);
			
			Assert.assertEquals(10000, contentLeft.begin.first.resolvedOffset);
			Assert.assertEquals(true, contentLeft.begin.first.resolved);
			Assert.assertEquals(10000, contentLeft.end.first.resolvedOffset);
			Assert.assertEquals(false, contentLeft.end.first.resolved);
			
			Assert.assertEquals(0, prerollRight.begin.first.resolvedOffset);
			Assert.assertEquals(true, prerollRight.begin.first.resolved);
			Assert.assertEquals(10000, prerollRight.end.first.resolvedOffset);
			Assert.assertEquals(true, prerollRight.end.first.resolved);
			
			Assert.assertEquals(10000, contentRight.begin.first.resolvedOffset);
			Assert.assertEquals(true, contentRight.begin.first.resolved);
			Assert.assertEquals(10000, contentRight.end.first.resolvedOffset);
			Assert.assertEquals(false, contentRight.end.first.resolved);
			
			contentLeft.dur = "10000ms";
			contentRight.dur = "10000ms";
			
			Assert.assertEquals(20000, sequenceLeft.duration);
			Assert.assertEquals(true, sequenceLeft.durationResolved);
			Assert.assertEquals(20000, sequenceRight.duration);
			Assert.assertEquals(true, sequenceRight.durationResolved);
			
			Assert.assertEquals(0, prerollLeft.begin.first.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.begin.first.resolved);
			Assert.assertEquals(10000, prerollLeft.end.first.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.end.first.resolved);
			
			Assert.assertEquals(10000, contentLeft.begin.first.resolvedOffset);
			Assert.assertEquals(true, contentLeft.begin.first.resolved);
			Assert.assertEquals(20000, contentLeft.end.first.resolvedOffset);
			Assert.assertEquals(true, contentLeft.end.first.resolved);
			
			Assert.assertEquals(0, prerollRight.begin.first.resolvedOffset);
			Assert.assertEquals(true, prerollRight.begin.first.resolved);
			Assert.assertEquals(10000, prerollRight.end.first.resolvedOffset);
			Assert.assertEquals(true, prerollRight.end.first.resolved);
			
			Assert.assertEquals(10000, contentRight.begin.first.resolvedOffset);
			Assert.assertEquals(true, contentRight.begin.first.resolved);
			Assert.assertEquals(20000, contentRight.end.first.resolvedOffset);
			Assert.assertEquals(true, contentRight.end.first.resolved);
		}
		
		[Test(description="Tests resolving a flat-packed sequence of assets, i.e. all the times are defined in the SMIL")]
		public function resolvesFlatSequence():void
		{
			var preroll:ISMILMediaElement = (this._seqDocument.getElementById("preroll") as ISMILMediaElement);
			
			Assert.assertNotNull(preroll)
				
			var prerollTime:Time = (preroll.begin.item(0) as Time);
			var prerollEnd:Time = (preroll.end.item(0) as Time);
			
			Assert.assertNotNull(prerollTime);
			Assert.assertNotNull(prerollEnd);
			
			prerollTime.resolve();
			prerollEnd.resolve();
			
			var content:ISMILMediaElement = (this._seqDocument.getElementById("content") as ISMILMediaElement);
			
			Assert.assertNotNull(content)
			
			var contentTime:Time = (content.begin.item(0) as Time);
			var contentEnd:Time = (content.end.item(0) as Time);
			
			Assert.assertNotNull(contentTime);
			Assert.assertNotNull(contentEnd);
			
			contentTime.resolve(true);
			contentEnd.resolve(true);
			
			Assert.assertEquals(70000, this._seqDocument.duration);
			
			Assert.assertEquals(10000, contentTime.resolvedOffset);
			Assert.assertEquals(70000, contentEnd.resolvedOffset);
		}
		
		[Test(description="Tests resolving a flat-packed set of parallel assets, i.e. all the times are defined in the SMIL")]
		public function resolvesFlatParallel():void
		{
			var parent:IElementParallelTimeContainer = this._parDocument.getElementById("holder") as IElementParallelTimeContainer;
			
			Assert.assertNotNull(parent);
			
			var parentBegin:Time = (parent.begin.item(0) as Time);
			var parentEnd:Time = (parent.end.item(0) as Time);
			
			parentBegin.resolve();
			
			var preroll:ISMILMediaElement = (this._parDocument.getElementById("preroll") as ISMILMediaElement);
			
			Assert.assertNotNull(preroll)
			
			var prerollTime:Time = (preroll.begin.item(0) as Time);
			var prerollEnd:Time = (preroll.end.item(0) as Time);
			
			Assert.assertNotNull(prerollTime);
			Assert.assertNotNull(prerollEnd);
			
			prerollTime.resolve();
			prerollEnd.resolve();
			
			var content:ISMILMediaElement = (this._parDocument.getElementById("content") as ISMILMediaElement);
			
			Assert.assertNotNull(content)
			
			var contentTime:Time = (content.begin.item(0) as Time);
			var contentEnd:Time = (content.end.item(0) as Time);
			
			Assert.assertNotNull(contentTime);
			Assert.assertNotNull(contentEnd);
			
			contentTime.resolve();
			contentEnd.resolve();
			
			Assert.assertEquals(10000, prerollEnd.resolvedOffset);
			Assert.assertEquals(60000, contentEnd.resolvedOffset);
			
			//parentEnd.resolve();
			//Assert.assertEquals(60, parentEnd.resolvedOffset);
		}
		
		[Test(description="Tests a document and parent element having timeChildren")]
		public function hasTimeChildren():void
		{
			var documentChildren:INodeList = this._seqDocument.timeChildren;
			
			// Fixtures.TIMED_SMIL_XML has 1 body, 1 seq, 2 video (4 children)
			Assert.assertEquals(4, documentChildren.length);
			
			var seq:IElementSequentialTimeContainer = (this._seqDocument.getElementById("holder") as IElementSequentialTimeContainer);
			
			Assert.assertNotNull(seq);
			
			var seqChildren:INodeList = seq.timeChildren;
			
			// Seq in Fixtures.TIMED_SMIL_XML has 2 video (2 children)
			Assert.assertEquals(2, seqChildren.length);
		}
	}
}