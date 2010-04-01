package org.smilkit.w3c.dom.views
{
	/**
	 * A base interface that all views shall derive from.
	 * 
	 * @see Document Object Model (DOM) Level 2 Views Specification: http://www.w3.org/TR/2000/REC-DOM-Level-2-Views-20001113
	 * @since DOM Level 2
	 */
	public interface IAbstractView
	{
		/**
		 * The source <code>DocumentView</code> of which this is an <code>AbstractView</code>.
		 */
		function get document():IDocumentView;
	}
}