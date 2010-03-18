package org.smilkit.w3c.dom.views
{
	/**
	 * The <code>DocumentView</code> interface is implemented by <code>Document</code>
	 * objects in DOM implementations supporting DOM Views. It provides an attribute
	 * to retrieve the default view of a document.
	 * 
	 * @see Document Object Model (DOM) Level 2 Views Specification (http://www.w3.org/TR/2000/REC-DOM-Level-2-Views-20001113)
	 * @since DOM Level 2
	 */
	public interface IDocumentView
	{
		/**
		 * The default <code>AbstractView</code> for this <code>Document</code>, 
     	 * or <code>null</code> if none available.
		 */
		function get defaultView():IAbstractView;
	}
}