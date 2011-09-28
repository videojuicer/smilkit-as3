/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
package org.smilkit.dom.smil.expressions
{
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.parsers.SMILTimeParser;
	import org.utilkit.expressions.ExpressionEngine;

	public class SMILTimeExpressionParser extends ExpressionEngine
	{
		protected var _relatedContainer:ElementTestContainer;
		
		public function SMILTimeExpressionParser(relatedContainer:ElementTestContainer)
		{
			super();
			
			this._relatedContainer = relatedContainer;
		}
		
		public function get relatedContainer():ElementTestContainer
		{
			return this._relatedContainer;
		}
		
		public override function calculateValue(value:Object):Object
		{
			var durationParser:SMILTimeParser = new SMILTimeParser(null);
			
			if (value is String && durationParser.identifies(value.toString()))
			{
				durationParser.parse(value.toString());
				
				return (durationParser.milliseconds / 1000);
			}
			
			return super.calculateValue(value);
		}
	}
}