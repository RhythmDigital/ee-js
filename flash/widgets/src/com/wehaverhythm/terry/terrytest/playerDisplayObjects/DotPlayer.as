package com.wehaverhythm.terry.terrytest.playerDisplayObjects
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Sine;
	
	import flash.display.Sprite;

	public class DotPlayer extends Sprite
	{
		public var id:int;
		public var team:int;

		private var dot:Sprite;
		
		public function DotPlayer(id:int, colour:int, team:int)
		{
			this.id = id;
			this.team = team;
			drawDot(colour);
		}
		
		private function drawDot(colour:int):void
		{
			dot = new Sprite();
			dot.graphics.beginFill(colour);
			dot.graphics.drawCircle(0,0,50);
						
			addChild(dot);
		}
		
		public function pullAni():void
		{
			var pullTo:int = 10;
			if(team ==0)pullTo*=-1;
			
			TweenMax.to(dot,.1,{x:pullTo, ease:Expo.easeOut});
			TweenMax.to(dot,.1,{delay:.1, x:0, ease:Sine.easeOut});			
		}
	}
}