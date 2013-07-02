package com.wehaverhythm.terry.pong
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Sine;
	import com.wehaverhythm.terry.generic.GameBaseNative;
	import com.wehaverhythm.terry.generic.GameCountDown;
	import com.wehaverhythm.utils.ArrayUtils;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	
	public class PongGame extends GameBaseNative
	{				
		private var scoreDisplay0:PongNumber;
		private var scoreDisplay1:PongNumber;		
		private var centreLine:Sprite;
		
		private var countDownDisplay:PongNumber;
		
		private var paddlesTeam0:Array;
		private var paddlesTeam1:Array;
		private var paddleW:Number;
		private var minPaddleDepth:int;
		private var hitPaddle:Boolean;
		
		public var paddleHeightTeam0:Number;
		public var paddleHeightTeam1:Number;
		private var team1:Vector.<PongUser>;
		private var team0:Vector.<PongUser>;
		
		private var team0X:int;
		private var team1X:int;		
		public var team0Score:int;
		public var team1Score:int;
		private var maxPlayers:int;		
		
		public var ball:starling.display.Quad;
		private var ballSpeed:Number;
		private var ballSpeedInit:Number;
		private var ballXDir:Number;
		private var ballYDir:Number;		
		
		public var blabImg:Bitmap;
		
		private var detectHits:Boolean;
		public var allUsers:Vector.<PongUser>; 
		
		private var twitterWall:TwitterImageWall;
		
		private var userNamesLookup:Dictionary;
		private var userIDLookup:Array;
		private var ballMoving:Boolean;
		
		private var joinOverlay:JoiningOverlay;
		private var gameOverScreen:PongGameOverOverlay;
		private var winnerScroller:PongProfileScroller;
		private var loserScroller:PongProfileScroller;
		private var fieldScreen:Sprite;

		private var ping:Boolean;
		private var winningTeam:int;
		private var losingTeam:int;
		private var bigTexture:BigTexture;
		
		private const WIN_SCORE:int = 4;
		
		
		public function PongGame()
		{
			super();
			
			PongSFX.init();
			
			minPlayers = 1;
			countDownFrom = 5;
		}
		
		override protected function onStarlingReady(e:starling.events.Event):void
		{			
			super.onStarlingReady(e);
			trace("PongGame onStarlingReady");			
			
			maxPlayers = 150;		
			team0Score = team1Score = 0;
			
			//twitter images
			twitterWall = new TwitterImageWall(starlingStage, blabImg);
			
			//pitch stuff
			paddleW = 20;
			team0X = 70;	
			team1X = 954-paddleW;
						
			
			// game over screen
			gameOverScreen = new PongGameOverOverlay();
			winnerScroller = new PongProfileScroller(gameOverScreen.winScroller);
			loserScroller = new PongProfileScroller(gameOverScreen.loseScroller);			
			bigTexture = new BigTexture(1024, 1024);
			
			// createUsers();
			addEventListener(flash.events.Event.ENTER_FRAME, tick, false, 0, true);	
			
			
			userNamesLookup = new Dictionary(true);
			userIDLookup = new Array();
			
			
			// TEST!
			if (debug) dispatchEvent(new flash.events.Event("SMASH_IT", true));
		}
		
		
		
		// WAITING STATE
		override protected function waitForPlayers():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownWaiting);
			
			if (joinOverlay == null) joinOverlay = new JoiningOverlay();
			addChild(joinOverlay);
			
			super.waitForPlayers();	
		}

		
		private function onKeyDownWaiting(e:KeyboardEvent):void
		{
			trace('\tKEY PRESSED:', e.keyCode);
			
			if (e.keyCode == Keyboard.SPACE)
			{
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownWaiting);
				
				layoutField();
				prepGame();
				startCountdown();
				joinOverlay.stopShowingJoiners();
				
				removeChild(joinOverlay);
				joinOverlay=null;
				
				for each(var pu:PongUser in allUsers)
				{
					bigTexture.addUser(pu);
					pu.profileImg.alpha = 0;
				}
				
				// make big texture.
				bigTexture.makeTexture();
				starlingStage.addChildAt(bigTexture.image, 0);
			}
		}
		
		public function profilePictureReceived(screenName:String, profilePicture:Bitmap):void
		{
			if(userNamesLookup[screenName]) {
				
				var hasBitmap:Boolean = profilePicture != null;
				
				trace("HAS BITMAP?! " + hasBitmap);
				
				// this gets called when a user joins and reconnects.	
				trace("Got profile picture for: " + screenName + ": " + profilePicture);
				trace("lookup",userNamesLookup[screenName]);
				if(hasBitmap) userNamesLookup[screenName].updateUserImage(profilePicture);
				
				joinOverlay.addPlayerToShowQueue(userNamesLookup[screenName]);
			}
		}
		

		

		// COUNTDOWN STATE
		
		override protected function startCountdown():void
		{
			trace('startCountdown');
			
			countdown.addEventListener(GameCountDown.SET_TIME, onSetCountDown);
			super.startCountdown();
			super.startGame();
		}
		
		private function onSetCountDown(event:CustomEvent):void
		{
			countDownDisplay.visible = true;
			countDownDisplay.makeNumber(int(event.params.time));
		}
		
		override protected function onCountdownComplete(e:flash.events.Event):void
		{
			countdown.removeEventListener(GameCountDown.SET_TIME, onSetCountDown);
			TweenMax.delayedCall(2, kickOff);
		}
		
		
		
		
		// START / END GAME
		
		override public function resetGame():void
		{
			super.resetGame();
			
			allUsers = new Vector.<PongUser>();
			
			for(var u:String in userNamesLookup) {	
				userNamesLookup[u] = null;
			}
			
			for(var id:String in userIDLookup) {
				userIDLookup[id] = null;
			}
						
			team0 = new Vector.<PongUser>();
			team1 = new Vector.<PongUser>();
			
			if(bigTexture) {
				bigTexture.reset();
				
				if(bigTexture.image && starlingStage.contains(bigTexture.image)) {
					starlingStage.removeChild(bigTexture.image);
				}
			}
			
			team0Score = team1Score = 0;
			

			
			// show waitscreen?
		}
		
		override protected function startGame():void
		{			
			super.startGame();			
			trace(this, 'START GAME');
		}

		
		// IN GAME
		
		protected function onEnterFrame(event:flash.events.Event):void
		{
			// convenience function
		}
		
		private function layoutField():void
		{
			if (fieldScreen == null) 
			{
				fieldScreen = new Sprite();
				
				centreLine = new Sprite();
				centreLine.graphics.beginFill(0xFFFFFF);
				centreLine.graphics.drawRect(0,0,5,768);
				centreLine.x = 512;
				fieldScreen.addChild(centreLine);
				
				scoreDisplay0 = new PongNumber();
				scoreDisplay0.makeNumber(0);
				fieldScreen.addChild(scoreDisplay0);
				scoreDisplay0.x = centreLine.x - (scoreDisplay0.width*2);
				scoreDisplay0.y = 20;				
				
				scoreDisplay1 = new PongNumber();
				scoreDisplay1.makeNumber(0);
				fieldScreen.addChild(scoreDisplay1);
				scoreDisplay1.x = centreLine.x + scoreDisplay1.width;
				scoreDisplay1.y = 20;
				
				countDownDisplay = new PongNumber();
				countDownDisplay.makeNumber(0);
				countDownDisplay.x = 512 - countDownDisplay.width;
				countDownDisplay.y = 384 - countDownDisplay.height;
				countDownDisplay.scaleX = countDownDisplay.scaleY = 2;
				countDownDisplay.visible = false;
				fieldScreen.addChild(countDownDisplay);
			}
			
			scoreDisplay0.makeNumber(0);
			scoreDisplay1.makeNumber(0);
			
			scoreDisplay0.visible = scoreDisplay1.visible = centreLine.visible = false;
			addChild(fieldScreen);
		}
		
		//temp
		private function createUsers():void
		{
			var totalPlayers:int = 100;
			
			//make users
			for(var i:int = 0; i<totalPlayers; i++)
			{
				var randomTeam:int = 0;
				var id:int = Math.floor(Math.random()*100*(Math.random()*100));
				
				if(i%2==0) randomTeam=1;
				
				var pongUser:PongUser = new PongUser(String("player_"+i), String(id), randomTeam, 0);
				twitterWall.addUser(pongUser);
				
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
				var paddle:Paddle;
				
				if(pongUser.team == 0){
					paddle = makePaddle(pongUser, paddleHeightTeam0);
					paddlesTeam0.push(paddle);
					paddle.pad.x = team0X;
					paddle.pad.alpha = Math.max(0.2,1-(team0.length/allUsers.length));
				}else{
					paddle = makePaddle(pongUser, paddleHeightTeam1);
					paddlesTeam1.push(paddle);
					paddle.pad.x = team1X;
					paddle.pad.alpha = Math.max(0.2,1-(team1.length/allUsers.length));
				}
				
				paddle.pad.y = Math.random()*(256)+192;
				starlingStage.addChild(paddle.pad);				
			}
		}
		
		private function makePaddle(user:PongUser, h:Number):Paddle
		{	
			var paddle:Paddle = new Paddle(user);
			paddle.makePaddleShape(paddleW, h);			
			return paddle;
		}
		
		
		private function prepGame():void
		{
			trace('prepGame');
			
			makePaddles();
			makeBall();			
		}
		
		private function makeBall():void
		{
			ballSpeed = ballSpeedInit = 5;
			
			if (ball == null)
			{
				ball = new starling.display.Quad(20, 20, 0xFFFFFF);
				ball.pivotX = ball.pivotY = 10;
				starlingStage.addChild(ball);
			}
			
			ball.visible = false;
		}
		
		
		private function kickOff():void
		{
			Math.random() > .5 ? ballXDir = ballYDir = 1 : ballXDir = ballYDir = -1;	
			
			countDownDisplay.visible = false;
			detectHits = true;
			ball.visible = true;
			centreLine.visible = true;
			
			scoreDisplay0.makeNumber(0);
			scoreDisplay1.makeNumber(0);
			scoreDisplay0.visible = scoreDisplay1.visible = true;
			
			resetGameAfterScore();
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			//testing paddle movement. needs replacing with data from PlayNow
			
			var paddleSets:Array = [paddlesTeam0, paddlesTeam1];
			
			for each (var pads:Array in paddleSets)
			{
				if(pads.length>1)
				{
					for (var i:int = 0; i< pads.length; i++)
					{
						TweenMax.to(pads[i].pad, Math.random()*1, {y:stage.mouseY+((Math.random()*256) - (Math.random()*256)), ease:Linear.easeNone });	
					}		
				}else{
					pads[0].pad.y = stage.mouseY -(pads[0].pad.height/2) ;	
				}
			}
		}
		
		private function tick(e:flash.events.Event):void
		{
			var i:int = 0;
			for(i; i < allUsers.length; ++i) {
				allUsers[i].update();
			}
			
			if(!ballMoving) return;
			
			
			
			//ball movement and scoring
			if(!hitPaddle){
				if(ball.y<5 ) {
					ballYDir=Math.random();
					PongSFX.play("PING_3");
				} else if(ball.y>763 ) {
					ballYDir=-Math.random();
					PongSFX.play("PING_3");
				}
				
				if(ball.x<5 ) score("team2");
				else if(ball.x>1019 ) score("team1");	
			}
			
			var currentXSpeed:Number = ballSpeed*ballXDir;
			var currentYSpeed:Number = ballSpeed*ballYDir;			
			
			ball.x+=currentXSpeed;
			ball.y+=currentYSpeed;
			
			hitPaddle = false;
			
			
			//collision detection
			if (detectHits)
			{			
				var collisionsCount:int;
				var paddles:Array;
				var padsHit:Vector.<Object> = new Vector.<Object>();
				
				//which team based on direction
				ballXDir == -1 ? paddles = paddlesTeam0 : paddles = paddlesTeam1;
				
				//check for ball hitting paddle
				for (i = 0; i< paddles.length; i++)
				{
					if (ball.bounds.intersects(paddles[i].pad.bounds))
					{
						if (!hitPaddle)	hitPaddle = true;
						playRandomPing();
						collisionsCount++;
						padsHit.push(paddles[i]);
					}
				}
				
				//check if paddle has enough players in the right area
				if (collisionsCount >= minPaddleDepth)
				{					
					//show hits
					for each(var pad:Paddle in padsHit)	
					{
						pad.colour = {hex:0xFFFFFF};
						var delay:Number = Math.random()*.1;
						
						TweenMax.to(pad.colour, .5, {hexColors:{hex:0x00FF00}, onUpdate:updatePaddleColour, onUpdateParams:[pad], delay:delay, yoyo:true, repeat:1}); // 0x82F578
						TweenMax.to(pad.pad, .5, {x:String(30*ballXDir), delay:delay, yoyo:true, repeat:1});
						
						pad.user.scorePoint();
					}
					
					//reset ball pos
					ballXDir==1 ? ball.x = team1X-ball.width/2 : ball.x = team0X+(ball.width/2)+paddleW;
					
					//change direction
					ballXDir *= -1;
					
					// speed up!
					//ballSpeed *= 1.1;
				}
				
				else if (collisionsCount>0 && collisionsCount<minPaddleDepth)
				{
					//not enough pads in place
					destroyPaddles(paddles);
					
					//trace("paddle too thin!", "collision", collisionsCount, "minPaddleDepth", minPaddleDepth);
				}
			}
			
		}
		
		private function playRandomPing():void
		{
			var pings:Array = ["PING_4", "PING_5"];
			ping = !ping;
			PongSFX.play(pings[ping ? 0 : 1]);
		}
			
		private function updatePaddleColour(paddle:Paddle):void
		{
			paddle.pad.color = paddle.colour.hex; 
		}
		
		private function resetPaddleColour(paddle:Paddle):void
		{
			paddle.pad.color = 0xFFFFFF;
		}
		
		private function destroyPaddles(pads:Array):void
		{
			detectHits=false;
			
			for each (var pad:Paddle in pads)
			{
				var distance:Number = 300;
				var randX:int = (Math.random()*distance)-(Math.random()*distance);
				var randY:int = (Math.random()*distance)-(Math.random()*distance);
				
				TweenMax.to(pad.pad, .75, {x:String(randX), y:String(randY), scaleX:0, scaleY:0, alpha:1, rotation:(Math.random()*180)-(Math.random()*180), ease:Sine.easeOut});
				
				pad.colour = {hex:0xFFFFFF};
				var delay:Number = Math.random()*.1;
				
				TweenMax.to(pad.colour, .4, {hexColors:{hex:0xFF0000}, onUpdate:updatePaddleColour, onUpdateParams:[pad], ease:Sine.easeOut });
			}
			
		}
		
		private function score(team:String):void
		{
			//hide ball
			ball.visible = false;
			
			//pause action
			ballMoving = false;
			//removeEventListener(flash.events.Event.ENTER_FRAME, tick);
			
			//score
			var padsToReset:Array;
			var padsXTo:Number;
			
			PongSFX.play("BOOM_1");
			
			if (team0Score==WIN_SCORE || team1Score==WIN_SCORE)
			{		
				if(team0Score>team1Score )
				{
					winningTeam = 0;
					losingTeam = 1;
				}else{
					winningTeam = 1;	
					losingTeam = 0;
				}
				gameOver();			
			}else{
				
				switch(team)
				{
					case "team1":
						team0Score ++;
						scoreDisplay0.makeNumber(team0Score);
						padsToReset = paddlesTeam1;
						padsXTo = team1X;
						break;
					
					case "team2":
						team1Score ++;
						scoreDisplay1.makeNumber(team1Score);
						padsToReset = paddlesTeam0;
						padsXTo = team0X;
						
						break;
				}	
				
				//reset game for next point
				TweenMax.delayedCall(1,resetPaddles,[padsToReset, padsXTo]);
				TweenMax.delayedCall(2,resetGameAfterScore);
			}
		}	
		
		private function gameOver():void
		{		
			trace("game over!");
			
			removeChild(fieldScreen);			
			removeAllPaddles();

			winnerScroller.initWithPlayers(this["team"+winningTeam]);
			loserScroller.initWithPlayers(this["team"+losingTeam]);

			addChild(gameOverScreen);
			
			//winning team
			
			gameOverScreen.teamWinnerTF.text = "TEAM "+String(winningTeam+1)+" WON!";
			gameOverScreen.winnersScroller.groupNameTF.text = "WINNERS";
			gameOverScreen.losersScroller.groupNameTF.text = "LOSERS";


			//top 3 players
			// Sort into rank. Highest first.
			var usersClone:Vector.<PongUser> = new Vector.<PongUser>();
			
			for(var j:int = 0; j < allUsers.length; j++) {
				usersClone.push(allUsers[j]);
			}
			
			
			usersClone.sort(function(cur:PongUser, next:PongUser):int {
				if(cur.score > next.score) return -1;
				//else if(cur.score == next.score) return 0;
				else return 1;
			});
			
			var playersToDisplay:int = Math.min(3, usersClone.length); 
			
			for (var k:int = 0; k<usersClone.length; k++)
			{
				usersClone[k].rank = k+1;
			}
			
			for (var i:int = 0; i<playersToDisplay; i++)
			{
				trace("score",usersClone[i].name,usersClone[i].score);
				var topPlayerDisplay:PongIndividualScore = new PongIndividualScore();	
				topPlayerDisplay.twitterNameTF.text = "@"+usersClone[i].name;
				topPlayerDisplay.scoreTF.text = usersClone[i].score;
				topPlayerDisplay.x = 30;
				topPlayerDisplay.y = 70+(i*55);
				
				var playerBitmap:Bitmap = usersClone[i].getUserBitmap();
				topPlayerDisplay.addChild(playerBitmap);
				playerBitmap.x = 67;
				
				gameOverScreen.topPlayers.addChild(topPlayerDisplay);
				
				TweenMax.from(topPlayerDisplay,1,{delay:i/2, y:800, ease:Expo.easeOut});
			}
			
			while(usersClone.length) {
				usersClone.shift();
			}
			
			//play now 
			endGame();
			
			// wait for SPACE
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownGameOver);
		}
		
		private function onKeyDownGameOver(e:KeyboardEvent):void
		{
			trace('\tKEY PRESSED:', e.keyCode);
			
			if (e.keyCode == Keyboard.SPACE)
			{
				//clear top scorers
				while(gameOverScreen.topPlayers.numChildren>2)	gameOverScreen.topPlayers.removeChildAt(2);
				
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownGameOver);
				removeChild(gameOverScreen);
				
				killAll();
				
	
				
				waitForPlayers();
				//if (debug) dispatchEvent(new flash.events.Event("SMASH_IT", true));
			}
		}
		
		private function killAll():void
		{
			trace('KILL ALL!');
			
			for each (var u:PongUser in allUsers)
			{
				u.destroy();
			}
			
			while (allUsers.length) allUsers.shift();
			
			twitterWall.reset();	
			winnerScroller.reset();
			loserScroller.reset();		
		}
		
		private function removeAllPaddles():void
		{
			for each (var u:PongUser in allUsers)
			{
				var p:Quad = u.paddle;
				if (starlingStage.contains(p)) starlingStage.removeChild(p);
				u.paddle = null;
			}
			
		}		
		
		private function resetPaddles(pads:Array, xTo:Number):void
		{
			var paddles:Array = [];
			
			for each (var p:Paddle in pads)
			{
				paddles.push(p.pad);
				resetPaddleColour(p);
			}
			
			TweenMax.staggerTo(paddles, .1, {x:xTo, rotation:0, alpha:Math.max(0.2,1-(pads.length/allUsers.length)), ease:Linear.easeNone, scaleX:1, scaleY:1}, .001);
			
			while (paddles.length)
			{
				paddles[0] = null;
				paddles.shift();
			}
			
			paddles = null;
		}
		
		
		private function resetGameAfterScore():void
		{
			trace("resetGameAfterScore");
			ball.x = 512;
			ball.y = 384;	
			
			ballSpeed = ballSpeedInit;
			ball.visible = true;
			detectHits = true;			
			ballMoving = true;
		}
		
		
		
		// PLAYERS
		
		
		override public function addPlayer(d:Object):void
		{
			trace('\ntrying to add player...');
			for (var i:* in d)
			{
				trace('\t', i, ':', d[i]);
			}
			trace('\n');
			
			
			if (gameState == GAME_WAITING)
			{			
				++numPlayers;				
				trace(numPlayers, 'players found');	
												
				var pongUser:PongUser = new PongUser(d.name, String(d.id), int(d.tid));
				twitterWall.addUser(pongUser);
				
				userNamesLookup[d.name] = pongUser;
				
				allUsers.push(pongUser);
				
				pongUser.team == 0 ? team0.push(pongUser) : team1.push(pongUser);
			}
			
		}
		
		override public function reconnectPlayer(d:Object):void
		{
			// reattach bats.
		}
		
		override public function removePlayer(d:Object):void
		{
			// remove bat.
		}
		
		override public function fire(id:uint):void
		{
			
		}
		
		
		public function doUserMove(id:String, move:Number):void
		{
			if (gameState != GAME_ACTIVE) return;
				
			var i:int = 0;
			for(i; i < allUsers.length; ++i) {
				if (allUsers[i].userID == id)
				{
					allUsers[i].setPosition(move);
					break;
				}
			}
		}
		
	}
}
