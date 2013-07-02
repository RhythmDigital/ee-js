package com.wehaverhythm.terry.grandprix
{
	import com.wehaverhythm.playnow.utils.PlayerManager;
	
	
	public class GrandPrixPlayerManager extends PlayerManager
	{
		private var playerData:Array;
		public var cars:Array;
		private var maxPlayers:int = 4;
		
		
		public function GrandPrixPlayerManager()
		{
			super();
		}
		
		public function init(playerData:Array, cars:Array):void
		{
			this.playerData = playerData;
			this.cars = cars;
		}	
		
		override public function addPlayer(d:Object):void
		{			
			if (numPlayers < maxPlayers)
			{
				super.addPlayer(d);
				
				// find colour by player name (is this right?)
				var col:uint;
				
				for each (var data:Array in playerData)
				{
					if (data[0] == d.name) 
					{
						col = data[1];
						break;
					}
				}
				
				var car:Car = cars[d.id];//getNextFreeCar();
				car.initWithPlayer(d, playerData[d.id][1]);
			}			
			else trace(this, 'cannot add player – max players reached!', '(' + numPlayers + ')');
		}
		/*
		private function getNextFreeCar():Car
		{
			var freeCar:Car;
			
			for each (var car:Car in cars)
			{
				if (isNaN(car.playerId))
				{
					freeCar = car;
					break;
				}
			}
			
			return freeCar;
		}
		*/
		override public function removePlayer(d:Object):void
		{			
			for each (var car:Car in cars)
			{
				if (car.playerId == d.id)
				{
					car.playerId = -1;
					break;
				}
			}
			
			super.removePlayer(d);
		}
		
		public function getCarByPlayerId(playerId:uint):Car
		{
			var playerCar:Car;
			
			for each (var car:Car in cars)
			{
				if (car.playerId == playerId)
				{
					playerCar = car;
					break;
				}
			}
			
			return playerCar;
		}
		
		override public function toString():String
		{
			return 'GrandPrixPlayerManager ::';
		}
	}
}