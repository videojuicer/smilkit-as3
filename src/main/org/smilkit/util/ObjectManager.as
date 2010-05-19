package org.smilkit.util
{
	import flash.utils.ByteArray;

	/**
	 * ObjectManager provides a static helper that can be used to clone an <code>Object</code>.
	 */ 
	public class ObjectManager
	{
		/**
		 * Clone's an Actionscript 3.0 Object using a ByteArray as a buffer. 
		 * 
		 * @param source Object to clone.
		 * 
		 * @return The cloned Object.
		 */
		public static function clone(source:Object):*
		{
			var buffer:ByteArray = new ByteArray();
			buffer.writeObject(source);
			buffer.position = 0;
			
			var clone:Object = buffer.readObject();
			
			return clone;
		}
	}
}