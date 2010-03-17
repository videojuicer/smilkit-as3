package org.smilkit.w3c.dom
{
	public interface ICharacterData extends INode
	{
		function get data():String;
		function set data(data:String):void;
		function get length():int;
		
		function substringData(offset:int, count:int):String;
		function appendData(arg:String):void;
		function insertData(offset:int, arg:String):void;
		function deleteData(offset:int, count:int, arg:String):void;
	}
}