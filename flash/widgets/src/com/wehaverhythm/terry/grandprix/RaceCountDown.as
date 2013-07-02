package com.wehaverhythm.terry.grandprix
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	public class RaceCountDown extends Sprite
	{
		public static const START_RACE:String = 'START_RACE';		
		public var anim:MovieClip;
		
		
		public function RaceCountDown()
		{
			super();
			anim.stop();
		}
		
		public function reset():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			anim.gotoAndStop(1);
			visible = false;
		}
		
		public function start():void
		{
			visible = true;
			anim.gotoAndPlay(1);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			if (anim.currentFrame == anim.totalFrames) 
			{
				dispatchEvent(new Event(RaceCountDown.START_RACE, false));
				reset();
			}
		}
	}
}