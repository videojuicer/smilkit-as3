package org.smilkit.w3c.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;

	public interface ISMILDocument extends IDocument, IElementSequentialTimeContainer
	{
		function createSMILElement(tagName:String):ISMILElement;
		function createMediaElement(tagName:String):ISMILMediaElement;
		function createSequentialElement(tagName:String = "seq"):IElementSequentialTimeContainer;
		function createParallelElement(tagName:String = "par"):IElementParallelTimeContainer;
		function createSwitchElement(tagName:String = "switch"):ISMILSwitchElement;
		function createReferenceElement(tagName:String = "ref"):ISMILRefElement;
		function createRegionElement(tagName:String = "region"):ISMILRegionElement;
		function createExclusiveElement(tagName:String = "excl"):IElementExclusiveTimeContainer;
	}
}