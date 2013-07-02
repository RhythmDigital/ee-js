package com.wehaverhythm.terry.grandprix
{	
	import flash.display.Sprite;
	
	
	public class Track extends Sprite
	{
		public var car0:Car;
		public var car1:Car;
		public var car2:Car;
		public var car3:Car;
		
		public var bridge:Sprite;
		public var lapCounter:LapCounter;
		
		public var path0:Sprite;
		public var path1:Sprite;
		public var path2:Sprite;
		public var path3:Sprite;
		public var paths:Array;
		
		public var maxSpeeds:Array = [ 5.600601603245525, 5.593306146836349, 5.591112674573811, 5.577065738981342 ];
		
		
		public function Track()
		{
			super();
			
			cacheAsBitmap = true;
			
			for (var i:int=0; i<4; ++i)
			{
				removeChild(this['car'+i]);
			}
			
			initPaths();
		}
		
		private function initPaths():void
		{
			paths = [];
			var path:Sprite;
			
			for (var p:int=0; p<4; ++p)
			{
				paths[p] = [];
				
				path = this['path'+p];
				path.visible = false;
				
				for (var i:int=0; i<path.numChildren; ++i)
				{
					var marker:Sprite = Sprite(path.getChildAt(i));
					paths[p].push(new Vector2D(marker.x, marker.y));
				}
			}
		}
		
		public function reset():void
		{
			alpha = 0;
			visible = false;
			bridge.visible = false;
			lapCounter.laps.text = '/';
		}
	}
}