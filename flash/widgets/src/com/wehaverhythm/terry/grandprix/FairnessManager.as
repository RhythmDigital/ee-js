package com.wehaverhythm.terry.grandprix
{
	public class FairnessManager
	{
		private var cars:Array;
		private var targetLapTime:Number;
		
		
		public function FairnessManager(cars:Array)
		{
			this.cars = cars;
			targetLapTime = 10;
		}
		
		public function adjustSpeeds(lapTimes:Array):void
		{
			trace('\n' + this, 'adjusting speeds...\n');
			
			for (var i:int=0; i<lapTimes.length; ++i)
			{
				var timePerSpeed:Number = cars[i].maxSpeed / lapTimes[i];
				var lapDifference:Number = lapTimes[i] - targetLapTime;
				var speedDifference:Number = timePerSpeed * lapDifference;
				cars[i].maxSpeed += speedDifference;
			}
		}
		
		public function toString():String
		{
			return 'FairnessManager ::';
		}
	}
}