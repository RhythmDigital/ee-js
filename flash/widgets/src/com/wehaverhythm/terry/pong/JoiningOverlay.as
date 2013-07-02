package com.wehaverhythm.terry.pong
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Sine;
	
	import flash.display.Sprite;
	
	import starling.display.Image;
	
	public class JoiningOverlay extends Sprite
	{
		private var overlay:PongJoinOverlay;
		private var playerQueue:Array;
		private var placeHolder:PongNewPlayer;
		private var displayTime:Number;
		private var allowJoiningDisplay:Boolean;
		
		
		public function JoiningOverlay()
		{
			displayTime = 2;
			playerQueue = [];
			overlay = new PongJoinOverlay();
			addChild(overlay);
			
			allowJoiningDisplay = true;
			
			showPlaceHolder();
		}
		
		
		public function addPlayerToShowQueue(user:PongUser):void
		{
			if(allowJoiningDisplay)
			{
				trace("playerQueue",playerQueue.length);
				playerQueue.push(user);
				
				//adjust tween speed based on queue length

				if(playerQueue.length>10){
					displayTime = .25;
				}else if(playerQueue.length>5){
					displayTime = .5;	
				}else if(playerQueue.length>2){
					displayTime = 1;
				}else if(playerQueue.length<2){
					displayTime = 2;
				}
				
				
				if(playerQueue.length==1)showPlayer(playerQueue[0]);
				
				if(placeHolder && placeHolder.alpha>0) TweenMax.to(placeHolder,displayTime*.125, {alpha:0});
			}
			
						
		}
		
		public function stopShowingJoiners():void
		{
			allowJoiningDisplay = false;
		}
		
		private function playSound():void
		{
			PongSFX.play("NEW_PLAYER");

		}
		
		private function showPlayer(player:PongUser):void
		{

			var xBez:Number;
			var yBez:Number = 530;
			
			if(player.team==1)
				xBez = 768;
			else
				xBez = 256;
			
			var playerDisplay:PongNewPlayer = new PongNewPlayer();
			playerDisplay.twitterNameTF.text = "@"+player.name.toUpperCase();
			playerDisplay.teamNameTF.text = String("JOINED TEAM "+(player.team+1));
			playerDisplay.x = 512;
			playerDisplay.y = 570;
			
			addChild(playerDisplay);
			
			var gridX:int = player.profileImg.x;
			var gridY:int = player.profileImg.y;
			
			player.profileImg.x = 512-(player.profileImg.width*.5);
			player.profileImg.y = 570;
			player.profileImg.alpha=1;
			
			TweenMax.from(player.profileImg,displayTime,{y:800, ease:Expo.easeOut});		
			
			TweenMax.from(playerDisplay,displayTime*.125,{delay:displayTime/4,alpha:0, ease:Sine.easeInOut});	
						
			TweenMax.to(player.profileImg,displayTime/2,{delay:displayTime,bezierThrough:[{x:xBez, y:yBez}, {x:gridX, y:gridY}], ease:Sine.easeInOut});	
			
			TweenMax.to(playerDisplay,displayTime/4,{delay:displayTime,alpha:0, ease:Sine.easeInOut, onComplete:deleteTextHarness, onCompleteParams:[playerDisplay, player]});	
			
			//play sound
			TweenMax.delayedCall(displayTime*.33,playSound);

		}
		
		private function deleteTextHarness(pDis:PongNewPlayer, player:PongUser):void
		{
			//remove from queue
			playerQueue.splice(playerQueue.indexOf(player), 1);		
			
			removeChild(pDis);
			pDis = null;
			
			//next one
			if(playerQueue.length>0 && allowJoiningDisplay) 
				showPlayer(playerQueue[0]);
			else
				showPlaceHolder();

		}
		
		private function showPlaceHolder():void
		{
			if(!placeHolder) {
				placeHolder = new PongNewPlayer();
				placeHolder.x = 512;
				placeHolder.y = 540;
				
				placeHolder.twitterNameTF.text = "JOIN NOW:";
				placeHolder.teamNameTF.text = "PLAYNOW.iO";

				
				addChild(placeHolder);
			}
			
			TweenMax.to(placeHolder, displayTime/4, {alpha:1, startAt:{alpha:0}});
			
			
		}
	}
}