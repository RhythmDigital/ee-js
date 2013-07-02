package com.wehaverhythm.terry.grandprix
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class Wheels extends Sprite
	{
		// timeline
		public var wheel0:MovieClip;
		public var wheel1:MovieClip;
		public var wheel2:MovieClip;
		public var wheel3:MovieClip;
		
		// class
		private var wheel:MovieClip;
		private var timer:Timer;
		private var delay:Number;
		
		
		public function Wheels()
		{
			super();
			
			var i:int = 0;
			
			while (i < 4) { 
				this['wheel'+i].gotoAndStop(1);
				++i;
			}
		}
		
		public function init():void
		{
			if (!timer) 
			{
				timer = new Timer(50);
				timer.addEventListener(TimerEvent.TIMER, onTimerTick);
			}
			
			timer.start();			
			delay = 10;
		}
		
		private function onTimerTick(event:TimerEvent):void
		{			
			var i:int = 0;
			
			while (i < 4) { 
				wheel = this['wheel'+i];
				wheel.currentFrame < wheel.totalFrames ? wheel.gotoAndStop(wheel.currentFrame+1) : wheel.gotoAndStop(1);
				++i;
			}
			
			timer.delay = int(Math.max(500 - delay*350, 40));
		}
		
		public function set speed(value:Number):void
		{
			this.delay = value;
			if (delay < .04) timer.stop();
			else timer.start();
		}
	}
}