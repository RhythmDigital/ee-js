package com.wehaverhythm.terry.terrytest
{
	import flash.display.Sprite;
	
	public class Bar extends Sprite
	{
		public function Bar(barWidth:int = 100, barHeight:int = 500, col:uint = 0x000000)
		{
			super();
			
			graphics.beginFill(col, 1);
			graphics.drawRect(-barWidth>>1,-barHeight,barWidth,barHeight);
			graphics.endFill();
		}
	}
}