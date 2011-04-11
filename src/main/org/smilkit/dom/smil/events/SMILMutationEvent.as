package org.smilkit.dom.smil.events
{
	import org.smilkit.dom.events.MutationEvent;

	public class SMILMutationEvent extends MutationEvent
	{
		// DOMVariables extension on the SMIL Boston DOM
		public static var DOM_VARIABLES_MODIFIED:String = "DOMVariablesModified";
		public static var DOM_VARIABLES_INSERTED:String = "DOMVariablesInserted";
		public static var DOM_VARIABLES_REMOVED:String = "DOMVariablesRemoved";
	}
}