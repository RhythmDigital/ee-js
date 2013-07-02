package com.wehaverhythm.terry.rockrace
{
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class Player extends Sprite
	{
		private var img:Image;
		public var body:Body;
		public var targetX:Number = 0;
		private var pin:PivotJoint;
		
		public function Player(texture:Texture, width:Number, height:Number, col:uint, pos:Vec2, team:int, space:Space, joinTo:Player = null, jointY:int = -1)
		{
			super();
			
			if(jointY == -1) jointY = pos.y;
			
			img = new Image(texture);
			addChild(img);
			//img.scaleY = 2;
			//addChild(new Quad(width,height,col));
			img.x = (width >> 1)-(img.width>>1);
			
			pivotX = width>>1;
			pivotY = height>>1;
			
			body = new Body(BodyType.DYNAMIC, pos);
			body.allowRotation = false;
			body.shapes.add(new Polygon(Polygon.rect(0,0,width,height), new Material(0.2)));
			body.space = space;
			body.userData.graphic = this;
			body.isBullet = true;
			body.mass = 1;
			body.align();
			
			targetX = pos.x;
			
			if(joinTo != null) {
			//	trace("make joint between " + joinTo + " and  " + joinTo); 
				
				/*var pivotPoint:Vec2 = new Vec2();
				pivotPoint.x = joinTo.body.position.x;// + (joinTo.body.position.x - body.position.x);
				pivotPoint.y = jointY;//body.position.y + 0;//height >> 1;
				
				trace(pivotPoint);
				*/
				/*
				var pivotPoint:Vec2 = Vec2.get(x(cellWidth/2),y(cellHeight/2));
				format(new PivotJoint(
					b1, b2,
					b1.worldPointToLocal(pivotPoint, true),
					b2.worldPointToLocal(pivotPoint, true)
				));
				*/
				
				var tempBodyAY:int = body.position.y;
				var tempBodyBY:int = joinTo.body.position.y;
				
				body.position.y = jointY;
				joinTo.body.position.y = jointY;
				
				pin = new PivotJoint(
					body, joinTo.body,
					body.worldPointToLocal(body.worldCOM, true),
					joinTo.body.worldPointToLocal(joinTo.body.worldCOM, true)
				);
				
				pin.stiff = false;
				pin.damping = 0.1;
				pin.frequency = 0.1;
				pin.space = space;
				
				body.position.y = tempBodyAY;
				joinTo.body.position.y = tempBodyBY;
			}
			
			//this.bounds.inflate(2,2);
			
			targetX = pos.x;
			
		}
		
		public function destroy():void
		{
			destroyJoints();
			body.space.bodies.remove(body);
			body = null;
		}
		
		public function destroyJoints():void
		{
			while(!body.constraints.empty()) body.constraints.at(0).space = null;
		}
		
		/*
		
		withCell(1, 0, "PivotJoint", function (x:Function, y:Function):void {
		var b1:Body = box(x(1*cellWidth/3),y(cellHeight/2),size);
		var b2:Body = box(x(2*cellWidth/3),y(cellHeight/2),size);
		
		var pivotPoint:Vec2 = Vec2.get(x(cellWidth/2),y(cellHeight/2));
		format(new PivotJoint(
		b1, b2,
		b1.worldPointToLocal(pivotPoint, true),
		b2.worldPointToLocal(pivotPoint, true)
		));
		pivotPoint.dispose();
		});*/
		
	}
}