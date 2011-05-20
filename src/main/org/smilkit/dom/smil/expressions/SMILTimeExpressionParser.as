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