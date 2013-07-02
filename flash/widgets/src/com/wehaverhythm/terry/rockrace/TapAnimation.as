package com.wehaverhythm.terry.rockrace
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.greensock.easing.Ease;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quint;
	
	import flash.display.Sprite;
	
	public class TapAnimation extends Sprite
	{
		private const FROM_Y:int = 300;
		private const TIME:Number = .5;
		private var tl:TimelineMax;
		private var tapAssets:Array;
		
		public function TapAnimation()
		{
			super();
			
			tapAssets = [new Tap, new Tap, new Tap];
			
			for each(var t:Tap in tapAssets) {
				t.y = FROM_Y;
				t.alpha = 0;
				addChild(t);
			}
			
			var ease:Ease = Quad.easeOut;
			
			// init animation
			tl = new TimelineMax({onComplete:hideTaps});
			tl.insert(new TweenMax(tapAssets[0], TIME, {ease:ease, y:0, alpha:1}), 0);
			tl.insert(new TweenMax(tapAssets[1], TIME, {ease:ease, y:0, alpha:.7}), .1);
			tl.insert(new TweenMax(tapAssets[2], TIME, {ease:ease, y:0, alpha:.4}), .2);
			tl.stop();
		}
		
		private function hideTaps():void
		{
			TweenMax.allTo(tapAssets, .3, {delay:1, alpha:0, onComplete:hideThis});
		}
		
		private function hideThis():void
		{
			// reset positions
			for each(var t:Tap in tapAssets) {
				t.y = FROM_Y;
			}
			
			if(this.parent) this.parent.removeChild(this);
		}
		
		public function play(delay:Number):void
		{
			TweenMax.delayedCall(delay, startTimeline);
			trace("Tap animation is playing");
		}
		
		private function startTimeline():void
		{
			tl.gotoAndPlay(0);
		}
	}
}