package com.wehaverhythm.terry.voter
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.Sprite;
	
	
	public class ScalesTray extends Sprite
	{
		// timeline
		public var tray:Sprite;
		
		// class
		private var colours:Array = [0xCCCCCC];
		
		
		public function ScalesTray()
		{
			super();
		}
		
		public function reset():void
		{
			// remove old counters
			for(var i:int = 0; i < numChildren; ++i) {
				var c:* = getChildAt(i);
				if(c is CounterDisplay) {
					removeChild(c);
				}
			}
		}
		
		public function addCounter(dur:Number):void
		{
			var margin:Number = tray.width - 40;
			
			var c:CounterDisplay = new CounterDisplay();
			c.x = -margin/2 + Math.random()*margin;
			c.y = -y - 40;
			addChildAt(c, 0);
			
			TweenMax.to(c, 0, {tint:colours[Math.floor(Math.random()*colours.length)]});
			TweenMax.to(c, dur, {y:tray.height-(c.height*.7), ease:Quad.easeIn});
		}
	}
}