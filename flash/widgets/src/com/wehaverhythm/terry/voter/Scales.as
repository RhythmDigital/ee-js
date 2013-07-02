package com.wehaverhythm.terry.voter
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	import com.wehaverhythm.utils.CustomEvent;
	import com.wehaverhythm.utils.Trig;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Scales extends Sprite
	{
		// timeline
		public var bar:ScalesBar;
		public var tray0:ScalesTray;
		public var tray1:ScalesTray;
		

		// class
		private var tipNotch:Number = 3;
		private var tipRange:int = 30;
		
		
		public function Scales()
		{
			super();
		}
		
		public function reset():void
		{
			trace("Resetting scales.");
			tray0.reset();
			tray1.reset();
			bar.rotation = 0;
			positionTrays();
		}
		
		public function tip(thisVote:int, votes:Array):void
		{
			ScalesTray(this['tray'+thisVote]).addCounter(.25);

			dispatchEvent(new CustomEvent("UPDATE_VOTES_COUNT", {totalVotes:votes.length}));
			
			var rot:Number = tipNotch*votes[1] - tipNotch*votes[0];			
			TweenMax.to(bar, .7, {delay:.24, rotation:rot, ease:Sine.easeInOut, onUpdate:positionTrays, overwrite:1});
		}
		
		
		
		private function positionTrays():void
		{
			var trayPoint:Point = Trig.localToLocal(bar.marker0, this);
			tray0.x = trayPoint.x;
			tray0.y = trayPoint.y;
			
			trayPoint = Trig.localToLocal(bar.marker1, this);
			tray1.x = trayPoint.x;
			tray1.y = trayPoint.y;
		}
	}
}