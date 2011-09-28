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
package org.smilkit.dom.smil.time
{
	import org.smilkit.dom.smil.Time;
	import org.utilkit.constants.AlgebraicOperator;

	public class SMILTimeHelper
	{
		public static function max(a:Time, b:Time):Time
		{	
			if (!a.resolved)
			{
				return a;
			}
			
			if (!b.resolved)
			{
				return b;
			}
			
			if (a.indefinite)
			{
				return a;
			}
			
			if (b.indefinite)
			{
				return b;
			}
			
			if (a.isGreaterThan(b))
			{
				return a;
			}
			
			return b;             
		}
		
		public static function min(a:Time, b:Time):Time
		{
			if (!b.resolved)
			{
				return a;
			}
			
			if (!a.resolved)
			{
				return b;
			}
			
			if (b.indefinite)
			{
				return a;
			}
			
			if (a.indefinite)
			{
				return b;
			}
			
			if (a.isGreaterThan(b))
			{
				return b;
			}
			
			return a;
		}
		
		public static function add(a:Time, b:Time):Time
		{
			return sum(a, AlgebraicOperator.ARITHMETIC_ADD, b);
		}
		
		public static function multiply(a:Time, b:Time):Time
		{
			return sum(a, AlgebraicOperator.ARITHMETIC_MULTIPLY, b);
		}
		
		public static function subtract(a:Time, b:Time):Time
		{
			return sum(a, AlgebraicOperator.ARITHMETIC_MINUS, b);
		}
		
		public static function sum(a:Time, operator:String, b:Time):Time
		{
			if (!a.resolved || !b.resolved)
			{
				return new Time(null, false, "unresolved");
			}
			
			if ((a.indefinite || b.indefinite) && (operator != AlgebraicOperator.ARITHMETIC_MULTIPLY || (a.resolvedOffset != 0 && b.resolvedOffset != 0)))
			{
				return new Time(null, false, "indefinite");
			}
			
			var offset:Number = NaN;
			
			// use the implicitSyncbaseOffset to sum two time objects together, as the resolvedOffset
			// can change dynamically and wont provide an accurate result.
			
			switch (operator)
			{
				case AlgebraicOperator.ARITHMETIC_ADD:
					offset = (a.implicitSyncbaseOffset + b.implicitSyncbaseOffset);
					break;
				case AlgebraicOperator.ARITHMETIC_MULTIPLY:
					offset = (a.implicitSyncbaseOffset * b.implicitSyncbaseOffset);
					break;
				case AlgebraicOperator.ARITHMETIC_MINUS:
					offset = (a.implicitSyncbaseOffset - b.implicitSyncbaseOffset);
					break;
			}
			
			return new Time(a.element, false, (offset * 1000) + "ms");
		}
	}
}