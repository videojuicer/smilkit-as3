package org.smilkit.timing
{
	import org.smilkit.w3c.dom.smil.ISMILDocument;

	public class TimingGraph
	{
		protected var _graph:Vector.<ResolvedTimeElement>;
		protected var _document:ISMILDocument;
		
		public function TimingGraph(document:ISMILDocument)
		{
			this._graph = new Vector.<ResolvedTimeElement>();
			this._document = document;
			
			// add listeners to document
			
		}
		
		public function get graph():Vector.<ResolvedTimeElement>
		{
			return this._graph;
		}
		
		public function get document():ISMILDocument
		{
			return this._document;
		}
	}
}