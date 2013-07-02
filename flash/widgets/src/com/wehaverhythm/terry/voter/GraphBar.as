package com.wehaverhythm.terry.voter
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	
	import flash.display.Sprite;
	
	
	public class GraphBar extends Sprite
	{
		// timeline
		public var bar:Sprite;
		
		// class
		private var minGirth:Number;
		private var maxGirth:Number;
		
		
		public function GraphBar()
		{
			super();
			bar.scaleX = 0;
		}
		
		
		
		public function showGirth(barWidth:Number):void
		{
			TweenMax.to(bar, .5+Math.random(), {delay:Math.random()*.3, width:Math.max(minGirth, barWidth), ease:Sine.easeOut, overwrite:1});
		}
		
		public function set min(value:Number):void
		{
			minGirth = value;
			showGirth(0);
		}
		
		public function set max(value:Number):void
		{
			maxGirth = value;
			//showPerc(0);
		}
	}
}