package com.wehaverhythm.terry.rockrace
{
	import com.wehaverhythm.terry.utils.TeamManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	
	public class RockTeamsElevation extends TeamManager
	{
		private var levelBMD:BitmapData;
		private var bmpScale:Number;
		private var circ:Sprite;
		private var circSmall:Sprite;
		
		public function RockTeamsElevation()
		{
			super();
			
			var vp:Rectangle =  Starling.current.viewPort;
			
			var level:LevelOutline = new LevelOutline();
			level.width = vp.width;
			bmpScale = 300 / level.width; // 300 = smaller bmp vers
			
			var mtx:Matrix = new Matrix();
			mtx.scale(bmpScale, bmpScale);
			
			levelBMD = new BitmapData(vp.width*bmpScale, vp.height*bmpScale, true, 0x00000000);
			levelBMD.draw(level, mtx);
			/*
			if(RockRace.DEBUG) 
			{
				circ = new Sprite();
				circ.graphics.beginFill(0xff0000);
				circ.graphics.drawCircle(0,0,10);
				circ.graphics.endFill();
				
				circSmall = new Sprite();
				circSmall.graphics.beginFill(0xff0000);
				circSmall.graphics.drawCircle(0,0,10);
				circSmall.graphics.endFill();
				
				Starling.current.nativeOverlay.addChild(level);
				Starling.current.nativeOverlay.addChild(new Bitmap(levelBMD));
				Starling.current.nativeOverlay.addChild(circ);
				Starling.current.nativeOverlay.addChild(circSmall);
			}*/
		}
		
		public function getLevelElevationAtX(px:Number):void
		{
		//	trace("get point at " + px);
			
			circSmall.x = px*bmpScale; 
			circ.x = px;
			
			var xScaled:Number = px*bmpScale;
			
			
			for(var i:int = 0; i < levelBMD.height; ++i) {
				//trace("pix: " + levelOutline.getPixel32(px, i));
				var pix:int = levelBMD.getPixel32(xScaled, i);
				var a:int = pix >> 24 & 0xff;
				
				if(a > 10) {
					circSmall.y = i; 
					circ.y = i/bmpScale;
					
					break;
				}
				
				//trace(pix >> 24 & 0xff);
			}
		}
	}
}