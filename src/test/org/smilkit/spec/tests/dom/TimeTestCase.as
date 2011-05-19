package org.smilkit.spec.tests.dom
{
	import flexunit.framework.Assert;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.smil.ElementParallelTimeContainer;
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
		
		[Before]
		public function setUp():void
		{
			SMILKit.defaults();
			
			//this._viewport = new Viewport();
			//this._viewport.location = "data:text/plain;charset=utf-8,"+Fixtures.BASIC_UNRESOLVED_SMIL_XML;
			
			var parser:BostonDOMParser = new BostonDOMParser();

			this._unresolvedDocument = (parser.parse(Fixtures.BASIC_UNRESOLVED_SMIL_XML) as ISMILDocument);
			
			parser = new BostonDOMParser();
			
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
			
			Assert.assertEquals(60, container.currentEndInterval.resolvedOffset);
			Assert.assertEquals(30, video1.currentEndInterval.resolvedOffset);
			Assert.assertEquals(60, video2.currentEndInterval.resolvedOffset);
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
			
			Assert.assertEquals(10, video1.currentEndInterval.resolvedOffset);
			Assert.assertEquals(70, video2.currentEndInterval.resolvedOffset);
			Assert.assertEquals(80, video3.currentEndInterval.resolvedOffset);
			Assert.assertEquals(80, container.currentEndInterval.resolvedOffset);
			
			video1.setAttribute("dur", null);

			Assert.assertEquals(Time.INDEFINITE, video1.currentEndInterval.resolvedOffset);
			Assert.assertTrue(video1.end.first.resolved);
		}
		
		[Test(description="Child sets the duration in a par. The parent should have the greatest duration selected from the children == 35s")]
		public function parentParCalculatesDurationFromChildren():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.RESOLVED_VIDEOS_IN_A_PAR_SMIL_XML) as SMILDocument);
		
			var container:ElementTimeContainer = (document.getElementsByTagName("par").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			Assert.assertEquals(30, video1.currentEndInterval.resolvedOffset);
			Assert.assertEquals(35, video2.currentEndInterval.resolvedOffset);
			Assert.assertEquals(35, container.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Parent sets the duration in a seq. The first child video should be 0=>30s, the second should be cropped and go from 30s=>40s")]
		public function parentSeqSetsDurationForChildrenCroppingLast():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.PARENT_SEQ_SETS_DURATION_SMIL_XML) as SMILDocument);
		
			var container:ElementTimeContainer = (document.getElementsByTagName("seq").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			Assert.assertEquals(30, video1.currentEndInterval.resolvedOffset);
			Assert.assertEquals(40, container.currentEndInterval.resolvedOffset);
			Assert.assertEquals(40, video2.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Parent sets the duration in a par. The first child video should be 0=>30s, the second should be cropped and go from 0=>40s")]
		public function parentParSetsDurationForChildrenCroppingLast():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.PARENT_PAR_SETS_DURATION_SMIL_XML) as SMILDocument);
		
			var container:ElementTimeContainer = (document.getElementsByTagName("par").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			Assert.assertEquals(30, video1.currentEndInterval.resolvedOffset);
			Assert.assertEquals(40, video2.currentEndInterval.resolvedOffset);
			Assert.assertEquals(40, container.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Parent sets the duration on a block and crops the last video")]
		public function parentCropsLastChild():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.PARENT_CROPS_LAST_CHILD_SMIL_XML) as SMILDocument);
			
			var container:ElementTimeContainer = (document.getElementsByTagName("par").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			Assert.assertEquals(00, container.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(40, container.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(30, video1.currentEndInterval.resolvedOffset);
			Assert.assertEquals(40, video2.currentEndInterval.resolvedOffset);
			
			var secondContainer:ElementTimeContainer = (document.getElementsByTagName("par").item(1) as ElementTimeContainer);
			var video3:SMILMediaElement = (document.getElementById("video_3") as SMILMediaElement);
			var video4:SMILMediaElement = (document.getElementById("video_4") as SMILMediaElement);
			
			Assert.assertEquals(40, secondContainer.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(80, secondContainer.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(80, video4.currentEndInterval.resolvedOffset);
			Assert.assertEquals(70, video3.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Unresolved child sets the duration in a seq. The second child is unresolved, which should cause the parent to have an unresolved duration.")]
		public function parentSeqStaysUnresolved():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.UNRESOLVED_CHILD_SETS_DUR_IN_SEQ_SMIL_XML) as SMILDocument);
		
			var container:ElementTimeContainer = (document.getElementsByTagName("seq").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			Assert.assertEquals(30, video1.currentEndInterval.resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, video2.currentEndInterval.resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, container.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Unresolved child sets the duration in a par. The second child is unresolved, which should cause the parent to have an unresolved duration.")]
		public function parentParStaysUnresolved():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.UNRESOLVED_CHILD_SETS_DUR_IN_PAR_SMIL_XML) as SMILDocument);
			
			var container:ElementTimeContainer = (document.getElementsByTagName("par").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			Assert.assertEquals(30, video1.currentEndInterval.resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, video2.currentEndInterval.resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, container.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Unresolved child sets the duration in a ref. The second child is unresolved, which should cause the parent to have an unresolved duration.")]
		public function parentRefStaysUnresolved():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.UNRESOLVED_CHILD_SETS_DUR_IN_REF_SMIL_XML) as SMILDocument);
			
			var container:ElementTimeContainer = (document.getElementsByTagName("ref").item(0) as ElementTimeContainer);
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			Assert.assertEquals(30, video1.currentEndInterval.resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, video2.currentEndInterval.resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, container.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Tests a document is unresolved and that the elements can resolve over time.")]
		public function unresolvedAssetsResolvedCorrectly():void
		{
			var sequenceLeft:ElementSequentialTimeContainer = (this._unresolvedDocument.getElementById("left") as ElementSequentialTimeContainer);
			var sequenceRight:ElementSequentialTimeContainer = (this._unresolvedDocument.getElementById("right") as ElementSequentialTimeContainer);
			
			var prerollLeft:SMILMediaElement = (this._unresolvedDocument.getElementById("preroll_left") as SMILMediaElement);
			var contentLeft:SMILMediaElement = (this._unresolvedDocument.getElementById("content_left") as SMILMediaElement);
			var prerollRight:SMILMediaElement = (this._unresolvedDocument.getElementById("preroll_right") as SMILMediaElement);
			var contentRight:SMILMediaElement = (this._unresolvedDocument.getElementById("content_right") as SMILMediaElement);
			
			Assert.assertEquals(Time.UNRESOLVED, sequenceLeft.duration);
			Assert.assertEquals(false, sequenceLeft.durationResolved);
			Assert.assertEquals(Time.UNRESOLVED, sequenceRight.duration);
			Assert.assertEquals(false, sequenceRight.durationResolved);
			
			Assert.assertEquals(00, prerollLeft.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.currentBeginInterval.resolved);
			Assert.assertEquals(Time.INDEFINITE, prerollLeft.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(Time.INDEFINITE, contentLeft.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, contentLeft.currentEndInterval.resolvedOffset);

			Assert.assertEquals(00, prerollRight.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, prerollRight.currentBeginInterval.resolved);
			Assert.assertEquals(Time.INDEFINITE, prerollRight.currentEndInterval.resolvedOffset);
			Assert.assertEquals(true, prerollRight.currentEndInterval.resolved);
			
			Assert.assertEquals(Time.INDEFINITE, contentRight.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, contentRight.currentBeginInterval.resolved);
			Assert.assertEquals(Time.INDEFINITE, contentRight.currentEndInterval.resolvedOffset);
			Assert.assertEquals(true, contentRight.currentEndInterval.resolved);
			
			prerollLeft.dur = "10000ms";
			prerollRight.dur = "10000ms";
			
			Assert.assertEquals(Time.UNRESOLVED, sequenceLeft.duration);
			Assert.assertEquals(false, sequenceLeft.durationResolved);
			Assert.assertEquals(Time.UNRESOLVED, sequenceRight.duration);
			Assert.assertEquals(false, sequenceRight.durationResolved);
			
			Assert.assertEquals(00, prerollLeft.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.currentBeginInterval.resolved);
			Assert.assertEquals(true, prerollLeft.currentEndInterval.resolved);
			Assert.assertEquals(10, prerollLeft.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(10, contentLeft.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, contentLeft.currentBeginInterval.resolved);
			Assert.assertEquals(Time.INDEFINITE, contentLeft.currentEndInterval.resolvedOffset);
			Assert.assertEquals(true, contentLeft.currentEndInterval.resolved);
			
			Assert.assertEquals(00, prerollRight.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, prerollRight.currentBeginInterval.resolved);
			Assert.assertEquals(10, prerollRight.currentEndInterval.resolvedOffset);
			Assert.assertEquals(true, prerollRight.currentEndInterval.resolved);
			
			Assert.assertEquals(10, contentRight.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, contentRight.currentBeginInterval.resolved);
			Assert.assertEquals(Time.INDEFINITE, contentRight.currentEndInterval.resolvedOffset);
			Assert.assertEquals(true, contentRight.currentEndInterval.resolved);
			
			contentLeft.dur = "10000ms";
			contentRight.dur = "10000ms";
			
			Assert.assertEquals(00, prerollLeft.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.currentBeginInterval.resolved);
			Assert.assertEquals(10, prerollLeft.currentEndInterval.resolvedOffset);
			Assert.assertEquals(true, prerollLeft.currentEndInterval.resolved);
			
			Assert.assertEquals(10, contentLeft.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, contentLeft.currentBeginInterval.resolved);
			Assert.assertEquals(20, contentLeft.currentEndInterval.resolvedOffset);
			Assert.assertEquals(true, contentLeft.currentEndInterval.resolved);
			
			Assert.assertEquals(00, prerollRight.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, prerollRight.currentBeginInterval.resolved);
			Assert.assertEquals(10, prerollRight.currentEndInterval.resolvedOffset);
			Assert.assertEquals(true, prerollRight.currentEndInterval.resolved);
			
			Assert.assertEquals(10, contentRight.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(true, contentRight.currentBeginInterval.resolved);
			Assert.assertEquals(20, contentRight.currentEndInterval.resolvedOffset);
			Assert.assertEquals(true, contentRight.currentEndInterval.resolved);
		}
		
		[Test(description="Tests resolving a flat-packed sequence of assets, i.e. all the times are defined in the SMIL")]
		public function resolvesFlatSequence():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			
			this._seqDocument = (parser.parse(Fixtures.BASIC_SEQ_SMIL_XML) as ISMILDocument);
			
			var preroll:SMILMediaElement = (this._seqDocument.getElementById("preroll") as SMILMediaElement);
			
			Assert.assertNotNull(preroll)
				
			var prerollTime:Time = (preroll.currentBeginInterval);
			var prerollEnd:Time = (preroll.currentEndInterval);
			
			var content:SMILMediaElement = (this._seqDocument.getElementById("content") as SMILMediaElement);
			
			Assert.assertNotNull(content)
			
			var contentTime:Time = (content.currentBeginInterval);
			var contentEnd:Time = (content.currentEndInterval);
			
			Assert.assertNotNull(contentTime);
			Assert.assertNotNull(contentEnd);
			
			Assert.assertEquals(00, prerollTime.resolvedOffset);
			Assert.assertEquals(10, prerollEnd.resolvedOffset);
			
			Assert.assertEquals(10, contentTime.resolvedOffset);
			Assert.assertEquals(70, contentEnd.resolvedOffset);
			
			var postroll:SMILMediaElement = (this._seqDocument.getElementById("postroll") as SMILMediaElement);
			
			Assert.assertNotNull(postroll)
			
			var postrollTime:Time = (postroll.currentBeginInterval);
			var posrollEnd:Time = (postroll.currentEndInterval);
			
			Assert.assertNotNull(postrollTime);
			Assert.assertNotNull(posrollEnd);

			Assert.assertEquals(70, postrollTime.resolvedOffset);
			Assert.assertEquals(80, posrollEnd.resolvedOffset);
			
			//Assert.assertEquals(80, this._seqDocument.duration);
		}

		[Test(description="Tests that resolving a flat document with a begin= on an asset is calculated correctly")]
		public function resolvesBeginTimesCorrectly():void
		{
		  var content:ISMILMediaElement = (this._beginDocument.getElementById("content") as ISMILMediaElement);
		  
		  Assert.assertNotNull(content);
		  
		  (content as ElementTimeContainer).startup();
		  
		  var begin:Time = (content as ElementTimeContainer).currentBeginInterval;
		  var end:Time = (content as ElementTimeContainer).currentEndInterval;

		  Assert.assertEquals(5, begin.resolvedOffset);
		  Assert.assertEquals(15, end.resolvedOffset);
		}

		[Test(description="Tests resolving a flat-packed set of parallel assets, i.e. all the times are defined in the SMIL")]
		public function resolvesFlatParallel():void
		{
			var parent:ElementParallelTimeContainer = this._parDocument.getElementById("holder") as ElementParallelTimeContainer;
			
			Assert.assertNotNull(parent);
			
			var parentBegin:Time = (parent.currentBeginInterval);
			var parentEnd:Time = (parent.currentEndInterval);

			var preroll:SMILMediaElement = (this._parDocument.getElementById("preroll") as SMILMediaElement);
			
			Assert.assertNotNull(preroll);
			
			var prerollTime:Time = (preroll.currentBeginInterval);
			var prerollEnd:Time = (preroll.currentEndInterval);
			
			Assert.assertNotNull(prerollTime);
			Assert.assertNotNull(prerollEnd);
			
			var content:SMILMediaElement = (this._parDocument.getElementById("content") as SMILMediaElement);
			
			Assert.assertNotNull(content)
			
			var contentTime:Time = (content.currentBeginInterval);
			var contentEnd:Time = (content.currentEndInterval);
			
			Assert.assertNotNull(contentTime);
			Assert.assertNotNull(contentEnd);
			
			Assert.assertEquals(10, prerollEnd.resolvedOffset);
			Assert.assertEquals(60, contentEnd.resolvedOffset);
			
			parent.startup();
			Assert.assertEquals(60, parentEnd.resolvedOffset);
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