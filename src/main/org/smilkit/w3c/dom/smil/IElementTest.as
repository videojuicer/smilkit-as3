package org.smilkit.w3c.dom.smil
{
	public interface IElementTest
	{
		function get systemBitrate():uint;
		
		
		function get systemCaptions():uint;
		
		
		function get systemLanguage():uint;
		
		
		function get systemRequired():uint;
		function get systemScreenSize():uint;
		function get systemScreenDepth():uint;
		
		function get systemOverdubOrSubtitle():uint;
		
		
		function get systemAudioDesc():uint;
		
		
		// not really sure why the Boston DOM implements this class with both boolean
		// and string properties, to clean up the class we have made every property
		// read only and returns the result of the test. If the attribute is null
		// the properties return false, so the tests should only be ran if the attribute exists.
		
		//function set systemBitrate(systemBitrate:int):void;
		//function set systemCaptions(systemCaptions:Boolean):void;
		//function set systemLanguage(systemLanguage:String):void;
		//function set systemOverdubOrSubtitle(systemOverdubOrSubtitle:String):void;
		//function set systemAudioDesc(systemAudioDesc:Boolean):void;
	}
}