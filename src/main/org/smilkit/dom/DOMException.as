package org.smilkit.dom
{
	/**
	 * DOM operations only raise exceptions in "exceptional" circumstances, i.e., 
	 * when an operation is impossible to perform (either for logical reasons, 
	 * because data is lost, or because the implementation has become unstable). 
	 * In general, DOM methods return specific error values in ordinary 
	 * processing situations, such as out-of-bound errors when using <code>NodeList</code>. 
	 * 
	 * Implementations should raise other exceptions under other circumstances. 
	 * For example, implementations should raise an implementation-dependent 
	 * exception if a <code>null</code> argument is passed. 
	 * 
	 * @see Document Object Model (DOM) Level 2 Views Specification: http://www.w3.org/TR/2000/REC-DOM-Level-2-Views-20001113
	 */
	public class DOMException extends Error
	{
		/**
		 * If index or size is negative, or greater than the allowed value
		 */
		public static var INDEX_SIZE_ERR:int = 1;
		
		/**
		 * If the specified range of text does not fit into a DOMString
		 */
		public static var DOMSTRING_SIZE_ERR:int = 2;
		
		/**
		 * If any node is inserted somewhere it doesn't belong
		 */
		public static var HIERARCHY_REQUEST_ERR:int = 3;
		
		/**
		 * If a node is used in a different document than the one that created it 
		 * (that doesn't support it)
		 */
		public static var WRONG_DOCUMENT_ERR:int = 4;
		
		/**
		 * If an invalid or illegal character is specified, such as in a name. See 
		 * production 2 in the XML specification for the definition of a legal 
		 * character, and production 5 for the definition of a legal name 
		 * character.
		 */
		public static var INVALID_CHARACTER_ERR:int = 5;
		
		/**
		 * If data is specified for a node which does not support data
		 */
		public static var NO_DATA_ALLOWED_ERR:int = 6;
		
		/**
		 * If an attempt is made to modify an object where modifications are not 
		 * allowed
		 */
		public static var NO_MODIFICATION_ALLOWED_ERR:int = 7;
		
		/**
		 * If an attempt is made to reference a node in a context where it does 
		 * not exist
		 */
		public static var NOT_FOUND_ERR:int = 8;
		
		/**
		 * If the implementation does not support the requested type of object or 
		 * operation.
		 */
		public static var NOT_SUPPORTED_ERR:int = 9;
		
		/**
		 * If an attempt is made to add an attribute that is already in use 
		 * elsewhere
		 */
		public static var INUSE_ATTRIBUTE_ERROR:int = 10;
		
		/**
		 * If an attempt is made to use an object that is not, or is no longer, 
		 * usable.
		 * @since DOM Level 2
		 */
		public static var INVALID_STATE_ERR:int = 11;
		
		/**
		 * If an invalid or illegal string is specified.
		 * @since DOM Level 2
		 */
		public static var SYNTAX_ERR:int = 12;
		
		/**
		 * If an attempt is made to modify the type of the underlying object.
		 * @since DOM Level 2
		 */
		public static var INVALID_MODIFICATION_ERR:int = 13;
		
		/**
		 * If an attempt is made to create or change an object in a way which is 
		 * incorrect with regard to namespaces.
		 * @since DOM Level 2
		 */
		public static var NAMESPACE_ERR:int = 14;
		
		/**
		 * If a parameter or an operation is not supported by the underlying 
		 * object.
		 * @since DOM Level 2
		 */
		public static var INVALID_ACCESS_ERR:int = 15;
		
		public function DOMException(type:int, message:String)
		{
			super(message, type);
		}
		
		public function get code():int {
			return this.errorID;
		}
	}
}