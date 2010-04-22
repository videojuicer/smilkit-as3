package org.smilkit.w3c.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;

	public interface ISMILDocument extends IDocument, IElementSequentialTimeContainer
	{
		function createSMILElement(tagName:String):ISMILElement;
		function createMediaElement(tagName:String):ISMILMediaElement;
		function createSequentialElement(tagName:String = null):IElementSequentialTimeContainer;
	}
}