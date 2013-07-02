package com.wehaverhythm.terry.voter
{
	public class PointTally
	{
		private var score:int = 0;
		
		public function PointTally()
		{
			this.score = 0;
		}
		
		public function add(score:int):void
		{
			this.score+=score;
		}
		
		public function get totalScore():int
		{
			return score;
		}
	}
}