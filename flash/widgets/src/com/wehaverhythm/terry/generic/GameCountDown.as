package com.wehaverhythm.terry.generic
{
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class GameCountDown extends EventDispatcher
	{
		public static var COMPLETE:String = 'COUNTDOWN_COMPLETE';
		public static var SHOW:String = 'COUNTDOWN_SHOW';
		public static var RESET:String = 'COUNTDOWN_RESET';
		public static var SET_TIME:String = 'COUNTDOWN_SET_TIME';
		
		private var countFrom:int = 4;		
		private var timer:Timer;
		private var targY:Number;
		private var fromY:Number;
		
		
		public function GameCountDown(countFrom:int)
		{
			super();
			
			this.countFrom = countFrom;
			setTime(countFrom);
			
			timer = new Timer(1000, countFrom);
			timer.addEventListener(TimerEvent.TIMER, onTimerTick);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		
		protected function onTimerComplete(e:TimerEvent):void
		{
			dispatchEvent(new Event(COMPLETE, true));
			reset();
		}
		
		protected function onTimerTick(e:TimerEvent):void
		{
			setTime(countFrom-timer.currentCount);
		}
		
		public function start():void
		{
			timer.reset();
			setTime(countFrom);
			timer.start();
			
			trace(this, 'starting countdown...');
			
			dispatchEvent(new Event(SHOW, true));
		}
		
		public function get running():Boolean
		{
			return timer.running;
		}
		
		public function reset():void
		{
			timer.stop();
			dispatchEvent(new Event(RESET, true));
		}
		
		private function setTime(t:int):void
		{
			var tStr:String = t < 10 ? "0" + String(t) : String(t);
			trace(this, tStr);
			dispatchEvent(new CustomEvent(SET_TIME, {time:tStr}, true));
		}
		
		override public function toString():String
		{
			return 'GameCountDown ::';
		}
	}
}
