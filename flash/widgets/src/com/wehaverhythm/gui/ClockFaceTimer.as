package com.wehaverhythm.gui
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.theflashblog.drawing.Wedge;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	
	/**
	 *	ClockFaceTimer
	 *
	 *	- ActionScript 3.0
	 *	- Flash 10
	 *
	 *	@author Adam Palmer
	 *	@since  09.06.2011
	 */
	
	public class ClockFaceTimer extends Sprite 
	{					
		protected var _radius:Number;
		private var color:uint;
		private var totalTime:Number;		
		private var timerTween:TweenMax;
		
		public var nextAngle:Number = 360;	
		
		public static var TIMER_COMPLETE:String = "TIMER COMPLETE";
		
		
		public function ClockFaceTimer():void
		{
			rotation = 90;
			scaleX = -1;
		}
		
		private function showProgress():void
		{
			this.graphics.clear();
			this.graphics.beginFill(color, 1);
			this.graphics.lineStyle(2,0x7A7A7A);
			Wedge.draw(this, 0, 0, _radius/2, nextAngle, 0);
			this.graphics.endFill();			
		}
		
		public function create(params:Object):void
		{
			x = params.x; 
			y = params.y;			
			color = params.color;
			_radius = params.radius;
		}
		
		public function fill():void
		{
			nextAngle = 360;
			showProgress();
			
		}
		
		public function set radius(r:Number):void
		{
			_radius = r;
			fill();
		}
		
		public function startTimer(seconds:Number, startDelay:Number=0):void
		{
			totalTime = seconds;
			timerTween = new TweenMax(this, totalTime, {delay:startDelay, nextAngle:0, onUpdate:showProgress, ease:Linear.easeNone, onComplete:onTimerComplete});
		}
		
		public function onTimerComplete():void
		{
			dispatchEvent(new Event(TimerEvent.TIMER_COMPLETE, true));
		}
		
		public function stopTimer():void
		{
			if (timerTween) TweenMax.killTweensOf(this);
		}
		
		public function resetTimer(seconds:Number, startNow:Boolean=true):void
		{
			if (timerTween) TweenMax.killTweensOf(this);
			this.graphics.clear();
			
			nextAngle = 360;
			
			startNow ? startTimer(seconds) : showProgress();
		}	
		
		/*public function get currentTime():Number
		{
		return timerTween.progress * totalTime;
		}
		
		public function get remainingTime():Number
		{
		return totalTime - currentTime;
		}*/
		
		public function get pPercent():Number
		{
			var perc:Number = Math.round((nextAngle / 360) * 100);			
			return perc;
		}
		
		public override function toString():String
		{
			return "ClockFaceTimer";
		}
	}
}