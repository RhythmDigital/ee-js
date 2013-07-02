package com.wehaverhythm.terry.rockrace
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Sine;
	import com.wehaverhythm.gui.CountDown;
	import com.wehaverhythm.physics.PhysicsEditor;
	import com.wehaverhythm.playnow.PlayNowEvent;
	import com.wehaverhythm.terry.generic.GameBaseNative;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import nape.callbacks.CbType;
	import nape.constraint.DistanceJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.util.ShapeDebug;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	/**
	 * Nape tut - http://www.gotoandlearn.com/play.php?id=157
	 */
	
	public class RockRaceGame extends Sprite
	{
		public static const GAME_STARTED:String = "GAME_STARTED";
		public static const GAME_OVER:String = "GAME_OVER";
		public static var GAME_RESET:String = "GAME_RESET";
		public static const TEAM_1:int = 0;
		public static const TEAM_2:int = 1;
		
		[Embed ("/assets/rockrace/rockRace.png", mimeType="image/png")]
		private const ROCKRACE_SPRITES:Class;
		
		[Embed(source="/assets/rockrace/rockRace.xml", mimeType="application/octet-stream")]
		private const ROCKRACE_SPRITES_DATA:Class;
		
		private const RPE_ROCK_LEFT:String = "-43, 1, -38, -23, -20, -34, -4, -34, 36, 5, 36, 22, 16, 36, -12, 36, -35, 25n-4, -34, 11, -39, 32, -28, 38.5, -10, 36, 5";//"-22, -32, -12, -44, 13, -40, 31, -21, 41, 5, 38, 19, 11, 40, -8, 37, -23, 26n-44, -4, -39, -24, -22, -32, -23, 26, -34, 25";
		private const RPE_ROCK_RIGHT:String = "-43, -10, -35, -29, -14, -40, 2, -34, -39, 4n2, -34, 17, -33, 34, -22, 39, 0, 31, 24, 9, 36, -18, 36, -39.25, 22, -39, 4";	//"-45, 4, -35, -23, -16, -40, 7, -45, 19, -32, 17, 26, 8, 36, -14, 41, -40, 21n19, -32, 37, -23, 41, -4, 30, 25, 17, 26";
		private const RPE_GROUND_PEAK:String = "-267, 44, 0, -44, 267, 44";
		
		private const MAX_ROCK_FALLBACK:Number = 100;
		private const GROUND_HEIGHT:int = 130;
		private const SEPERATOR_TARG_Y:int = 264;
		private const PLAYER_NUDGE_DIST:int = 6;
		
		private var keyPresses:Dictionary; // keyPress log's
		private var initialised:Boolean; // is the application initialised
		private var space:Space; // the 'world' as it is in box2d.
		private var sprites:TextureAtlas; // the master spritesheet atlas
		private var rockLeftBody:Body; // team 1 rock body
		private var rockRightBody:Body; // team 2 rock body
		private var debug:ShapeDebug; // the debug draw object
		private var physicsEnabled:Boolean = false; // are physics running?
		
		private var rocks:Array; // all rocks
		private var rockLeft:Rock; // team 1 rock
		private var rockRight:Rock; // team 2 rock
		private var ground:Body; // the ground body
		private var groundPeak:Body; // the mountain physics body
		private var groundPeakSprite:MovieClip; // the mountain sprite
		private var rockCap:Body;
		
		private var peakShowing:Boolean; // is the mountain showing?
		private var gameActive:Boolean; // is game play in progress (people pushing rocks)
		private var teamManager:RockTeams; // organises all of the teams. adds/removes/resets etc.
		private var seperatorLine:Image; // the strange faint vertical line in the centre.
		private var countdown:CountDown; // big countdown timer
		private var tapText:TapAnimation;	// tap!,tap!,tap! text.
		private var gameEnded:Boolean; // end sequence running.
		
		// collision detection
		private var collisionTypes:Object = {r0:new CbType(), r1:new CbType(), p0:new CbType(), p1:new CbType()};
		private var overlay:StageOverlay;
		private var bigWall:Body;
		private var rockFurthestX:Object;
		
		private var rockRain:Vector.<Rock> = new Vector.<Rock>();
		private var rockRainTimer:Timer;
		public var shakeAmount:Number;
		private var winTeam:int;
		private var rockPos:Boolean;
		private var prevRockYPos:int = 0;
		private var dancers:Array;
		private var danceTimer:Timer;
		
		public var viewportDefault:Rectangle;
		private var rockCapPivot:Body;
		private var rockCapJoint:DistanceJoint;
		
		public function RockRaceGame()
		{
			super();
			addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
			
			alpha = 0;
		}
		
		private function onAddedToStage():void
		{
			// TODO Auto Generated method stub
			trace("RockRaceGame initialised.");
			initialised = true;
			
			setBackground(0xffffff);
			initAssets();
			initPhysics();
			initOverlay();
			
			teamManager = new RockTeams(rockLeft, rockRight, stage.stageHeight - GROUND_HEIGHT, this, [sprites.getTexture("player_10000"), sprites.getTexture("player_20000")], collisionTypes);
			teamManager.addEventListener(PlayNowEvent.TEAM_MANAGER_UPDATE, onTeamManagerUpdate);
			
			// rock debug
			if(RockRace.DEBUG) {
				debug = new ShapeDebug(stage.stageWidth, stage.stageHeight);
				debug.drawConstraints = true;
				Starling.current.nativeStage.addChild(debug.display);	
			}
			
			seperatorLine = new Image(sprites.getTexture("separator0000"));
			//addChildAt(seperatorLine, 1);
			
			seperatorLine.x = stage.stageWidth >> 1;
			seperatorLine.y = stage.stageHeight;
			
			addEventListener(starling.events.Event.ENTER_FRAME, onEnterFrame);
			onEnterFrame(null);
			
			// FOR TESTING
			Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownDebug);
			Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpDebug);
			
			showWaitingScreen();
			
			Starling.current.nativeStage.dispatchEvent(new CustomEvent(PlayNowEvent.GAME_INITIALISED_FIRST_TIME, null, false, false));
			Starling.current.nativeStage.dispatchEvent(new flash.events.Event(GAME_RESET,true));
		}
		
		protected function onTeamManagerUpdate(e:flash.events.Event):void
		{
			trace("Team Manager Update");
			// update overlay here!
			if(!gameActive && teamManager.numPlayers == 2 && !countdown.running) {
				trace("THERE IS ENOUGH PLAYERS IN TEAMS");
				startCountdown();
			}
		}
		
		private function setBackground(col:uint):void
		{
			var bg:starling.display.Quad = new starling.display.Quad(stage.stageWidth, stage.stageHeight, col, true);
			addChild(bg);
		}
		
		private function initAssets():void
		{
			var spritesTexture:Texture = Texture.fromBitmap(new ROCKRACE_SPRITES(), false, false, 1);
			var spritesXML:XML = new XML(new ROCKRACE_SPRITES_DATA());
			sprites = new TextureAtlas(spritesTexture, spritesXML);
			
		}
		
		private function initPhysics():void
		{
			space = new Space(new Vec2(0, 3000)); // gravity.
			
			// GROUND!
			ground = new Body(BodyType.STATIC);
			ground.shapes.add(new Polygon(Polygon.rect(0,stage.stageHeight-110, stage.stageWidth*2, 20), new Material(0.1,1,1,1,2))); // ground
			ground.shapes.add(new Polygon(Polygon.rect(-20,0,20,stage.stageHeight), new Material(0.7,1,1,1,0.0010))); // left
			ground.shapes.add(new Polygon(Polygon.rect(stage.stageWidth,0,20,stage.stageHeight), new Material(0.7,1,1,1,0.0010))); // right
			//ground.shapes.add(new Polygon(Polygon.rect(0,-20,stage.stageWidth,20), new Material(0.7,1,1,1,0.0010))); // ceiling
			ground.space = space;
			
			rockCap = new Body(BodyType.STATIC);
			rockCap.shapes.add(new Polygon(Polygon.box(300,20)));
			rockCap.position.setxy(stage.stageWidth>>1,(stage.stageHeight>>1)+65);
			rockCap.allowRotation = false;
			//rockCap.mass = 2;
			
			// BIG WALL
			bigWall = new Body(BodyType.STATIC);
			bigWall.shapes.add(new Polygon(Polygon.rect((stage.stageWidth>>1)-10,0, 20, stage.stageHeight), new Material(0,1,1,1,0.0010)));
			
			
			// Ground image
			var groundTile:Image = new Image(sprites.getTexture("ground_tile_x0000"));
			groundTile.x = -stage.stageWidth*0.2;
			groundTile.y = stage.stageHeight - GROUND_HEIGHT;
			groundTile.width = stage.stageWidth*1.4;
			
			
			// GROUND PEAK!
			groundPeakSprite = new MovieClip(sprites.getTextures("ground_peak"), 60);
			groundPeak = PhysicsEditor.getNapeBody(RPE_GROUND_PEAK, BodyType.STATIC);
			groundPeak.position.x = (stage.stageWidth >> 1);
			groundPeak.position.y = stage.stageHeight - (GROUND_HEIGHT + 25);
			groundPeakSprite.pivotX = (groundPeakSprite.width >> 1);
			groundPeakSprite.pivotY = (groundPeakSprite.height >> 1);
			groundPeakSprite.x = groundPeak.position.x+2;
			groundPeakSprite.y = groundPeak.position.y+3;
			groundPeak.space = space;
			groundPeak.userData.graphic = groundPeakSprite;
			Starling.juggler.add(groundPeakSprite);
			groundPeakSprite.pause();
			
			// Ground Shadow Mask
			var shadowMask:starling.display.Quad = new starling.display.Quad(stage.stageWidth, GROUND_HEIGHT, 0xf2f2f2);
			shadowMask.y = stage.stageHeight - (GROUND_HEIGHT-20);
			
			// make rock bodies
			rockLeft = addRock("left", new Vec2(300, stage.stageHeight-GROUND_HEIGHT));
			rockRight = addRock("right", new Vec2(stage.stageWidth-300, stage.stageHeight-GROUND_HEIGHT));
			
			// init collisions
//			var rockLeftCollision:InteractionListener = new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, collisionTypes.r0, collisionTypes.p0, onRockLeftCollision);
//			var rockRightCollision:InteractionListener = new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, collisionTypes.r1, collisionTypes.p1, onRockRightCollision);
//			space.listeners.add(rockLeftCollision);
//			space.listeners.add(rockRightCollision);
			
			rocks = [rockLeft, rockRight];
			rockLeft.body.cbTypes.add(collisionTypes.r0);
			rockRight.body.cbTypes.add(collisionTypes.r1);
			
			addChild(groundTile);
			addChild(groundPeakSprite);
			addChild(shadowMask);
		}
		/*
		private function onRockRightCollision(collision:InteractionCallback):void
		{
			trace("rock right");
			rockRight.body.angularVel = ROCK_ANG_VEL*-1;
			//rockRight.body.rotation -= Trig.getRadians(10);
		}
		
		private function onRockLeftCollision(collision:InteractionCallback):void
		{
			trace("rock left");
			rockRight.body.angularVel = ROCK_ANG_VEL;
			//rockLeft.body.rotation += Trig.getRadians(10);
		}
		*/
		private function initOverlay():void
		{
			overlay = new StageOverlay();
			overlay.alpha = 0;
			Starling.current.nativeOverlay.addChild(overlay);
			
			countdown = new CountDown(overlay.startCounter);
			countdown.addEventListener(CountDown.COUNTDOWN_COMPLETE, onCountdownComplete);
			
			// team flags
			overlay.team1.scaleX = overlay.team1.scaleY = overlay.team2.scaleX = overlay.team2.scaleY = 1.5;
			overlay.team1.x = -(overlay.team1.width + 20);
			overlay.team2.x = stage.stageWidth + overlay.team2.width + 20;
			overlay.team1.y = overlay.team2.y = 140;
			
			// win box
			overlay.winBox.scaleX = overlay.winBox.scaleY = 0;			
			overlay.logo.y = stage.stageHeight + 100;
				
			// new tap animation instance
			tapText = new TapAnimation();
			tapText.x = stage.stageWidth >> 1;
			tapText.y = 130;
		}
		
		public function start():void
		{
			TweenMax.to(this, .4, {autoAlpha:1, ease:Sine.easeIn});
			TweenMax.to(overlay, .4, {autoAlpha:1, ease:Sine.easeIn});
			TweenMax.to(overlay.team1, .4, {delay:1, x:250, ease:Sine.easeOut});
			TweenMax.to(overlay.team2, .4, {delay:1.1,x:stage.stageWidth - 250, ease:Sine.easeOut});
		}
		
		protected function onCountdownComplete(e:flash.events.Event):void
		{
			startGame();
		}
		
		public function resetGame():void
		{
			// put everything back to its start position, and show connect screen.
			rockLeft.detachBody();
			rockRight.detachBody();
			
			showRockCap = true;
			
			rockFurthestX = {r0:0, r1:stage.stageWidth};
			
			TweenMax.allTo([rockLeft, rockRight], .4, {y:0, alpha:0, onComplete:removeRocks});
			
			countdown.reset();
			teamManager.reset(); // remove all players
			
			Starling.current.nativeStage.dispatchEvent(new flash.events.Event(GAME_RESET,true));
		
			gameActive = false;
			gameEnded = false;
		}
		
		private function removeRocks():void
		{
			rockLeft.resetRocks();
			rockRight.resetRocks();
			
			rockLeft.attachBody();
			rockRight.attachBody();
			if(contains(rockLeft)) removeChild(rockLeft);
			if(contains(rockRight)) removeChild(rockRight);
		}
		
		public function showWaitingScreen():void
		{
			trace("Showing waiting screen");
			resetGame();
			physicsEnabled = true;
			
			showBigJoinIn(1);
		}
		
		public function startCountdown():void
		{
			trace("Start countdown");
			countdown.start();
			
			TweenMax.to(overlay.joinIn, .4, {delay:.2, y:664, scaleX:1, scaleY:1, ease:Sine.easeOut});
			TweenMax.to(overlay.logo, .4, {delay:.2, y:stage.stageHeight + 100, autoAlpha:0, ease:Sine.easeIn});
		}
		
		public function showBigJoinIn(delay:Number = .7):void
		{
			TweenMax.to(overlay.joinIn, .4, {delay:delay, y:stage.stageHeight>>1, scaleX:1.7, scaleY:1.7, ease:Sine.easeOut});
			TweenMax.to(overlay.logo, .4, {delay:delay, y:690, autoAlpha:.6, ease:Sine.easeIn});
		}
		
		public function startGame():void
		{
			addChild(rockLeft);
			addChild(rockRight);
			
			
			// enable physics on rocks.
			
			updateGraphics(rockLeft.body);
			updateGraphics(rockRight.body);
			//rockRight.active = rockLeft.active = false;
			
			rockLeft.alpha = rockRight.alpha = 1;
			TweenMax.from(rockLeft, 1, {delay:.7, y:-300, alpha:0, ease:Bounce.easeOut, overwrite:1});
			TweenMax.from(rockRight, 1, {delay:.9, y:-300, alpha:0, ease:Bounce.easeOut, onComplete:activateRocks, overwrite:1});
			
			TweenMax.delayedCall(1.1, shakeScreen, [10]);
			TweenMax.delayedCall(1.3, shakeScreen, [10]);
			
			showTapText();
		}
		
		private function activateRocks():void
		{
			rockRight.active = rockLeft.active = true;
			startPushingRocks();
		}
		
		private function showTapText():void
		{
			trace("Show tap text!");
			Starling.current.nativeOverlay.addChild(tapText);
			tapText.play(1);
		}
		
		private function startPushingRocks():void
		{
			gameActive = true;
			Starling.current.nativeStage.dispatchEvent(new flash.events.Event(RockRaceGame.GAME_STARTED));
		}
		
		private function startPhysics():void
		{
			physicsRunning = true;
		}
		
		private function set physicsRunning(state:Boolean):void
		{	
			physicsEnabled = state;
		}
		
		/**
		 * Hit ball!
		 */
		public function fire(team:int):void
		{
			if(gameActive) teamManager.moveTeam(team, PLAYER_NUDGE_DIST);
		}
		
		/**
		 * Add Player
		 */
		public function addPlayer(d:Object):void
		{
			teamManager.addPlayer(d, d.tid);
		}
		
		/**
		 * Remove Player
		 */
		public function removePlayer(d:Object):void
		{
			teamManager.removePlayer(d);
		}
		
		protected function onKeyUpDebug(e:KeyboardEvent):void
		{
			keyPresses[e.keyCode] = false;
		}
		
		private function onKeyDownDebug(e:KeyboardEvent):void
		{
			if(!keyPresses) keyPresses = new Dictionary();
			keyPresses[e.keyCode] = true;
			
			var i:int = 0;
			var p:Player;
			
			switch(e.keyCode) {
				
				// MOVE TEAM 0
				case Keyboard.LEFT:
					if(gameActive) teamManager.moveTeam(TEAM_1, PLAYER_NUDGE_DIST);
					break;
				
				// MOVE TEAM 1
				case Keyboard.RIGHT:
					if(gameActive) teamManager.moveTeam(TEAM_2, PLAYER_NUDGE_DIST);
					break;
				
				// Add dummy player to team 1
				case Keyboard.NUMBER_1:
					if(keyPresses[Keyboard.SHIFT]) teamManager.removeDummyPlayer(TEAM_1);
					else teamManager.addDummyPlayer(TEAM_1);
					break;
				
				// Add dummy player to team 2
				case Keyboard.NUMBER_2:
					if(keyPresses[Keyboard.SHIFT]) teamManager.removeDummyPlayer(TEAM_2);
					else teamManager.addDummyPlayer(TEAM_2);
					break;
				
				case Keyboard.SPACE:
				//	beginGameOverSequence(TEAM_1);
					break;
			}
		}
		
		private function makeRockBody(side:String):Body
		{
			var b:Body = PhysicsEditor.getNapeBody(side == "left" ? RPE_ROCK_LEFT : RPE_ROCK_RIGHT, BodyType.DYNAMIC, new Material(0,3,4,4,4));
			return b;
		}
		
		//http://blog.onebyonedesign.com/actionscript/starling-nape-physics-and-physicseditor/
		private function addRock(side:String, pos:Vec2):Rock
		{
			//trace("New Rock.");
			var rock:Rock = new Rock(sprites.getTexture("rock_"+side+"0000"), makeRockBody(side), pos, space);
			return rock;
		}
		
		private function updateGraphics(b:Body, forceUpdate:Boolean = false):void
		{
			//trace("update!");
			var img:DisplayObject = b.userData.graphic as DisplayObject;
			
			img.x = b.position.x;
			img.y = b.position.y;
			img.rotation = b.rotation;
			
			/*if(img.parent && img.parent is Rock && Math.abs(b.velocity.x) > MAX_VEL) {
				trace("Cap X Vel to " + MAX_VEL);
				b.velocity.x = b.velocity.x < 0 ? -MAX_VEL : MAX_VEL;
			}*/
		}
		
		private function onEnterFrame(e:starling.events.Event):void
		{	
			if(physicsEnabled || e == null)
			{
				space.step(1/Starling.current.nativeStage.frameRate);
				space.liveBodies.foreach(updateGraphics);
			} 
			
			// check if a rock is over the mid point.
			if(!gameEnded && gameActive) {
				
				var rockLeftDistBehind:Number = 0;
				var rockRightDistBehind:Number = 0;
				
				// track rock positions
				if(rockLeft.x > rockFurthestX.r0) {
					rockFurthestX.r0 = rockLeft.x;
				} else {
					rockLeftDistBehind = rockFurthestX.r0-rockLeft.x;
					//trace("ROCK LEFT FALLING BEHIND BY: " + rockLeftDistBehind);
				}
				
				if(rockRight.x < rockFurthestX.r1) {
					rockFurthestX.r1 = rockRight.x;
				} else {
					rockRightDistBehind = rockRight.x-rockFurthestX.r1;
					//trace("ROCK RIGHT FALLING BEHIND BY: " + rockRightDistBehind);
				}
				
				if(rockLeftDistBehind > MAX_ROCK_FALLBACK || rockRightDistBehind > MAX_ROCK_FALLBACK) {
					gameActive = false;
					if(rockRightDistBehind > rockLeftDistBehind) {
						beginGameOverSequence(TEAM_1, false);
					} else {
						beginGameOverSequence(TEAM_2, false);
					}
				}
				
				var halfStageW:Number = stage.stageWidth >> 1;
				if (rockLeft.x > halfStageW || rockRight.x < halfStageW && gameActive)
				{
					gameActive = false;
					
					if (rockLeft.x > halfStageW) {
						beginGameOverSequence(TEAM_1);
					} else {
						beginGameOverSequence(TEAM_2);
					}
				}
			}
			
			// draw debug
			if(RockRace.DEBUG) 
			{
				debug.clear();
				debug.flush();
				debug.draw(space);	
			}
		}
		
		private function beginGameOverSequence(winTeam:int, fireWinnersRock:Boolean = true):void
		{
			gameEnded = true;
			trace("Team " + winTeam + " won!");
			
			showRockCap = false;
			
			var impulse:Number = 200;
			var rock:Rock = rocks[winTeam];
			var opposition:int = winTeam == 0 ? 1 : 0;
			
			// if team is 2 (1)
			if(winTeam == TEAM_2) {
				impulse *= -1;
			}
			
			if(fireWinnersRock) rock.body.applyImpulse(new Vec2(impulse, 0), new Vec2(rock.body.localCOM.x, rock.body.localCOM.y+5));
			//rocks[opposition].body.applyImpulse(new Vec2(impulse, 5), new Vec2(rock.body.localCOM.x, rock.body.localCOM.y+5));
			
			Starling.current.nativeStage.dispatchEvent(new CustomEvent(RockRaceGame.GAME_OVER, {event:"end", winnerID:winTeam}, false, true));
			
			showWinBox(winTeam, 1);
			TweenMax.delayedCall(1.2, startRockRain, [winTeam, opposition]);
			TweenMax.delayedCall(1.2, blastPeople, [opposition]);
			TweenMax.delayedCall(.1, dancePeople, [winTeam]);
			TweenMax.delayedCall(8, clearEndScreenAssets);
		}
		
		private function showWinBox(winTeam:int, delay:Number = .5):void
		{
			var b:WinBox = overlay.winBox as WinBox;
			
			b.txtWinner.text = "TEAM " + (winTeam+1);
			b.txtCrushed.text = "TEAM "+(winTeam == TEAM_1 ? 2 : 1)+" ARE CRUSHED ";
			b.cacheAsBitmap = true;
			TweenMax.to(b, .7, {delay:delay, scaleX:1, scaleY:1, ease:Expo.easeOut, overwrite:2});
		}
		
		private function startRockRain(winTeam:int, loseTeam:int, amount:int = 40):void
		{
			// bigWall.space = space;
			this.winTeam = winTeam;
			
			if(!rockRainTimer) 
			{
				rockRainTimer = new Timer(20, amount);
				rockRainTimer.addEventListener(TimerEvent.TIMER, rockRainTimerTick);
			}
			else rockRainTimer.reset();			
			
			shakeScreen(amount);			
			rockRainTimer.start();
		}
		
		private function rockRainTimerTick(e:TimerEvent):void
		{
			var rockScale:Number = .4 + Math.random();
			var rainRandomX:Number = 100 + Math.random()*((stage.stageWidth>>1) - 200);
			
			if (winTeam == 0) rainRandomX += stage.stageWidth>>1;
			
			var r:Rock = addRock(winTeam == 0 ? "left":"right", new Vec2(0, 0));
			
			if(rockPos) rainRandomX += r.width;
			var rockY:int = rockPos ? prevRockYPos-(r.height*2) : prevRockYPos+(r.height*2);
			r.body.position.x = rainRandomX;
			r.body.position.y = rockY;
			trace(rockY);
			
			
			
			r.scaleX = r.scaleY = rockScale;
			r.body.scaleShapes(rockScale,rockScale);
			r.body.angularVel = -10+Math.random()*20;
			rockRain.push(r);
			addChild(r);
			
			rockPos = !rockPos;
			prevRockYPos = rockY;
		}
		
		private function shakeScreen(amount:int):void
		{
			shakeAmount = amount/2;
			TweenMax.to(this, amount*.04, {shakeAmount:0, ease:Sine.easeOut, onUpdate:updateShakeScreen, onComplete:resetAfterShakeScreen}); 
		}
		
		private function updateShakeScreen():void
		{
			Starling.current.viewPort.x = viewport.x+(-shakeAmount + Math.random()*(shakeAmount*2));
			Starling.current.viewPort.y = viewport.y+(-shakeAmount + Math.random()*(shakeAmount*2));
		}
		
		private function resetAfterShakeScreen():void
		{
			Starling.current.viewPort.x = viewport.x;
			Starling.current.viewPort.y = viewport.y;
		}
		
		private function blastPeople(opposition:int):void
		{
			// reduce opposition masses
			teamManager.makeLightweight(opposition, 1);
			
			var oppPhysicsPeople:Array = teamManager.getPhysicsPeople(opposition);
			for each(var p:Player in oppPhysicsPeople) {
				p.destroyJoints();
				//				var loc:Vec2 = new Vec2(p.body.localCOM.x + (opposition == 0) ? 20 : -20, p.body.localCOM.y + 20); // give it a bash on it's bottom.
				p.body.allowMovement = true;
				p.body.allowRotation = true;
				p.body.align();
				p.body.applyImpulse(p.body.worldVectorToLocal(new Vec2(23,10)), new Vec2(-8,4));//p.body.worldPointToLocal(new Vec2(stage.stageWidth>>1, 400)));
			}
		}
		
		private function dancePeople(winTeam:int):void
		{
			// reduce masses
			teamManager.makeLightweight(winTeam, 1);
			
			// get winning team players
			dancers = teamManager.getPhysicsPeople(winTeam);
			
			danceTimer = new Timer(200, dancers.length);
			danceTimer.addEventListener(TimerEvent.TIMER, danceTimerTick);		
			danceTimer.start();			
		}
		
		private function danceTimerTick(e:TimerEvent):void
		{
			trace('=====>', Timer(e.target).currentCount);
			
			var p:Player = dancers[Timer(e.target).currentCount-1];
			p.destroyJoints();
			p.body.allowMovement = true;
			p.body.allowRotation = true;
			p.body.align();
			p.body.applyImpulse(p.body.worldVectorToLocal(new Vec2(0, 20)), new Vec2(0, 2+Math.random()*4));
		}
		
		private function clearEndScreenAssets():void
		{
			var b:WinBox = overlay.winBox as WinBox;
			TweenMax.to(overlay.winBox, .7, {scaleX:0, scaleY:0, ease:Expo.easeIn, overwrite:2});
			bigWall.space = null;
			TweenMax.delayedCall(2, showWaitingScreen);
			
			for each (var rock:Rock in rockRain)
			{
				rock.shrinkAndDie(Math.random()*2);
			}
			
			while (rockRain.length) { rockRain.shift(); };
		}
		
		/*
		if(!keyPresses[Keyboard.SHIFT]) {
		// team 0
		
		if(rockLeft.bounds.intersects(peopleLeft[peopleLeft.length-1].bounds)) {
		rockLeft.body.angularVel = 8;
		}
		
		for(i = peopleLeft.length; i > 0; --i) {
		p = peopleLeft[i-1];
		p.targetX += 5;
		
		if(p.targetX < (stage.stageWidth >> 1)) {
		TweenMax.to(p.body.position, .7, {delay:(i-1)*0.01, x:p.targetX, ease:com.greensock.easing.Elastic.easeOut, overwrite:2});
		}
		
		}
		
		} else {
		// team 1
		
		if(rockRight.bounds.intersects(peopleRight[peopleRight.length-1].bounds)) {
		rockRight.body.angularVel = -8;
		}
		
		for(i = peopleRight.length; i > 0; --i) {
		p = peopleRight[i-1];
		p.targetX -= 5;
		
		if(p.targetX > (stage.stageWidth >> 1)) {
		TweenMax.to(p.body.position, .7, {delay:(i-1)*0.01, x:p.targetX, ease:com.greensock.easing.Elastic.easeOut, overwrite:2});
		}
		}
		
		}
		//rockLeft.body.applyImpulse(new Vec2(MAX_FORCE, 0), rockLeft.body.localCOM);
		//people[0].body.applyImpulse(new Vec2(MAX_FORCE, 0), rockLeft.body.localCOM);
		*/
		
		public function set showRockCap(state:Boolean):void
		{
			if(state) {
				rockCap.space = space;
			} else {
				rockCap.space = null;
			}
		}
		
		public function get viewport():Rectangle
		{
			if(!viewportDefault) viewportDefault = Starling.current.viewPort.clone();
			return viewportDefault
		}
		
		public function handledCustomObject(data:Object):void
		{
			trace("----------------\nCustom Data: ");
			for(var k:String in data) {
				
				trace("\t"+k+": " + data[k]);
			}
			trace("----------------");
		}
	}
}