package com.wehaverhythm.terry.voter.results
{
	public class ResultsPollBasic extends ResultsDisplay
	{
		public function ResultsPollBasic()
		{
			super();
		}
		
		override public function init(results:Results):void
		{
			trace("Show results for poll");
		}
	}
}