package com.wehaverhythm.terry.generic
{
	import com.wehaverhythm.playnow.PlayNowEvent;
	import com.wehaverhythm.terry.grandprix.StarlingStage;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	
	public class GameBaseNative extends flash.display.Sprite
	{
		public static const GAME_STARTED:String = 'GAME_STARTED';
		public static const GAME_OVER:String = 'GAME_OVER';
		public static const GAME_RESET:String = 'GAME_RESET';
		
		protected var initialised:Boolean; // is the application initialised
		protected var debug:Boolean;
		
		// game state
		protected var state:String;
		public static const GAME_WAITING:String = 'GAME_WAITING';
		public const GAME_COUNTDOWN:String = 'GAME_COUNTDOWN';
		public const GAME_ACTIVE:String = 'GAME_ACTIVE';
		public const GAME_INACTIVE:String = 'GAME_INACTIVE';
		
		// messaging
		public static const DISPATCH_EVENT_TO_ALL:String = 'DISPATCH_EVENT_TO_ALL';
		public static const DISPATCH_EVENT_TO_USER:String = 'DISPATCH_EVENT_TO_USER';
		
		// misc
		protected var countdown:GameCountDown;
		protected var keyPresses:Dictionary;
		
		// players
		protected var minPlayers:int = 2;
		protected var numPlayers:int;
		protected var playerData:Array;
		
		protected var countDownFrom:int = 5;
		protected var mStarling:Starling;
		
		// starling
		protected var starlingStage:StarlingStage;
		protected var viewportRatio:Number;
		
		
		public function GameBaseNative()
		{
			super();
			addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:flash.events.Event):void
		{
			trace('GameBaseNative added to stage & initialised');
			initialised = true;
			
			viewportRatio = stage.stageWidth / stage.stageHeight;	
			//scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}
		
		public function init(debug:Boolean, playerData:Array):void
		{
			this.debug = debug;
			
			if (debug)
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownDebug);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpDebug);
			}
			
			this.playerData = playerData;			
			initStarling();
		}
		
		protected function initStarling():void
		{
			trace("init Starling...");
			mStarling = new Starling(StarlingStage, stage, new Rectangle(0,0,stage.stageWidth, stage.stageHeight));
			mStarling.start();
			mStarling.addEventListener(starling.events.Event.ROOT_CREATED, onStarlingReady);
		}
		
		protected function onStarlingReady(e:starling.events.Event):void
		{
			starlingStage = Starling.current.root as StarlingStage;
			Starling.current.nativeOverlay.addChild(this);			
			
			stage.addEventListener(flash.events.Event.RESIZE, onResize);
			
			countdown = new GameCountDown(countDownFrom);
			countdown.addEventListener(GameCountDown.COMPLETE, onCountdownComplete);
			
			stage.dispatchEvent(new flash.events.Event(PlayNowEvent.GAME_INITIALISED_FIRST_TIME, true));
			
			trace('GameBaseNative onStarlingReady');
			waitForPlayers();
			
			onResize(null);
		}
		
		protected function onResize(e:flash.events.Event):void
		{
			if (mStarling)
			{
				var v:Rectangle = mStarling.viewPort;
				
				// Make Starling viewport 16:9, centre it vertically if nessecery.
				
				v.width = stage.stageWidth;
				var newHeight:Number = stage.stageWidth/viewportRatio;
				v.height = newHeight;
				
				if(newHeight > stage.stageHeight) {
					v.height = stage.stageHeight;
					var newWidth:Number = stage.stageHeight*viewportRatio;
					v.width = newWidth;
				}
				
				v.x = (stage.stageWidth>> 1)-(v.width>>1);
				v.y = (stage.stageHeight>> 1)-(v.height>>1);
				
				Starling.current.viewPort.x = v.x;
				Starling.current.viewPort.y = v.y;
				Starling.current.viewPort.width = v.width;
				Starling.current.viewPort.height = v.height;
			}
		}
		
		
		/*
		
		START SEQUENCE
		
		1)	waiting screen - needs to wait for enough players
		2)	countdown starts
		3)	game starts
		
		*/
		
		protected function waitForPlayers():void
		{
			trace('Waiting for', minPlayers, 'players...');
			resetGame();
			gameState = GAME_WAITING;
			dispatchEvent(new flash.events.Event(GAME_WAITING, true));
		}
		
		protected function startCountdown():void
		{
			trace('Start countdown');
			gameState = GAME_COUNTDOWN;
			countdown.start();
		}		
		
		protected function onCountdownComplete(e:flash.events.Event):void
		{
			startGame();
		}
		
		protected function startGame():void
		{
			gameState = GAME_ACTIVE;
			dispatchEvent(new flash.events.Event(GAME_STARTED, true));
		}
		
		protected function endGame(winnerId:uint = 0, data:Object = null):void
		{
			if(data == null) data = new Object();
			data.winnerId = winnerId;
			data.event = "end";
			
			gameState = GAME_INACTIVE;
			dispatchEvent(new CustomEvent(GAME_OVER, data, false));
			
			//trace(this, 'Player id:', winnerId, 'wins!');
			
	
		}
		
		public function resetGame():void
		{
			// put everything back to its start position, and show connect screen.				
			
			numPlayers = 0;
			
			if (countdown) countdown.reset();			
			dispatchEvent(new flash.events.Event(GAME_RESET, true));			
			gameState = GAME_INACTIVE;
		}
		
		
		/* 
		KEYS 
		*/
		
		protected function onKeyUpDebug(e:KeyboardEvent):void
		{
			if (keyPresses) keyPresses[e.keyCode] = false;
		}
		
		protected function onKeyDownDebug(e:KeyboardEvent):void
		{
			if (!keyPresses) keyPresses = new Dictionary();
			keyPresses[e.keyCode] = true;
		}
		
		
		/* 		
		PLAYERS		
		*/		
		
		public function fire(id:uint):void
		{
			trace('fire! player:', id);
		}
		
		public function addPlayer(d:Object):void
		{
			trace('\ntrying to add player...');
			for (var i:* in d)
			{
				trace('\t', i, ':', d[i]);
			}
			trace('\n');
			
			if (gameState == GAME_WAITING || gameState == GAME_COUNTDOWN)
			{
				++numPlayers;
				
				trace(numPlayers, 'players found. Need', minPlayers-numPlayers, 'more');
				if (numPlayers == minPlayers) startCountdown();
			}
		}
		
		public function reconnectPlayer(d:Object):void
		{
			trace('reconnected player', d.id);
			
		}
		
		public function removePlayer(d:Object):void
		{
			trace('removing player:', d.id);
			numPlayers = Math.max(0, numPlayers-1);
		}
		
		public function handledCustomObject(d:Object):void
		{
			trace("----------------\nCustom Data: ");
			for(var k:String in d) {
				
				trace("\t"+k+": " + d[k]);
			}
			trace("----------------");
		}
		
		protected function bubbleCustomEvent(e:CustomEvent):void
		{
			dispatchEvent(new CustomEvent(e.type, e.params));
		}		
		
		public function get gameState():String
		{
			return state;
		}
		
		public function set gameState(value:String):void
		{
			state = value;
			trace('\tgame state set to:', state);
		}
		
		override public function toString():String
		{
			return 'GameBaseNative ::';
		}
	}
}


