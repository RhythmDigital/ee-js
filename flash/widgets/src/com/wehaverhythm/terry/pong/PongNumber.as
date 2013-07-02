package com.wehaverhythm.terry.pong
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import com.greensock.TweenMax;

	public class PongNumber extends Sprite
	{
		private var pixelSize:int;
		private var gridW:int;
		private var gridH:int;
		private var numDisplay:Sprite;
		private var pixelPositions:Array;
		private var gridPositions:Array;
		
		public function PongNumber()
		{
			numDisplay = new Sprite();
			addChild(numDisplay);
			pixelSize = 20;
			gridW = 3;
			gridH = 5;
			
			pixelPositions = [
				[1,1,1,1,0,1,1,0,1,1,0,1,1,1,1],
				[0,1,0,0,1,0,0,1,0,0,1,0,0,1,0],
				[1,1,1,0,0,1,1,1,1,1,0,0,1,1,1],
				[1,1,1,0,0,1,1,1,1,0,0,1,1,1,1],
				[1,0,0,1,0,1,1,1,1,0,0,1,0,0,1],
				[1,1,1,1,0,0,1,1,1,0,0,1,1,1,1],
				[1,1,1,1,0,0,1,1,1,1,0,1,1,1,1],
				[1,1,1,0,0,1,0,0,1,0,0,1,0,0,1],
				[1,1,1,1,0,1,1,1,1,1,0,1,1,1,1],
				[1,1,1,1,0,1,1,1,1,0,0,1,0,0,1]];
			
			
			gridPositions = [
				new Point(0,0), new Point(1*pixelSize, 0),new Point(2*pixelSize, 0),
				new Point(0,1*pixelSize), new Point(1*pixelSize, 1*pixelSize),new Point(2*pixelSize, 1*pixelSize),
				new Point(0,2*pixelSize), new Point(1*pixelSize, 2*pixelSize),new Point(2*pixelSize, 2*pixelSize),
				new Point(0,3*pixelSize), new Point(1*pixelSize, 3*pixelSize),new Point(2*pixelSize, 3*pixelSize),
				new Point(0,4*pixelSize), new Point(1*pixelSize, 4*pixelSize),new Point(2*pixelSize, 4*pixelSize)];
		
			//makeNumber(0);
		}
		
		private function makePixel(xPos:Number, yPos:Number):Sprite
		{		
			var pix:Sprite = new Sprite();
			pix.graphics.beginFill(0xFFFFFF);
			pix.graphics.lineStyle(.1,0x000000,.1);
			pix.graphics.drawRect(xPos,yPos,pixelSize,pixelSize);
			
			return pix;
		}
		
		public function makeNumber(num:int):void
		{
			trace("num",num);
		//	numDisplay.graphics.clear();
			
			while(numDisplay.numChildren>0)
			{
				numDisplay.removeChildAt(0);
			}
			
			var numArray:Array = pixelPositions[num];
			
			for (var i:int = 0; i< numArray.length; i++)
			{
				if(numArray[i]==1)
				{
					var pix:Sprite = makePixel(gridPositions[i].x, gridPositions[i].y);
					pix.alpha = 0;
					numDisplay.addChild(pix);
					TweenMax.to(pix, .1, {alpha:1, delay:i*.05});
				}
			}
		}
	}
}