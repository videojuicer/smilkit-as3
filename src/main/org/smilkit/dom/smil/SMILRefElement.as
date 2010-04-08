package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.ISMILRefElement;
	
	public class SMILRefElement extends SMILMediaElement implements ISMILRefElement
	{
		public function SMILRefElement(owner:IDocument, name:String)
		{
			super(owner, name);
		}
	}
}