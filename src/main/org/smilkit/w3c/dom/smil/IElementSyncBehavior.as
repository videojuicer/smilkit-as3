package org.smilkit.w3c.dom.smil
{
	public interface IElementSyncBehavior
	{
		function get syncBehavior():String;
		function get syncTolerance():Number;
		function get defaultSyncBehavior():String;
		function get defaultSyncTolerance():Number;
		function get syncMaster():Boolean;
	}
}