package com.wehaverhythm.terry.rockrace
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Expo;
	import com.wehaverhythm.playnow.utils.TeamManager;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.Material;
	import nape.shape.Shape;
	
	import starling.display.Sprite;
	
	public class RockTeams extends TeamManager
	{
		private const PLAYER_WIDTH:int = 35;
		private const PLAYER_HEIGHT:int = 30;
		private const teamColours:Array = [0xff0000, 0x00ff00];
		
		private var rocks:Array;
		private var lastPlayersAdded:Array;
		private var physicsPeople:Array;
		private var groundY:int;
		private var parent:Sprite;
		private var playerTextures:Array;
		private var defaultRockPhysics:Material;
		private var defaultRockMass:Number;
		private var collisionTypes:Object;
		
		private var dummyID:int = 0;
		
		public function RockTeams(rockLeft:Rock, rockRight:Rock, groundY:Number, parent:Sprite, playerTextures:Array, collisionTypes:Object)
		{
			super();
			
			this.groundY = groundY;	
			this.parent = parent;
			this.playerTextures = playerTextures;
			rocks = [rockLeft, rockRight];
			this.defaultRockPhysics = rockLeft.body.shapes.at(0).material;
			this.defaultRockMass = rockLeft.body.mass;
			this.collisionTypes = collisionTypes;
			
			lastPlayersAdded = [null, null];
			physicsPeople = [[],[]];
		}
		
		public function addDummyPlayer(team:int):void
		{
			trace("adding dummy player to team " + team);
			addPlayer({id:String(dummyID++), tid:team}, team);
		}
		
		public function removeDummyPlayer(team:int):void
		{
			if(!teams[team] || !teams[team].length) return;
			var randomID:int = Math.floor(Math.random()*teams[team].length);
			var playerID:String = teams[team][randomID].id;
			trace("removing dummy player ("+playerID+") from team " + team);
			removePlayer(teams[team][randomID]);
		}
		
		override public function addPlayer(data:Object, team:int):void
		{
			super.addPlayer(data, team);
			addPhysicsPlayer(team);
		}
		
		override public function removePlayer(data:Object, ignoreEvent:Boolean = false):void
		{
			trace(data.tid);
			removePhysicsPlayer(data.tid);
			super.removePlayer(data, ignoreEvent);
		}
		
		override public function removePlayerById(id:String, ignoreEvent:Boolean = false):void
		{
			throw(new Error("DON'T USE THIS! It breaks the app, mind you - so does this error. But at least you know why it's broken."));
			//removePhysicsPlayer(team);
			//super.removePlayerById(id);
		}
		
		public function makeLightweight(team:int, mass:Number = 0):void
		{
			var r:Rock = Rock(rocks[team]);
			var m:Material = new Material(3,0.2,0.2,.8,0.0003);
			
			// MAKE TEAM LIGHT AND SLIPPY
			for each(var p:Player in physicsPeople[team]) {
				p.body.mass = mass;
				p.body.shapes.foreach(function(s:Shape):void{
					s.material = m;
				});
			}
			
			// MAKE ROCK LIGHT AND SLIPPY
			/*
			r.body.mass = mass;
			r.body.shapes.foreach(function(s:Shape):void{
				s.material = m;
			});*/
		}
		
		override public function reset():void
		{
			super.reset();
			
			// RESET ROCK PHYSICS SETTINGS
			for each(var r:Rock in rocks) {
				r.body.mass = defaultRockMass;
				r.body.shapes.foreach(function(s:Shape):void{
					s.material = defaultRockPhysics;
				});
			}
		}
		
		/**
		 * PHYSICS STUFF
		 */
		private function addPhysicsPlayer(team:int):void
		{
			var posX:int = team == 0 ? (rocks[team].body.position.x - (rocks[team].width)) : (rocks[team].body.position.x + (rocks[team].width)) - PLAYER_WIDTH;
			
			if(lastPlayersAdded[team]) {
				
				if(team == 0) posX = lastPlayersAdded[team].x - (PLAYER_WIDTH*1.6);
				else posX = lastPlayersAdded[team].x + (PLAYER_WIDTH*.6);
			}
			
			lastPlayersAdded[team] = new Player(playerTextures[team], PLAYER_WIDTH, PLAYER_HEIGHT, teamColours[team], new Vec2(posX, groundY), team, rocks[team].body.space, lastPlayersAdded[team], groundY);
			physicsPeople[team].unshift(lastPlayersAdded[team]);// position by last person.
			
			lastPlayersAdded[team].body.position.y = 0; // force body Y to zero for animating in.
		//	TweenMax.to(lastPlayersAdded[team].body.position, .6, {y:groundY, overwrite:2, ease:Bounce.easeOut});
			
			Body(lastPlayersAdded[team].body).cbTypes.add(collisionTypes["p"+team]);
			
			parent.addChild(lastPlayersAdded[team]);
		}
		
		private function removePhysicsPlayer(team:int):void
		{
			trace("removeing player from " + team);
			var p:Player = physicsPeople[team].shift();
			if(p) {
				TweenMax.killTweensOf(p.body.position);
				p.destroy();
				TweenMax.to(p, .2, {y:-100, ease:Expo.easeIn, overwrite:2});
			}
			
			lastPlayersAdded[team] = physicsPeople[team].length ? physicsPeople[team][0] : null;
		}
		
		public function moveTeam(team:Number, moveDist:Number = 5):void
		{
			var teamPlayers:Array = physicsPeople[team];
			var i:int;	
			var p:Player;
			
			moveDist /= teamPlayers.length;
			trace(team + " >> " + moveDist);
			if(!teamPlayers.length) {
				trace("Can't move, no players on team " + team);
				return;
			}
			
			// move players
			for(i = teamPlayers.length; i > 0; --i) {
				p = teamPlayers[i-1];
				trace("< p targ: " +p.targetX);
				team == 0 ? p.targetX = p.body.position.x + moveDist : p.targetX = p.body.position.x - moveDist; // move target left or right by speed, depending on team.
				trace("> p targ: " +p.targetX);
				// Tween the player body
				TweenMax.to(p.body.position, .7, {delay:(i-1)*0.01, x:p.targetX, ease:com.greensock.easing.Elastic.easeOut, overwrite:2});
			}
		}
		
		public function destroyTeamJoints(players:Array):void
		{
			for each(var p:Player in players) {
				p.destroyJoints();
			}
		}
		
		public function getPhysicsPeople(teamID:int):Array
		{
			return physicsPeople[teamID];
		}
	}
}