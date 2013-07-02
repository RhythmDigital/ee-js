package com.wehaverhythm.terry.grandprix
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	
	public class GrandPrixWaiting extends Sprite
	{
		public var grid0:Sprite;
		public var grid1:Sprite;
		public var grid2:Sprite;
		public var grid3:Sprite;
		public var join:Sprite;
		
		public var race:Sprite;
		public var startsIn:Sprite;
		public var seconds:TextField;
		
		
		public function GrandPrixWaiting()
		{
			super();
		}
		
		public function init():void
		{
			alpha = 0;
			visible = false;
			
			seconds.blendMode = BlendMode.ADD;
			
			join.alpha = grid0.alpha = grid1.alpha = grid2.alpha = grid3.alpha = race.alpha = startsIn.alpha = seconds.alpha = 0;
		}
		
		public function show():void
		{
			TweenMax.to(this, .1, {autoAlpha:1, ease:Sine.easeIn});
			
			TweenMax.to(join, .5, {alpha:.63, ease:Sine.easeIn});
			
			TweenMax.to(grid0, .4, {delay:.2, alpha:1, ease:Sine.easeIn});
			TweenMax.to(grid1, .4, {delay:.4, alpha:1, ease:Sine.easeIn});
			TweenMax.to(grid2, .4, {delay:.6, alpha:1, ease:Sine.easeIn});
			TweenMax.to(grid3, .4, {delay:.8, alpha:1, ease:Sine.easeIn});
		}
		
		public function showCountdown():void
		{
			TweenMax.to(race, .3, {alpha:.12, ease:Sine.easeIn});
			TweenMax.to(startsIn, .3, {delay:.15, alpha:.12, ease:Sine.easeIn});
			TweenMax.to(seconds, .3, {delay:.24, alpha:.12, ease:Sine.easeIn});
		}
		
		public function reset():void
		{
			TweenMax.to(this, .2, {autoAlpha:0, ease:Sine.easeIn, onComplete:init});
		}
	}
}