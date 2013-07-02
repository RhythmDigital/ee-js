package com.wehaverhythm.terry.generic
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	public class LogoIntro extends Sprite
	{
		// timeline		
		public var logo:Sprite;
		
		// class
		public var ready:Boolean;
		private var callback:Function;
		
		
		public function LogoIntro()
		{
			super();			
			ready = false;
			
			TweenMax.to(logo, 0, {autoAlpha:0});			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			TweenMax.to(logo, .6, {delay:1, autoAlpha:1, ease:Sine.easeIn});
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}	
		
		protected function onEnterFrame(event:Event):void
		{
			// keep on top
			if (parent) parent.addChild(this);
			
			// ready to hide?
			if (ready) 
			{
				ready = false;
				TweenMax.to(logo, .4, {delay:2, autoAlpha:0, ease:Sine.easeIn, onComplete:fadeOut});
			}
		}
		
		public function hide(callback:Function):void
		{
			ready = true;
			this.callback = callback;
		}
		
		private function fadeOut():void
		{
			TweenMax.to(this, .4, {autoAlpha:0, ease:Sine.easeIn, onComplete:kill});
		}

		private function kill():void
		{
			callback();
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if (parent) parent.removeChild(this);
		}
	}
}