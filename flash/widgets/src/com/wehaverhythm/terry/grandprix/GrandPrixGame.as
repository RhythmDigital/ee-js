package com.wehaverhythm.terry.grandprix
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Sine;
	import com.wehaverhythm.terry.generic.GameBaseNative;
	import com.wehaverhythm.terry.generic.GameCountDown;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import starling.events.Event;
	
	
	public class GrandPrixGame extends GameBaseNative
	{		
		public var cars:Array;
		private var playerManager:GrandPrixPlayerManager;
		
		private var waitScreen:GrandPrixWaiting;
		private var raceCountDown:RaceCountDown;
		
		private var autoDrive:Boolean;
		private var laps:int;
		private var maxLaps:int;
		
		private var fairnessManager:FairnessManager;
		
		private var autoDriveTimer:Timer;
		private var resetMaxSpeeds:Boolean;
		
		private var winnerText:Winner;
		private var celebrationTime:int;
		
		private var track:Track;
		
		
		public function GrandPrixGame()
		{
			super();
			minPlayers = 1;
			countDownFrom = 5;
			maxLaps = 1;
			celebrationTime = 14;
			autoDrive = false;
		}
		
		override public function init(debug:Boolean, playerData:Array):void
		{
			super.init(debug, playerData);
		}
		
		override protected function onStarlingReady(e:starling.events.Event):void
		{
			super.onStarlingReady(e);
			
			initBG();
			initTrack();			
			initPlayers();
			initRaceCountDown();
			
			addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function initBG():void
		{
			var bg:Sprite = new BG();
			addChildAt(bg, 0);
		}
		
		private function initTrack():void
		{
			track = new TrackDisplay();
			track.reset();
			addChild(track);
			addChild(track.bridge);
		}
		
		private function initPlayers():void
		{
			cars = [];
			
			for (var i:int=0; i<4; ++i)
			{
				var car:Car = new RacingCar();
				car.init(i, [new Vector2D(waitScreen['grid'+i].x - 60, waitScreen['grid'+i].y)], -50, waitScreen['grid'+i].y, 1.5, 9.8);
				car.addEventListener(Car.LAP_COMPLETE, onCarLapComplete);
				cars.push(car);
			}
			
			playerManager = new GrandPrixPlayerManager();
			playerManager.init(playerData, cars);
			
			resetMaxSpeeds = autoDrive;
			
			if (autoDrive) 
			{
				for (i=0; i<4; ++i)
				{
					addPlayer({name:'Player ' + (i+1), type:'join', id:i});
				}
			}
		}
		
		private function initRaceCountDown():void
		{
			raceCountDown = new RaceCountDownDisplay();
			raceCountDown.reset();
			raceCountDown.x = stage.stageWidth/2;
			raceCountDown.y = stage.stageHeight/2;
			raceCountDown.addEventListener(RaceCountDown.START_RACE, onRaceCountDownComplete);
			addChild(raceCountDown);
		}
		
		override protected function startCountdown():void
		{
			countdown.addEventListener(GameCountDown.SET_TIME, onSetCountDown);
			super.startCountdown();
			waitScreen.showCountdown();
		}
		
		private function onSetCountDown(event:CustomEvent):void
		{
			waitScreen.seconds.text = event.params.time;
		}
		
		override public function resetGame():void
		{
			super.resetGame();
			
			laps = 0;
			
			if (winnerText)
			{
				if (this.contains(winnerText)) removeChild(winnerText);
				
				for (var i:int=0; i<4; ++i)
				{
					cars[i].reset(); 
				}
			}
			
			if (!waitScreen) waitScreen = new GrandPrixWaitingDisplay();
			waitScreen.init();
			addChild(waitScreen);
			
			waitScreen.show();
		}
		
		override protected function startGame():void
		{			
			waitScreen.reset();
			super.startGame();
			
			trace(this, 'START GAME with', numPlayers, 'players');
			
			for (var i:int=0; i<4; ++i)
			{
				trace(this, cars[i]); 
				
				if (cars[i].playerId > -1)
				{
					TweenMax.to(cars[i], .5, {delay:Math.random()*.4, x:track['car'+i].x, y:track['car'+i].y, scaleX:track['car'+i].scaleX, scaleY:track['car'+i].scaleY, ease:Bounce.easeOut});
					cars[i].initForRace(resetMaxSpeeds, track.paths[i], track.maxSpeeds[i]);
				}
			}
			
			addChild(raceCountDown);
			TweenMax.to(track, .37, {delay:.5, autoAlpha:1, ease:Sine.easeIn, onComplete:raceCountDown.start});
		}
		
		private function onRaceCountDownComplete(event:flash.events.Event):void
		{
			track.bridge.visible = true;
			
			if (autoDrive) initAutoDrive();
			
			track.lapCounter.laps.text = String(laps+1) + '/' + maxLaps;
			
			for (var i:int=0; i<4; ++i)
			{
				cars[i].move = true;
				cars[i].startTimingLap();
			}
		}
		
		private function initAutoDrive():void
		{
			if (!autoDriveTimer) 
			{
				autoDriveTimer = new Timer(20);
				autoDriveTimer.addEventListener(TimerEvent.TIMER, onAutoDriveTimerTick);
			}
			
			autoDriveTimer.start();
			
			// if (!fairnessManager) fairnessManager = new FairnessManager(cars);
		}
		
		protected function onAutoDriveTimerTick(event:TimerEvent):void
		{
			for (var i:int=0; i<4; ++i)
			{
				cars[i].push();
			}
		}
		
		private function onCarLapComplete(event:CustomEvent):void
		{
			laps = 0;
			var winner:Car;
			
			for (var i:int=0; i<4; ++i)
			{ 
				if (cars[i].lapTimes.length > laps)
				{
					laps = cars[i].lapTimes.length;
					winner = cars[i];
				}
			}
			
			if (laps < maxLaps) track.lapCounter.laps.text = String(laps+1) + '/' + maxLaps;				
			else endGame(winner.playerId);
		}
		
		override protected function endGame(winnerId:uint=0, data:Object = null):void
		{
			super.endGame(winnerId);
			track.reset();
			
			showWinnerText();
			
			var winningCar:Car = playerManager.getCarByPlayerId(winnerId);
			
			for (var i:int=0; i<4; ++i)
			{
				if (cars[i] == winningCar) cars[i].wins();
				else cars[i].reset(); 
			}
			
			TweenMax.delayedCall(celebrationTime, waitForPlayers);
		}
		
		private function showWinnerText():void
		{
			if (!winnerText)
			{
				winnerText = new Winner();
				winnerText.alpha = .12;
				winnerText.blendMode = BlendMode.ADD;
				winnerText.x = 1280 >> 1;// stage.stageWidth >> 1;
				winnerText.y = 720 >> 1;// stage.stageHeight >> 1;
				winnerText.scaleX = winnerText.scaleY = 7.39;
			}
			
			winnerText.gotoAndPlay(1);
			addChildAt(winnerText, 2);
		}
		
		protected function onEnterFrame(event:flash.events.Event):void
		{
			addChildAt(track.bridge, 3);
			
			for (var i:int=0; i<4; ++i)
			{ 
				cars[i].update();
				
				// over or under bridge?				
				if (cars[i].racing)
				{
					if (cars[i].pathIndex < 3) 
					{
						// if (getChildIndex(cars[i]) != 3) Debug.showDisplayList(this);
						addChildAt(cars[i], 3);
					}
					else addChild(cars[i]);
				}
			}
		}
		
		override public function addPlayer(d:Object):void
		{
			super.addPlayer(d);	
			
			// if (gameState == GAME_WAITING || gameState == GAME_COUNTDOWN) playerManager.addPlayer(d);
			
			if (gameState == GAME_WAITING || gameState == GAME_COUNTDOWN || gameState == GAME_ACTIVE)
			{			
				playerManager.addPlayer(d);
				
				var car:Car = playerManager.getCarByPlayerId(d.id);
				
				
				
				if (car) 
				{
					car.showConnected(true);
					
					if (!car.parent)
					{
						car.move = true;
						car.push(100);
					}
					
					addChild(car);
				}
			}
		}
		
		override public function reconnectPlayer(d:Object):void
		{
			var car:Car = playerManager.getCarByPlayerId(d.id);
			if (car) car.showConnected(true);
		}
		
		
		override public function removePlayer(d:Object):void
		{
			//super.removePlayer(d);
			
			var car:Car = playerManager.getCarByPlayerId(d.id);
			if (car) car.showConnected(false);
			
			//playerManager.removePlayer(d);			
		}
		
		override public function fire(id:uint):void
		{
			var car:Car = playerManager.getCarByPlayerId(id);
			if (car) {
				car.showConnected(true);
				car.push();
			}
		}
		
		override protected function onKeyUpDebug(e:KeyboardEvent):void
		{
			super.onKeyUpDebug(e);
			cars[0].pushing = false;
		}
		
		override protected function onKeyDownDebug(e:KeyboardEvent):void
		{
			super.onKeyDownDebug(e);
			
			switch(e.keyCode)
			{			
				case Keyboard.RIGHT:
					cars[0].push();
					break;
			}
		}
		
	}
}