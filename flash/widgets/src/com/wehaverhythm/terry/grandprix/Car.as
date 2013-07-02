package com.wehaverhythm.terry.grandprix 
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	
	public class Car extends Sprite 
	{
		// timeline
		public var body:Sprite;
		public var wheels:Wheels;
		public var notConnected:MovieClip;
		
		// const
		public static const PLACE_UNDER_BRIDGE:String = 'PLACE_UNDER_BRIDGE';
		public static const PLACE_OVER_BRIDGE:String = 'PLACE_OVER_BRIDGE';
		public static const LAP_COMPLETE:String = 'LAP_COMPLETE';
		
		// class
		private var mass:Number;
		private var positionVector:Vector2D;
		private var velocityVector:Vector2D;
		public var maxSpeed:Number;
		
		public var pathIndex:int;
		private var path:Array;
		public var pushing:Boolean;
		
		public var playerId:int;
		public var carId:int;
		public var racing:Boolean;
		public var move:Boolean;
		public var active:Boolean;
		
		private var lapStartTime:int;
		public var lapTimes:Array;
		private var winPath:Array;
		private var winMargin:int;
		private var won:Boolean;
		
		private var initValues:Object;
				
		
		public function Car()
		{
			winMargin = 50;
		}
		
		public function init(carId:int, path:Array, xPos:Number, yPos:Number, scale:Number, maxSpeed:Number=7):void
		{
			this.carId = carId;
			this.path = path;
			
			initValues = {path:path, x:xPos, y:yPos, scale:scale, maxSpeed:maxSpeed};	
			reset();
		}
		
		public function reset():void
		{
			mass = 3;
			velocityVector = new Vector2D();
			pathIndex = 0;
			winPath = null;
			lapTimes = [];
			
			racing = false;
			active = false;
			positionVector = new Vector2D();
			this.maxSpeed = initValues.maxSpeed;
			
			path = initValues.path;
			x = initValues.x;
			y = initValues.y;
			scaleX = scaleY = initValues.scale;	
			
			trace(this, 'x:', x, 'y:', y);
			
			playerId = -1;
			wheels.init();
			
			move = won = false;
			
			if (parent) parent.removeChild(this);
		}
		
		public function initForRace(resetMaxSpeed:Boolean, path:Array=null, maxSpeed:Number=0):void
		{
			if (path) this.path = path;
			resetMaxSpeed ? this.maxSpeed = 6 : this.maxSpeed = maxSpeed;
			
			mass = 5;
			pathIndex = 0;
			velocityVector.length = wheels.speed = 0;
			racing = true;
			move = won = false;
			
			trace(this, 'starting at maxSpeed:', maxSpeed);
		}
		
		public function initWithPlayer(d:Object, col:uint):void
		{
			TweenMax.to(body, 0, {tint:col});
			playerId = int(d.id);
			active = true;
		}
		
		public function update():void
		{
			if (move)
			{
				followPath();
				
				// keep it within its max speed
				if (!pushing) velocityVector.multiply(.98);
				velocityVector.truncate(maxSpeed);
				
				// wheels
				wheels.speed = velocityVector.length;
				
				// move it
				positionVector = positionVector.add(velocityVector);
				
				// set the x and y, using the super call to avoid this class's implementation
				super.x = position.x;
				super.y = position.y;
				
				// rotation = the velocity's angle converted to degrees
				if (Math.abs(velocityVector.length) > .00001) rotation = velocityVector.angle * 180 / Math.PI;
				notConnected.rotation = -rotation;
			}
			
			if (won) push(5);
		}
		
		public function push(length:Number=.5):void
		{
			if (move)
			{
				pushing = true;
				
				velocityVector.length += length; 		
				
				TweenMax.killDelayedCallsTo(resetPushing);
				TweenMax.delayedCall(.3, resetPushing);
			}
		}
		
		private function resetPushing():void
		{
			pushing = false;
		}
		
		public function startTimingLap():void
		{
			var d:Date = new Date();
			lapStartTime = d.time;
		}
		
		public function wins():void
		{
			TweenMax.to(this, .5, {delay:.3, scaleX:1.3, scaleY:1.3, ease:Sine.easeOut});
			
			winPath = [];
			
			for (var i:int=0; i<200; ++i)
			{
				winPath.push(new Vector2D(-winMargin/2 + Math.random()*(1280+winMargin), -winMargin/2 + Math.random()*(720+winMargin)));
			}
			
			path = winPath;
			pathIndex = 0;
			maxSpeed = 30;
			// mass = 5;
			
			won = true;
		}
		
		public function followPath():void
		{
			if (pathIndex >= path.length) //if you have finished with the path
			{
				pathIndex = 0;
				
				if (racing) 
				{
					var newTime:int = new Date().time;
					var lapTime:Number = (newTime - lapStartTime)/1000;
					lapTimes.push(lapTime);
					startTimingLap();
					
					dispatchEvent(new CustomEvent(Car.LAP_COMPLETE, {lapTime:lapTime}));
					
					trace(this, 'lap', lapTimes.length, 'completed:', lapTime);
				}
			} 	
			
			var waypoint:Vector2D = path[pathIndex]; //get the current waypoint
			var dist:Number = waypoint.distance(positionVector); //get the distance from the waypoint
			
			if (dist < (won ? 60 : 10)) // if you are within SOME pixels of the waypoint
			{
				if (won) maxSpeed = 10 + Math.random()*20;
				++pathIndex; // go to the next waypoint				
				return; // quit for now
			}
			
			seek(waypoint.cloneVector());  // otherwise, seek the current waypoint
		}
		
		public function seek(target:Vector2D):void
		{
			// subtract the position from the target to get the vector from the vehicle's position to the target. 
			// Normalize it then multiply by max speed to get the maximum velocity from your position to the target.
			var desiredVelocity:Vector2D = target.subtract(position).normalize().multiply(velocityVector.length); 
			
			// subtract velocity from the desired velocity to get the force vector
			var steeringForce:Vector2D = desiredVelocity.subtract(velocityVector); 
			
			//divide the steeringForce by the mass(which makes it the acceleration), then add it to velocity to get the new velocity
			velocityVector.add(steeringForce.divide(mass));			
		}
		
		public function set position(value:Vector2D):void
		{
			positionVector = value;
			x = positionVector.x;
			y = positionVector.y;
		}
		
		public function get position():Vector2D
		{
			return positionVector;
		}
		
		override public function set x(value:Number):void
		{
			super.x = value;
			positionVector.x = x;
		}
		
		override public function set y(value:Number):void
		{
			super.y = value;
			positionVector.y = y;
		}
		
		public function showConnected(connected:Boolean):void
		{
			notConnected.visible = !connected;
		}
		
		override public function toString():String
		{
			return 'Car ' + carId + ' ( playerId: ' + playerId + ' ) ::';
		}
	}
}

