package com.wehaverhythm.terry.pong
{
	import com.greensock.TweenMax;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.wehaverhythm.utils.Maths;
	
	import flash.display.Bitmap;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.textures.Texture;
	

	public class PongUser
	{
		public var userID:String;
		public var score:int;
		public var team:int;
		public var profileImg:Image;
		public var name:String;
		public var paddle:Quad;
		public var rank:int;
		
		// animation
		private var speed:Number = 0.1;
		private var spring:Number = 0;
		private var velY:Number = 0;
		private var currentY:Number = 0;
		public var targetY:Number = 0;
		
		//String("player_"+i), userID, randomTeam, 0
		public var userBitmap:Bitmap;
		private var usingDefaultImage:Boolean;
		public var defaultAlpha:Number = .3;
		
		public function PongUser(nameStr:String, id:String, t:int, s:int=0)
		{
			userID = id;
			score = s;
			team = t;
			name = nameStr;			
		}
		
		public function setProfileImage(img:Image, defaultBMP:Bitmap):void
		{
			usingDefaultImage = true;
			userBitmap = defaultBMP;
			profileImg = img;
		}
		
		public function scorePoint():void
		{
			score++;			
			profileImg.alpha = 1;
			TweenMax.killDelayedCallsTo(resetAlpha);
			TweenMax.delayedCall(.5, resetAlpha);
			//TweenMax.to(profileImg, .5, {alpha:1, yoyo:true, repeat:1});
		}
		
		private function resetAlpha():void
		{
			profileImg.alpha = 0;//.3;
		}
		
		public function setPosition(val:Number):void
		{
			var posY:Number = Maths.map(val, 0, 255, 0, 768-paddle.height);
			targetY = posY;
		}
		
		public function update():void{
			
			velY = velY*spring;
			velY = velY+((targetY - currentY)*speed);
			currentY = currentY + velY;
			if(paddle) paddle.y = currentY;
		}
		
		public function updateUserImage(bmp:Bitmap):void
		{
			usingDefaultImage = false;
			profileImg.texture = Texture.fromBitmap(bmp);
			//set to invisible before animation
			profileImg.alpha=0;
			
			userBitmap = bmp;
		}
		
		public function getUserBitmap():Bitmap
		{
			return new Bitmap(userBitmap.bitmapData.clone());	
		}
		
		public function toString():String
		{
			return "PongUser :: " + name + " >> score: " + score;
		}
		
		public function destroy():void
		{
			userID = null;
			name = null;
			
			if (!usingDefaultImage) 
			{
				profileImg.texture.dispose();
				profileImg.dispose();
				// userBitmap.bitmapData.dispose();
			}
			
			userBitmap = null;
			profileImg = null;
			paddle = null;
		}
	}
}