package org.smilkit.w3c.dom.smil
{
	public interface ISMILMediaElement extends IElementTime, ISMILElement
	{
		function get abstractAttr():String;
		function set abstractAttr(abstractAttr:String):void;
		
		function get alt():String;
		function set alt(alt:String):void;
		
		function get author():String;
		function set author(author:String):void;
		
		function get clipBegin():String;
		function set clipBegin(clipBegin:String):void;
		
		function get clipEnd():String;
		function set clipEnd(clipEnd:String):void;
		
		function get copyright():String;
		function set copyright(copyright:String):void;
		
		function get longdesc():String;
		function set longdesc(longdesc:String):void;
		
		function get port():String;
		function set port(port:String):void;
		
		function get readIndex():String;
		function set readIndex(readIndex:String):void;
		
		function get rtpFormat():String;
		function set rtpFormat(rtpFormat:String):void;
		
		function get src():String;
		function set src(src:String):void;
		
		function get stripRepeat():String;
		function set stripRepeat(stripRepeat:String):void;
		
		function get title():String;
		function set title(title:String):void;
		
		function get transport():String;
		function set transport(transport:String):void;
		
		function get type():String;
		function set type(type:String):void;
		
		function get params():Object;
		function getParam(name:String):String;
		function setParam(name:String, value:String):void;
	}
}