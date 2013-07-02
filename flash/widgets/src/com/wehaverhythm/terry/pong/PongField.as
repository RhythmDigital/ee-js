package com.wehaverhythm.terry.pong
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Sine;
	import com.wehaverhythm.terry.pong.Paddle;
	import com.wehaverhythm.terry.pong.PongNumber;
	import com.wehaverhythm.terry.pong.PongUser;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class PongField extends Sprite
	{

		private var scoreDisplay0:PongNumber;
		private var scoreDisplay1:PongNumber;
		private var centreLine:Sprite;
		private var paddlesTeam0:Array;
		private var paddlesTeam1:Array;
		private var team0X:int;
		private var team1X:int;
		private var maxPlayers:int;
		private var paddleW:Number;
		private var ball:Sprite;
		private var ballSpeed:Number;
		private var ballXDir:Number;
		private var ballYDir:Number;
		private var hitPaddle:Boolean;
		private var team1Score:int;
		private var team2Score:int;
		private var minPaddleDepth:int;
		private var detectHits:Boolean;
		private var allUsers:Array; 
		private var twitterWall:TwitterImageWall;
		private var paddleHeightTeam0:Number;
		private var paddleHeightTeam1:Number;
		private var team1:Array;
		private var team0:Array;


		
		public function PongField() 
		{			
			maxPlayers = 150;		
			team1Score = team2Score = 0;
			
			//ball
			ballSpeed = 5;
			ball = createBall();
			addChild(ball);
			
			//pitch stuff
			paddleW = 20;
			team0X = 70;	
			team1X = 954-paddleW;
						
			layoutField();
			
			//add players
			createUsers();
			makePaddles();
			
			//twitter images
			twitterWall = new TwitterImageWall(allUsers);
			addChildAt(twitterWall,0);
			
			kickOff();						
		}
		
		private function layoutField():void
		{
			centreLine = new Sprite();
			centreLine.graphics.beginFill(0xFFFFFF);
			centreLine.graphics.drawRect(0,0,5,768);
			centreLine.x = 512;
			addChild(centreLine);
			
			scoreDisplay0 = new PongNumber();
			addChild(scoreDisplay0);
			scoreDisplay0.makeNumber(0);
			scoreDisplay0.x = centreLine.x - (scoreDisplay0.width*2);
			scoreDisplay0.y = 20;
			
			scoreDisplay1 = new PongNumber();
			addChild(scoreDisplay1);
			scoreDisplay1.makeNumber(0);
			scoreDisplay1.x = centreLine.x + scoreDisplay1.width;
			scoreDisplay1.y = 20;
		}
		
		//temp
		private function createUsers():void
		{
			var totalPlayers:int=100;

			allUsers = []

			 team0 = [];
			 team1 = [];
			
			//make users
			for(var i:int = 0; i<totalPlayers; i++)
			{
				var randomTeam:int = 0;
				var id:int = Math.floor(Math.random()*100*(Math.random()*100));
				
				if(i%2==0) randomTeam=1;
				
				var pongUser:PongUser = new PongUser(String("player_"+i), id, randomTeam, 0);
								
				allUsers.push(pongUser);
				
				if(pongUser.team == 0){
					team0.push(pongUser)
				}else{
					team1.push(pongUser)
				}				
			}
		}
		
		private function makePaddles():void
		{
			var paddleCols:int;
			paddlesTeam0 = [];
			paddlesTeam1 = [];
				
			paddleCols = Math.ceil(team0.length/16);
			paddleHeightTeam0 = (256*paddleCols)/team0.length;
			
			paddleCols = Math.ceil(team1.length/16);
			paddleHeightTeam1 = (256*paddleCols)/team1.length;
			
			minPaddleDepth = Math.ceil(allUsers.length/32);

		
			for(var i:int = 0; i<allUsers.length; i++)
			{
				var pongUser:PongUser = allUsers[i];
				var pad:Paddle;
				
				if(pongUser.team == 0){
					pad = makePaddle(pongUser, paddleHeightTeam0);
					paddlesTeam0.push(pad);
					pad.x = team0X;
					pad.alpha = Math.max(0.2,1-(team0.length/maxPlayers));
				}else{
					pad = makePaddle(pongUser, paddleHeightTeam1);
					paddlesTeam1.push(pad);
					pad.x = team1X;
					pad.alpha = Math.max(0.2,1-(team1.length/maxPlayers));
				}
				
				pad.y = Math.random()*(256)+192;
				addChild(pad);
				
			}
		}
		
		private function makePaddle(user:PongUser, h:Number):Paddle
		{	
			var pad:Paddle = new Paddle(user);
			pad.makePaddleShape(paddleW,h);

			return pad;
		}
		
		
		private function createBall():Sprite
		{
			var b:Sprite = new Sprite();
			b.graphics.beginFill(0xFFFFFF);
			b.graphics.drawRect(-10,-10,20,20);
			b.x = 512;
			b.y = 384;
			
			return b;
		}

		
		private function kickOff():void
		{
			if(Math.random()>.5)
				ballXDir = ballYDir= 1;				
			else
				ballXDir = ballYDir=-1;	
			
			detectHits = true;

			addEventListener(Event.ADDED_TO_STAGE,doAddedToStage, false, 0, true);

		}
		
		
		private function doAddedToStage(event:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,doAddedToStage);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, doMouseMove, false, 0, true);
			
			resetGameAfterScore();	
		}	

		
		
		private function doMouseMove(event:MouseEvent):void
		{
			//testing paddle movement. needs replacing with data from PlayNow
			
			var paddleSets:Array = [paddlesTeam0, paddlesTeam1];
			
			for each (var pads:Array in paddleSets)
			{
				if(pads.length>1)
				{
					for (var i:int = 0; i< pads.length; i++)
					{
						TweenMax.to(pads[i], Math.random()*1, {y:stage.mouseY+((Math.random()*256) - (Math.random()*256)), ease:Linear.easeNone });	
					}		
				}else{
					pads[0].y = stage.mouseY -(pads[0].height/2) ;	
				}
			}
			
			
		}
		
		private function tick(e:Event):void
		{
			//ball movement and scoring
			if(!hitPaddle){
				if(ball.y<5 )ballYDir=Math.random();
				if(ball.y>763 )ballYDir=-Math.random();
								
				if(ball.x<5 ) score("team2");
				if(ball.x>1019 ) score("team1");	
			}
			
			var currentXSpeed:Number = ballSpeed*ballXDir;
			var currentYSpeed:Number = ballSpeed*ballYDir;			
		
			ball.x+=currentXSpeed;
			ball.y+=currentYSpeed;
			
			hitPaddle=false;
			
			//collision detection
			if(detectHits)
			{			
				var collisionsCount:int;
				var pads:Array;
				var hitPads:Array = [];
				
				//which team based on direction
				if(ballXDir==-1)
					pads = paddlesTeam0;
				else
					pads = paddlesTeam1;
				
				//check for ball hitting paddle
				for (var i:int = 0; i< pads.length; i++)
				{
					if(pads[i].hitTestObject(ball))
					{
						if(!hitPaddle)	hitPaddle = true;
						collisionsCount++;
						hitPads.push(pads[i]);
					}
				}
				
				
				//check if paddle has enough players in the right area
				if(collisionsCount>=minPaddleDepth) {
					//trace("collisionsCount",collisionsCount);
					
					//show hits
					for each(var pad:Paddle in hitPads)	
					{
						TweenMax.to(pad, .5, { x:String(30*ballXDir),tint:0x82F578, delay:Math.random()*.1, yoyo:true, repeat:1});				
						pad.user.scorePoint();
					}
					
					//reset ball pos
					if(ballXDir==1)
						ball.x = team1X-ball.width/2;
					else
						ball.x = team0X+(ball.width/2)+paddleW;
					
					//change direction
					ballXDir *= -1; 
					
				}else if(collisionsCount>0 && collisionsCount<minPaddleDepth){
					//not enough pads in place
					destroyPaddles(pads);
					
					//trace("paddle too thin!", "collision", collisionsCount, "minPaddleDepth", minPaddleDepth);
				}
			}

		}
		
		private function destroyPaddles(pads:Array):void
		{
			detectHits=false;
			for each (var pad:Paddle in pads)
			{
				var randX:int = (Math.random()*300)-(Math.random()*300);
				var randY:int = (Math.random()*300)-(Math.random()*300);

				TweenMax.to(pad,.75, {x:String(randX),y:String(randY),scaleX:0, scaleY:0, alpha:1,rotation:(Math.random()*180)-(Math.random()*180), tint:0xFF0000, ease:Sine.easeOut});
			}
			
		}
		
		private function score(team:String):void
		{
			//hide ball
			ball.visible = false;
			
			//pause action
			removeEventListener(Event.ENTER_FRAME, tick);
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, doMouseMove);
			
			//score
			var padsToReset:Array;
			var padsXTo:Number;
			
			if(team1Score==9 || team2Score==9)
			{
				trace("game over!");

			}else{
				
				switch(team){
					case "team1":
						team1Score ++;
						scoreDisplay0.makeNumber(team1Score);
						padsToReset = paddlesTeam1;
						padsXTo = team1X;
						break;
					case "team2":
						team2Score ++;
						scoreDisplay1.makeNumber(team2Score);
						padsToReset = paddlesTeam0;
						padsXTo = team0X;
						
						break;
				}	
				
				//reset game for next point
				TweenMax.delayedCall(1,resetPaddles,[padsToReset, padsXTo]);
				TweenMax.delayedCall(2,resetGameAfterScore);
			}
		}	
		
		
		private function resetPaddles(pads:Array, xTo:Number):void
		{
			TweenMax.staggerTo(pads, .05, {x:xTo, rotation:0, removeTint:true, alpha:Math.max(0.2,1-(pads.length/maxPlayers)), ease:Linear.easeNone, scaleX:1, scaleY:1},.001);
		}
		
		
		private function resetGameAfterScore():void
		{
			trace("resetGameAfterScore");
			ball.x = 512;
			ball.y = 384;	
		
			ball.visible = true;
			detectHits = true;
			
			addEventListener(Event.ENTER_FRAME, tick, false, 0, true);			
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, doMouseMove, false, 0, true);			
		}
		
	}
	
	
}