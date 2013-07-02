package com.wehaverhythm.gui
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class CountDown extends EventDispatcher
	{
		public static var COUNTDOWN_COMPLETE:String = "COUNTDOWN_COMPLETE";
		
		private const COUNT_FROM:int = 10;
		private const SHOW_TIME:Number = .7;
		
		private var countSprite:*;
		private var timeBox:*;
		private var timer:Timer;
		private var targY:Number;
		private var fromY:Number;
		
		public function CountDown(sprite:*)
		{
			super();
			
			countSprite = sprite;
			targY = countSprite.y + 20;
			fromY = countSprite.y = -countSprite.height;
			
			timeBox = countSprite.copy.time;
			setTime(COUNT_FROM);
			
			timer = new Timer(1000, COUNT_FROM);
			timer.addEventListener(TimerEvent.TIMER, onTimerTick);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		
		protected function onTimerComplete(e:TimerEvent):void
		{
			trace("DONE!");
			dispatchEvent(new Event(CountDown.COUNTDOWN_COMPLETE, true, true));
			reset();
		}
		
		protected function onTimerTick(e:TimerEvent):void
		{
			setTime(COUNT_FROM-timer.currentCount);
		}
		
		public function start():void
		{
			timer.reset();
			setTime(COUNT_FROM);
			timer.start();
			
			TweenMax.to(countSprite, SHOW_TIME, {delay:.5, y:targY, overwrite:2, ease:Back.easeOut});
		}
		
		public function get running():Boolean
		{
			return timer.running;
		}
		
		public function reset():void
		{
			timer.stop();
			TweenMax.to(countSprite, SHOW_TIME, {y:fromY, overwrite:2, ease:Back.easeIn});
		}
		
		private function setTime(t:int):void
		{
			var tStr:String = t < 10 ? "0" + String(t) : String(t);
			trace(tStr);
			countSprite.copy.time.txtTime.text = tStr;
		}
		
	}
}