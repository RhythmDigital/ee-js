package com.wehaverhythm.terry.pong
{

	import com.wehaverhythm.starling.utils.StarlingUtils;
	import com.wehaverhythm.terry.grandprix.StarlingStage;
	import com.wehaverhythm.terry.pong.PongUser;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;


	public class TwitterImageWall
	{
		private var cols:int;
		private var rows:int;
		private var currentRowTeam0:int;
		private var currentRowTeam1:int;
		private var currentColTeam0:int;
		private var currentColTeam1:int;

		private var imgSize:int;
		private var team0Harness:Sprite;
		private var team1Harness:Sprite;
		private var imgAlpha:Number;
		
		private var defaultImage:Bitmap;
		private var defaultTexture:Texture;
		private var starlingStage:StarlingStage;

		private var team0Count:int;
		private var team1Count:int;
		
		
		public function TwitterImageWall(starlingStage:StarlingStage, defaultImage:Bitmap)
		{
			this.starlingStage = starlingStage;
			this.defaultImage = defaultImage;
			this.defaultTexture = Texture.fromBitmap(defaultImage);
			
			currentRowTeam0=0;
			currentRowTeam1=0;
			
			currentColTeam0=0;
			currentColTeam1=0;
			
			team0Count = 0;
			team1Count = 0;
			
			//imgAlpha=.3;
			imgSize = 48;
			rows = 16;
		}
		
//		public function updateUserImage(screenName:String, profilePicture:Bitmap):void
//		{
//			
//		}
		
		public function addUser(user:PongUser):void
		{
			// var userImg:starling.display.Image = StarlingUtils.imageFromBitmap(this.defaultImage);
			
			var userImg:Image = new Image(defaultTexture);
			userImg.width = userImg.height = imgSize;
			starlingStage.addChildAt(userImg, 0);
			userImg.smoothing = TextureSmoothing.NONE;
			user.setProfileImage(userImg, defaultImage);
			
			if (user.team == 0)
			{
				if (team0Count%rows == 0 && team0Count>0) 
				{
					currentRowTeam0=0;
					currentColTeam0++;
				} else if(team0Count>0){
					currentRowTeam0++;
				}
				
				team0Count++;
				userImg.x = currentColTeam0*imgSize;
				userImg.y = currentRowTeam0*imgSize;
				
			} else {
				
				if (team1Count%rows == 0) 
				{
					currentRowTeam1=0;
					currentColTeam1++;
				} 
				else currentRowTeam1++;
				
				team1Count++;
				userImg.x = 1024-(currentColTeam1*imgSize);
				userImg.y = currentRowTeam1*imgSize;		
				
			}
			
			userImg.alpha = imgAlpha;
		}			

		public function reset():void
		{
			currentRowTeam0=0;
			currentRowTeam1=0;
			
			currentColTeam0=0;
			currentColTeam1=0;
			
			team0Count = 0;
			team1Count = 0;
		}
	}
}