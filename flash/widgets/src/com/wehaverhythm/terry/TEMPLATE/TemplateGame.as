package com.wehaverhythm.terry.TEMPLATE
{
	import com.wehaverhythm.terry.generic.GameBaseNative;
	import com.wehaverhythm.terry.generic.GameCountDown;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.events.Event;
	
	import starling.events.Event;
	
	
	public class TemplateGame extends GameBaseNative
	{				
		
		public function TemplateGame()
		{
			super();
			
			minPlayers = 1;
			countDownFrom = 5;
		}
		
		override protected function onStarlingReady(e:starling.events.Event):void
		{
			super.onStarlingReady(e);
			
			// INIT STUFF HERE
			
			addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
		}
		
		override protected function startCountdown():void
		{
			countdown.addEventListener(GameCountDown.SET_TIME, onSetCountDown);
			super.startCountdown();
		}
		
		private function onSetCountDown(event:CustomEvent):void
		{
			// show countdown somewhere
		}
		
		override public function resetGame():void
		{
			super.resetGame();
			
			// show waitscreen?
		}
		
		override protected function startGame():void
		{			
			super.startGame();
			
			trace(this, 'START GAME with', numPlayers, 'players');
		}
		
		private function onRaceCountDownComplete(event:flash.events.Event):void
		{
			
		}
		
		override protected function endGame(winnerId:uint):void
		{
			super.endGame(winnerId);
			
			// DO GAME END SEQUENCE, then waitForPlayers();
		}
		
		protected function onEnterFrame(event:flash.events.Event):void
		{
			
		}
		
		override public function addPlayer(d:Object):void
		{
			super.addPlayer(d);	
			
			if (gameState == GAME_WAITING || gameState == GAME_COUNTDOWN || gameState == GAME_ACTIVE)
			{			
				// add player to player manager?
			}
		}
		
		override public function reconnectPlayer(d:Object):void
		{
			// 
		}
		
		
		override public function removePlayer(d:Object):void
		{
			
		}
		
		override public function fire(id:uint):void
		{
			
		}
		
	}
}
