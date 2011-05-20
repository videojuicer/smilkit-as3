package org.smilkit.spec.tests.dom.smil
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.smil.ElementParallelTimeContainer;
	import org.smilkit.dom.smil.ElementSequentialTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;

	public class ElementTimeContainerTestCase
	{
		protected var _document:SMILDocument;
		protected var _holder:ElementParallelTimeContainer;
		protected var _content:SMILMediaElement;
		protected var _content2:SMILMediaElement;
		
		protected var _seqDocument:SMILDocument;
		protected var _seqHolder:ElementSequentialTimeContainer;
		protected var _seqContent:SMILMediaElement;
		protected var _seqContent2:SMILMediaElement;
		
		[Before]
		public function setup():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			
			this._document = (parser.parse(Fixtures.BASIC_PAR_TIME_TEST_SMIL_XML) as SMILDocument);
			this._holder = (this._document.getElementById("holder") as ElementParallelTimeContainer);
			this._content = (this._document.getElementById("content") as SMILMediaElement);
			this._content2 = (this._document.getElementById("content_2") as SMILMediaElement);
			
			this._seqDocument = (parser.parse(Fixtures.BASIC_SEQ_TIME_TEST_SMIL_XML) as SMILDocument);
			this._seqHolder = (this._seqDocument.getElementById("holder") as ElementSequentialTimeContainer);
			this._seqContent = (this._seqDocument.getElementById("content") as SMILMediaElement);
			this._seqContent2 = (this._seqDocument.getElementById("content_2") as SMILMediaElement);
		}
		
		[Test(description="Tests that an element time container can gather its first interval")]
		public function gathersFirstIntervalSuccessfully():void
		{
			this._content.startup();
			
			Assert.assertNotNull(this._content.currentBeginInterval);
			Assert.assertNotNull(this._content.currentEndInterval);
			
			Assert.assertEquals(0, this._content.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._content.currentEndInterval.resolvedOffset);
			
			Assert.assertNotNull(this._content2.currentBeginInterval);
			Assert.assertNotNull(this._content2.currentEndInterval);
			
			Assert.assertEquals(0, this._content2.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._content2.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Tests that an element time container can gather its first interval in a seq")]
		public function gathersFirstSeqIntervalSuccessfully():void
		{
			this._seqHolder.startup();
			
			Assert.assertNotNull(this._seqContent.currentBeginInterval);
			Assert.assertNotNull(this._seqContent.currentEndInterval);
			
			Assert.assertEquals(0, this._seqContent.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._seqContent.currentEndInterval.resolvedOffset);
			
			Assert.assertNotNull(this._seqContent2.currentBeginInterval);
			Assert.assertNotNull(this._seqContent2.currentEndInterval);
			
			Assert.assertEquals(10, this._seqContent2.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(20, this._seqContent2.currentEndInterval.resolvedOffset);
			
			Assert.assertNotNull(this._seqHolder.currentBeginInterval);
			Assert.assertNotNull(this._seqHolder.currentEndInterval);
			
			Assert.assertEquals(0, this._seqHolder.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(20, this._seqHolder.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Tests that an element time container can gather the next interval in a seq")]
		public function gathersNextSeqIntervalSuccessfully():void
		{
			this._seqHolder.startup();

			Assert.assertEquals(0, this._seqContent.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._seqContent.currentEndInterval.resolvedOffset);

			Assert.assertEquals(10, this._seqContent2.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(20, this._seqContent2.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(0, this._seqHolder.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(20, this._seqHolder.currentEndInterval.resolvedOffset);
			
			this._seqContent.gatherNextInterval();

			Assert.assertEquals(10, this._seqContent.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(20, this._seqContent.currentEndInterval.resolvedOffset);

			Assert.assertEquals(20, this._seqContent2.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(30, this._seqContent2.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(0, this._seqHolder.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(30, this._seqHolder.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Tests that an element time container with children can gather its first interval")]
		public function gathersFirstIntervalSuccessfullyWithChildren():void
		{
			this._holder.startup();
			
			Assert.assertNotNull(this._holder.currentBeginInterval);
			Assert.assertNotNull(this._holder.currentEndInterval);
			
			Assert.assertEquals(0, this._holder.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._holder.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(0, this._content.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._content.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(0, this._content2.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._content2.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Tests that an element time container with children can gather the next interval")]
		public function gathersNextIntervalSuccessfullyWithChildren():void
		{
			this._holder.startup();
			
			Assert.assertEquals(0, this._holder.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._holder.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(0, this._content.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._content.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(0, this._content2.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._content2.currentEndInterval.resolvedOffset);
			
			this._content.gatherNextInterval();
			
			Assert.assertEquals(10, this._content.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(20, this._content.currentEndInterval.resolvedOffset);
			
			Assert.assertEquals(0, this._content2.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._content2.currentEndInterval.resolvedOffset);

			Assert.assertEquals(0, this._holder.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(20, this._holder.currentEndInterval.resolvedOffset);
		}
		
		[Test(description="Tests that an element time container can gather its next interval")]
		public function gathersNextIntervalSuccessfully():void
		{
			this._content.startup();
			
			Assert.assertEquals(0, this._content.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(10, this._content.currentEndInterval.resolvedOffset);
			
			this._content.gatherNextInterval();
			
			Assert.assertNotNull(this._content.currentBeginInterval);
			Assert.assertNotNull(this._content.currentEndInterval);
			
			Assert.assertEquals(10, this._content.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(20, this._content.currentEndInterval.resolvedOffset);
		
			this._content.gatherNextInterval();
			
			Assert.assertNotNull(this._content.currentBeginInterval);
			Assert.assertNotNull(this._content.currentEndInterval);
			
			Assert.assertEquals(20, this._content.currentBeginInterval.resolvedOffset);
			Assert.assertEquals(30, this._content.currentEndInterval.resolvedOffset);
			
			this._content.gatherNextInterval();
			
			Assert.assertNull(this._content.currentBeginInterval);
			Assert.assertNull(this._content.currentEndInterval);
		}
		
		[Test(description="Tests the calculation of the simple duration")]
		public function calculatesSimpleDuration():void
		{
			var time:Time = this._content.computeSimpleDurationTime();
			
			Assert.assertTrue(time.resolved);
			Assert.assertEquals(10, time.resolvedOffset);
		}
		
		[Test(description="Tests the calculation of the intermediate duration")]
		public function calculatesIntermediateDurationTimeDuration():void
		{
			var time:Time = this._content.computeIntermediateDurationTime(this._content.computeSimpleDurationTime());
			
			Assert.assertTrue(time.resolved);
			Assert.assertEquals(10, time.resolvedOffset);
		}
	}
}