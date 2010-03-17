package org.smilkit.w3c.dom.smil
{
	public interface IElementTest
	{
		function get systemBitrate():int;
		function set systemBitrate(systemBitrate:int):void;
		
		function get systemCaptions():Boolean;
		function set systemCaptions(systemCaptions:Boolean):void;
		
		function get systemLanguage():String;
		function set systemLanguage(systemLanguage:String):void;
		
		function get systemRequired():Boolean;
		function get systemScreenSize():Boolean;
		function get systemScreenDepth():Boolean;
		
		function get systemOverdubOrSubtitle():String;
		function set systemOverdubOrSubtitle(systemOverdubOrSubtitle:String):void;
		
		function get systemAudioDesc():Boolean;
		function set systemAudioDesc(systemAudioDesc:Boolean):void;
	}
}