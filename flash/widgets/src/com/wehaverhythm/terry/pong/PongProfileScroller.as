package com.wehaverhythm.terry.pong
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class PongProfileScroller extends Sprite
	{
		private var rect:Rectangle;
		private var bmps:Vector.<Bitmap>; 
		private var numBitmaps:int;
		private var speed:int = 6;
		
		public function PongProfileScroller(display:*)
		{
			super();
			x = display.x;
			y = display.y;
			display.parent.addChild(this);
			display.parent.removeChild(display);
			rect = new Rectangle(0, 0, display.width, display.height);
			
			with(graphics) {
				beginFill(0xff0000, 0);
				drawRect(0, 0, rect.width, rect.height);
				endFill();
			}
			
			this.scrollRect = rect;
		}
		
		public function initWithDummyBitmaps(num:int = 100, speed:Number = 3):void
		{
			bmps = new Vector.<Bitmap>();
			this.speed = speed;
			
			var totalWidth:Number = 0;
			
			for(var i:int = 0; i < num; ++i) {
				var bmp:Bitmap = getDummyBitmap();
				bmp.x = i*bmp.width;
				
				if(bmp.x < rect.width) addChild(bmp);
				numBitmaps++;
				totalWidth+=bmp.width;
				bmps.push(bmp);
			}
			
			if(totalWidth > rect.width) {
				start();
			}
		}
		
		public function getDummyBitmap():Bitmap
		{
			var b:Bitmap = new Bitmap(new BitmapData(48,48,false,Math.random()*0xffffff));
			return b;
		}
		
		public function initWithPlayers(players:Vector.<PongUser>, speed:Number = 3):void
		{
			bmps = new Vector.<Bitmap>();
			this.speed = speed;
			
			var totalWidth:Number = 0;
			
			for(var i:int = 0; i < players.length; ++i) {
				var bmp:Bitmap = PongUser(players[i]).getUserBitmap();
				bmp.x = i*bmp.width;
				
				if(bmp.x < rect.width) addChild(bmp);
				numBitmaps++;
				totalWidth+=bmp.width;
				bmps.push(bmp);
			}
			
			if(totalWidth > rect.width) {
				start();
			}
		}
		
		private function onUpdate(e:Event):void
		{
			for(var i:int = 0; i < numBitmaps; ++i) {
				bmps[i].x -= this.speed;
				if(bmps[i].x > 0 || bmps[i].x < rect.width) {
					if(!contains(bmps[i])) addChild(bmps[i]);
				} else {
					if(contains(bmps[i])) removeChild(bmps[i]);
				}
			}
			
			var bmpZero:Bitmap = bmps[0];
			var bmpEnd:Bitmap = bmps[numBitmaps-1];
			if(bmpZero.x + bmpZero.width <= 0) {
				bmpZero.x = (bmpEnd.x + bmpEnd.width);
				bmps.push(bmps.shift());
			}
			
//			nextX = bmps[i].x + bmp.width;
		}
		
		private function start():void
		{
			addEventListener(Event.ENTER_FRAME, onUpdate);
		}
		
		public function stop():void
		{
			removeEventListener(Event.ENTER_FRAME, onUpdate);
		}
		
		public function reset():void
		{
			stop();
			
			while(bmps.length) {
				if(this.contains(bmps[0])) removeChild(bmps[0]);
				bmps.shift();
			}
			
			bmps = null;
		}
	}
}