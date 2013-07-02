package com.wehaverhythm.terry.rockrace
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.wehaverhythm.utils.Trig;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Shape;
	import nape.space.Space;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	public class Rock extends Sprite
	{
		public var body:Body;
		private var space:Space;
		private var pos:Vec2;
		
		public function Rock(texture:Texture, body:Body, pos:Vec2, space:Space)
		{
			var img:Image = new Image(texture);
			
			// set pivot central
			img.pivotX = img.width >> 1;
			img.pivotY = img.height >> 1;
			addChild(img);
			
			var rock:Body = body;
			rock.setShapeMaterials(new Material(0, 3.9, 4, 1,0.2));
			rock.shapes.foreach(setCollision);
			rock.position = pos;
			
			this.body = rock;
			//this.body.align();
			this.space = space;
			this.pos = pos;
			this.body.mass = 1;//.3;
			
			// add circle as default shape.
			if(!rock.shapes.length) rock.shapes.add(new Circle(img.width>>1, null, null));// new Material(20,1,2,1,0.0010), null));
			//rock.space = space;
			rock.userData.graphic = this;
			
			// inflate the hit test rect of the rock to it hits a player.
			// this.bounds.inflate(6,6);
			
			active = true;
		}
		
		private function setCollision(s:Shape):void
		{
		//	trace("altering shape collision");
			//s.filter.collisionGroup = 2;
			//s.filter.collisionMask = 1;
			/*s.sensorEnabled = true;
			s.filter.sensorGroup = 2;
			s.filter.sensorMask = -1;*/
		}
		
		public function shrinkAndDie(delay:Number=0):void
		{					
			TweenMax.to(this, .01 + Math.random()*.2, {delay:delay, scaleX:0, scaleY:0, ease:Bounce.easeIn, onComplete:remove, onStart:destroyBody});			
		}
		
		public function remove():void
		{
			if (this.parent) this.parent.removeChild(this);
		}
		
		public function destroyBody():void
		{
			detachBody();
			body.space = null;
			body = null;
		}
		
		public function resetRocks():void
		{
			this.body.position = pos;
			this.body.rotation = Trig.getRadians(0);
			this.body.torque = 0;
			this.body.angularVel = 0;
			this.body.velocity = new Vec2(0,0);
			this.body.force = new Vec2(0,0);
		}
		
		public function set active(state:Boolean):void {
			if(state) this.body.space = this.space;
			else this.body.space = null;
		}
		
		public function attachBody():void
		{
			body.userData.graphic = this; 
		}
		
		public function detachBody():void
		{
			body.userData.graphic = null; 
		}
	}
}