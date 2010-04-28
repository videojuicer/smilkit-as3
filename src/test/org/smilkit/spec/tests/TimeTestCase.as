package org.smilkit.spec.tests
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.Element;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
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
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._seqDocument = (parser.parse(Fixtures.BASIC_SEQ_SMIL_XML) as ISMILDocument);
			this._parDocument = (parser.parse(Fixtures.BASIC_PAR_SMIL_XML) as ISMILDocument);
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
			
			contentTime.resolve();
			contentEnd.resolve();
			
			Assert.assertEquals(70, contentEnd.resolvedOffset);
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
			
			Assert.assertEquals(10, prerollEnd.resolvedOffset);
			Assert.assertEquals(60, contentEnd.resolvedOffset);
			
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