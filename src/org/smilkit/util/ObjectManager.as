package org.smilkit.utils
{
	import flash.utils.ByteArray;

	public class ObjectManager
	{
		public static function clone(source:Object):Object
		{
			var buffer:ByteArray = new ByteArray();
			buffer.writeObject(source);
			buffer.position = 0;
			
			var clone:Object = buffer.readObject();
			
			return clone;
		}
	}
}