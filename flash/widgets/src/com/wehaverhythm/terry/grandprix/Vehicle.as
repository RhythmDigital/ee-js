package com.rocketmandevelopment.steering {
	import com.rocketmandevelopment.math.Vector2D;
	import flash.display.Sprite;
	
	public class Vehicle extends Sprite {
		private var _mass:Number;
		private var _position:Vector2D;
		private var _velocity:Vector2D;
		private var _maxForce:Number;
		private var _maxSpeed:Number;
		//sprite has rotation
		
		public function Vehicle(){
			_mass = 2;
			_position = new Vector2D(x,y);
			_velocity = new Vector2D();
			_maxForce = 2;
			_maxSpeed = 2;
		}
		
		/**
		* Updates the vehicle based on velocity
		*/
		public function update():void {
			// keep it witin its max speed
			_velocity.truncate(_maxSpeed);
			
			// move it
			_position = _position.add(_velocity);
			
			// keep it on screen
			if(stage) {
				if(position.x > stage.stageWidth) position.x = 0;
				if(position.x < 0) position.x = stage.stageWidth;
				if(position.y > stage.stageHeight) position.y = 0;
				if(position.y < 0) position.y = stage.stageHeight;
			}

			
			// set the x and y, using the super call to avoid this class's implementation
			super.x = position.x;
			super.y = position.y;
			
			// rotation = the velocity's angle converted to degrees
			rotation = _velocity.angle * 180 / Math.PI;
		}
		
		/**
		 * Gets and sets the vehicle's mass
		 */
		public function set mass(value:Number):void {
			_mass = value;
		}
		
		public function get mass():Number {
			return _mass;
		}
		
		/**
		 * Gets and sets the max speed of the vehicle
		 */
		public function set maxSpeed(value:Number):void {
			_maxSpeed = value;
		}
		
		public function get maxSpeed():Number {
			return _maxSpeed;
		}
		
		/**
		 *Gets and sets the position of the vehicle
		 */
		public function set position(value:Vector2D):void {
			_position = value;
			x = _position.x;
			y = _position.y;
		}
		
		public function get position():Vector2D {
			return _position;
		}
		
		/**
		 * Gets and sets the velocity of the vehicle
		 */
		public function set velocity(value:Vector2D):void {
			_velocity = value;
		}
		
		public function get velocity():Vector2D {
			return _velocity;
		}
		
		/**
		 * Override of the sprite set x function
		 */
		override public function set x(value:Number):void {
			super.x = value;
			_position.x = x;
		}
		
		/**
		 * Override of the sprite set y function
		 */
		override public function set y(value:Number):void {
			super.y = value;
			_position.y = y;
		}
		
	}
}