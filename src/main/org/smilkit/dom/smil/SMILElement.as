package org.smilkit.dom.smil
{
	import org.smilkit.dom.Element;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	
	public class SMILElement extends Element implements ISMILElement
	{
		public function SMILElement(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		protected function get ownerSMILDocument():SMILDocument
		{
			return (this.ownerDocument as SMILDocument);
		}
	}
}