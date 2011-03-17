package org.smilkit.spec.tests.dom
{
	import flexunit.framework.Assert;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.smil.ElementSequentialTimeContainer;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
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
		protected var _beginDocument:ISMILDocument;
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
			
			parser = new BostonDOMParser();
			
			this._parDocument = (parser.parse(Fixtures.BASIC_PAR_SMIL_XML) as ISMILDocument);
			
			parser = new BostonDOMParser();
			
			this._beginDocument = (parser.parse(Fixtures.BEGIN_TIME_SMIL_XML) as ISMILDocument);
		}
		
		[Test(description="Child sets the duration in a seq. The parent should have duration == the total duration of the children == 60s")]
		public function parentSeqCalculatesDurationFromChildren():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.RESOLVED_VIDEOS_IN_A_SEQ_SMIL_XML) as SMILDocument);
		
			var container:ElementTimeContainer = (document.getElementsByTagName("seq").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			video1.resolve();
			video2.resolve();
			container.resolve();
			
			// DA FUCK?
			//Assert.assertEquals(60000, container.end.first.resolvedOffset);
			Assert.assertEquals(30000, video1.end.first.resolvedOffset);
			Assert.assertEquals(60000, video2.end.first.resolvedOffset);
		}
		
		[Test(description="Elements can unresolved when resolved.")]
		public function elementsCanUnresolveWhenResolved():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.BASIC_SEQ_SMIL_XML) as SMILDocument);
			
			var container:ElementTimeContainer = (document.getElementsByTagName("seq").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("preroll") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("content") as SMILMediaElement);
			var video3:SMILMediaElement = (document.getElementById("postroll") as SMILMediaElement);
			
			video1.resolve();
			video2.resolve();
			video3.resolve();
			container.resolve();
			
			Assert.assertEquals(10000, video1.end.first.resolvedOffset);
			Assert.assertEquals(70000, video2.end.first.resolvedOffset);
			Assert.assertEquals(80000, video3.end.first.resolvedOffset);
			Assert.assertEquals(80000, container.end.first.resolvedOffset);
			
			video1.setAttribute("dur", null);

			video1.resolve();
			video2.resolve();
			video3.resolve();
			container.resolve();
			
			Assert.assertEquals(Time.UNRESOLVED, video1.end.first.resolvedOffset);
			Assert.assertFalse(video1.end.first.resolved);
			Assert.assertFalse(video1.resolved);
		}
		
		[Test(description="Child sets the duration in a par. The parent should have the greatest duration selected from the children == 35s")]
		public function parentParCalculatesDurationFromChildren():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.RESOLVED_VIDEOS_IN_A_PAR_SMIL_XML) as SMILDocument);
		
			var container:ElementTimeContainer = (document.getElementsByTagName("par").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			video1.resolve();
			video2.resolve();
			container.resolve();
			
			Assert.assertEquals(30000, video1.end.first.resolvedOffset);
			Assert.assertEquals(35000, video2.end.first.resolvedOffset);
			Assert.assertEquals(35000, container.end.first.resolvedOffset);
		}
		
		[Test(description="Parent sets the duration in a seq. The first child video should be 0=>30s, the second should be cropped and go from 30s=>40s")]
		public function parentSeqSetsDurationForChildrenCroppingLast():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.PARENT_SEQ_SETS_DURATION_SMIL_XML) as SMILDocument);
		
			var container:ElementTimeContainer = (document.getElementsByTagName("seq").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			video1.resolve();
			video2.resolve();
			container.resolve();
			
			Assert.assertEquals(30000, video1.end.first.resolvedOffset);
			Assert.assertEquals(40000, container.end.first.resolvedOffset);
			Assert.assertEquals(40000, video2.end.first.resolvedOffset);
		}
		
		[Test(description="Parent sets the duration in a par. The first child video should be 0=>30s, the second should be cropped and go from 0=>40s")]
		public function parentParSetsDurationForChildrenCroppingLast():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.PARENT_PAR_SETS_DURATION_SMIL_XML) as SMILDocument);
		
			var container:ElementTimeContainer = (document.getElementsByTagName("par").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			video1.resolve();
			video2.resolve();
			container.resolve();
			
			Assert.assertEquals(30000, video1.end.first.resolvedOffset);
			Assert.assertEquals(40000, video2.end.first.resolvedOffset);
			Assert.assertEquals(40000, container.end.first.resolvedOffset);
		}
		
		[Test(description="Parent sets the duration on a block and crops the last video")]
		public function parentCropsLastChild():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.PARENT_CROPS_LAST_CHILD_SMIL_XML) as SMILDocument);
			
			var container:ElementTimeContainer = (document.getElementsByTagName("par").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			video1.resolve();
			video2.resolve();
			container.resolve();
			
			Assert.assertEquals(00000, container.begin.first.resolvedOffset);
			Assert.assertEquals(30000, video1.end.first.resolvedOffset);
			Assert.assertEquals(40000, video2.end.first.resolvedOffset);
			Assert.assertEquals(40000, container.end.first.resolvedOffset);
			
			var secondContainer:ElementTimeContainer = (document.getElementsByTagName("par").item(1) as ElementTimeContainer);
			var video3:SMILMediaElement = (document.getElementById("video_3") as SMILMediaElement);
			var video4:SMILMediaElement = (document.getElementById("video_4") as SMILMediaElement);
			
			video3.resolve();
			video4.resolve();
			secondContainer.resolve();
			
			Assert.assertEquals(40000, secondContainer.begin.first.resolvedOffset);
			Assert.assertEquals(70000, video3.end.first.resolvedOffset);
			Assert.assertEquals(80000, video4.end.first.resolvedOffset);
			Assert.assertEquals(80000, secondContainer.end.first.resolvedOffset);
		}
		
		[Test(description="Unresolved child sets the duration in a seq. The second child is unresolved, which should cause the parent to have an unresolved duration.")]
		public function parentSeqStaysUnresolved():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.UNRESOLVED_CHILD_SETS_DUR_IN_SEQ_SMIL_XML) as SMILDocument);
		
			var container:ElementTimeContainer = (document.getElementsByTagName("seq").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			video1.resolve();
			video2.resolve();
			container.resolve();
			
			Assert.assertEquals(30000, video1.end.first.resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, video2.end.first.resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, container.end.first.resolvedOffset);
		}
		
		[Test(description="Unresolved child sets the duration in a par. The second child is unresolved, which should cause the parent to have an unresolved duration.")]
		public function parentParStaysUnresolved():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.UNRESOLVED_CHILD_SETS_DUR_IN_PAR_SMIL_XML) as SMILDocument);
			
			var container:ElementTimeContainer = (document.getElementsByTagName("par").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			video1.resolve();
			video2.resolve();
			container.resolve();
			
			Assert.assertEquals(30000, video1.end.first.resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, video2.end.first.resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, container.end.first.resolvedOffset);
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
			
			Assert.assertEquals(Time.UNRESOLVED, sequenceLeft.duration);
			Assert.assertEquals(false, sequenceLeft.durationResolved);
			Assert.assertEquals(Time.UNRESOLVED, sequenceRight.duration);
			Assert.assertEquals(false, sequenceRight.durationResolved);
			
			Assert.assertEquals(0, prerollLeft.begin.first.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.begin.first.resolved);
			Assert.assertEquals(Time.UNRESOLVED, prerollLeft.end.first.resolvedOffset);
			Assert.assertEquals(false, prerollLeft.end.first.resolved);
			
			Assert.assertEquals(Time.UNRESOLVED, contentLeft.begin.first.resolvedOffset);
			Assert.assertEquals(false, contentLeft.begin.first.resolved);
			Assert.assertEquals(Time.UNRESOLVED, contentLeft.end.first.resolvedOffset);
			Assert.assertEquals(false, contentLeft.end.first.resolved);
			
			Assert.assertEquals(0, prerollRight.begin.first.resolvedOffset);
			Assert.assertEquals(true, prerollRight.begin.first.resolved);
			Assert.assertEquals(0, prerollRight.end.first.resolvedOffset);
			Assert.assertEquals(true, prerollRight.end.first.resolved);
			
			Assert.assertEquals(0, contentRight.begin.first.resolvedOffset);
			Assert.assertEquals(true, contentRight.begin.first.resolved);
			Assert.assertEquals(Time.UNRESOLVED, contentRight.end.first.resolvedOffset);
			Assert.assertEquals(false, contentRight.end.first.resolved);
			
			prerollLeft.dur = "10000ms";
			prerollRight.dur = "10000ms";
			
			Assert.assertEquals(Time.UNRESOLVED, sequenceLeft.duration);
			Assert.assertEquals(false, sequenceLeft.durationResolved);
			Assert.assertEquals(Time.UNRESOLVED, sequenceRight.duration);
			Assert.assertEquals(false, sequenceRight.durationResolved);
			
			Assert.assertEquals(0, prerollLeft.begin.first.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.begin.first.resolved);
			Assert.assertEquals(10000, prerollLeft.end.first.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.end.first.resolved);
			
			Assert.assertEquals(10000, contentLeft.begin.first.resolvedOffset);
			Assert.assertEquals(true, contentLeft.begin.first.resolved);
			Assert.assertEquals(Time.UNRESOLVED, contentLeft.end.first.resolvedOffset);
			Assert.assertEquals(false, contentLeft.end.first.resolved);
			
			Assert.assertEquals(0, prerollRight.begin.first.resolvedOffset);
			Assert.assertEquals(true, prerollRight.begin.first.resolved);
			Assert.assertEquals(10000, prerollRight.end.first.resolvedOffset);
			Assert.assertEquals(true, prerollRight.end.first.resolved);
			
			Assert.assertEquals(10000, contentRight.begin.first.resolvedOffset);
			Assert.assertEquals(true, contentRight.begin.first.resolved);
			Assert.assertEquals(Time.UNRESOLVED, contentRight.end.first.resolvedOffset);
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
			
			prerollTime.resolve(true);
			prerollEnd.resolve(true);
			
			var content:ISMILMediaElement = (this._seqDocument.getElementById("content") as ISMILMediaElement);
			
			Assert.assertNotNull(content)
			
			var contentTime:Time = (content.begin.item(0) as Time);
			var contentEnd:Time = (content.end.item(0) as Time);
			
			Assert.assertNotNull(contentTime);
			Assert.assertNotNull(contentEnd);
			
			contentTime.resolve(true);
			contentEnd.resolve(true);
			
			Assert.assertEquals(00000, prerollTime.resolvedOffset);
			Assert.assertEquals(10000, prerollEnd.resolvedOffset);
			
			Assert.assertEquals(10000, contentTime.resolvedOffset);
			Assert.assertEquals(70000, contentEnd.resolvedOffset);
			
			var postroll:ISMILMediaElement = (this._seqDocument.getElementById("postroll") as ISMILMediaElement);
			
			Assert.assertNotNull(postroll)
			
			var postrollTime:Time = (postroll.begin.item(0) as Time);
			var posrollEnd:Time = (postroll.end.item(0) as Time);
			
			Assert.assertNotNull(postrollTime);
			Assert.assertNotNull(posrollEnd);
			
			postrollTime.resolve(true);
			posrollEnd.resolve(true);
			
			Assert.assertEquals(70000, postrollTime.resolvedOffset);
			Assert.assertEquals(80000, posrollEnd.resolvedOffset);
			
			(content.parentNode as ElementTimeContainer).resolve();
			
			Assert.assertEquals(80000, this._seqDocument.duration);
		}
		
		[Test(description="Tests that resolving a flat document with a begin= on an asset is calculated correctly")]
		public function resolvesBeginTimesCorrectly():void
		{
		  var content:ISMILMediaElement = (this._beginDocument.getElementById("content") as ISMILMediaElement);
		  
		  Assert.assertNotNull(content);
		  
		  var begin:Time = (content.begin.item(0) as Time);
		  var end:Time = (content.end.item(0) as Time);
		  
		  begin.resolve();
		  end.resolve();
		  
		  Assert.assertEquals(5000, begin.resolvedOffset);
		  Assert.assertEquals(15000, end.resolvedOffset);
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
			
			// Fixtures.TIMED_SMIL_XML has 1 body, 1 seq, 3 video (6 children)
			Assert.assertEquals(5, documentChildren.length);
			
			var seq:IElementSequentialTimeContainer = (this._seqDocument.getElementById("holder") as IElementSequentialTimeContainer);
			
			Assert.assertNotNull(seq);
			
			var seqChildren:INodeList = seq.timeChildren;
			
			// Seq in Fixtures.TIMED_SMIL_XML has 3 video (3 children)
			Assert.assertEquals(3, seqChildren.length);
		}
	}
}