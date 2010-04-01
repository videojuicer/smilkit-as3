package org.smilkit.dom
{
	import org.smilkit.w3c.dom.IDocumentType;
	
	/**
	 * The document class represents an XML document via the W3C DOM Level 2 standard.
	 * The document provides factory methods for the creation of child objects that link
	 * to the document they were created on, this is the only method for child creation
	 * as objects must always exist on a <code>IDocument</code>.
	 * 
	 * @see org.smilkit.dom.CoreDocument
	 * @see org.smilkit.w3c.dom.IDocument
	 */ 
	public class Document extends CoreDocument
	{
		public function Document(documentType:IDocumentType)
		{
			super(documentType);
		}
	}
}