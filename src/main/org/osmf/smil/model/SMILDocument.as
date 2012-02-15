/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.smil.model
{
	import org.osmf.utils.OSMFStrings;

	/**
	 * Represents the root level elements of a SMIL document.
	 */	
	public class SMILDocument
	{
		/**
		 * Adds a root level element to the collection of
		 * elements.
		 */
		public function addElement(value:SMILElement):void
		{
			if (elements == null)
			{
				elements = new Vector.<SMILElement>();		
			}
			
			elements.push(value);
		}
		
		/**
		 * The number of root level elements.
		 */
		public function get numElements():int
		{
			var num:int = 0;
			
			if (elements != null)
			{
				num = elements.length;
			}
			
			return num;
		}
		
		/**
		 * Returns the SMILElement at the specified index
		 * in the collection.
		 * 
		 * @throws RangeError if the index is out of range.
		 */
		public function getElementAt(index:int):SMILElement
		{
			if (elements != null && index < elements.length)
			{
				return elements[index];
			}
			
			throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
		}
		
		public function addRegion(value:SMILRegionElement):void
		{
			if (this._regions == null)
			{
				this._regions = new Vector.<SMILRegionElement>();
			}
			
			this._regions.push(value);
		}
		
		public function get numRegions():int
		{
			var num:int = 0;
			
			if (this._regions != null)
			{
				num = this._regions.length;
			}
			
			return num;
		}
		
		public function getRegionAt(index:int):SMILRegionElement
		{
			if (this._regions != null && index < this._regions.length)
			{
				return this._regions[index];
			}
			
			throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
		}
		
		public function getRegionByName(name:String):SMILRegionElement
		{
			if (this._regions != null)
			{
				for (var i:uint = 0; i < this.numRegions; i++)
				{
					var element:SMILRegionElement = this.getRegionAt(i);
					
					if (element.id == name)
					{
						return element;
					}
				}
			}
			
			return null;
		}
		
		public function addMetadata(value:SMILMetaElement):void
		{
			if (this._metadata == null)
			{
				this._metadata = new Vector.<SMILMetaElement>();
			}
			
			this._metadata.push(value);
		}
		
		public function get numMetadata():int
		{
			var num:int = 0;
			
			if (this._metadata != null)
			{
				num = this._metadata.length;
			}
			
			return num;
		}
		
		public function getMetadataAt(index:int):SMILMetaElement
		{
			if (this._metadata != null && index < this._metadata.length)
			{
				return this._metadata[index];
			}
			
			throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
		}
		
		public function getMetadataByName(name:String):SMILMetaElement
		{
			if (this._metadata != null)
			{
				for (var i:uint = 0; i < this.numMetadata; i++)
				{
					var element:SMILMetaElement = this.getMetadataAt(i);
					
					if (element.name == name)
					{
						return element;
					}
				}
			}
			
			return null;
		}
		
		private var elements:Vector.<SMILElement>;
		private var _regions:Vector.<SMILRegionElement>;
		private var _metadata:Vector.<SMILMetaElement>;
	}
}
