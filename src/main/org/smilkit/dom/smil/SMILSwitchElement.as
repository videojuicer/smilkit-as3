package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.smil.ISMILSwitchElement;
	
	public class SMILSwitchElement extends SMILElement implements ISMILSwitchElement
	{
		public function SMILSwitchElement(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public function get selectedElement():IElement
		{
			return null;
		}
	}
}