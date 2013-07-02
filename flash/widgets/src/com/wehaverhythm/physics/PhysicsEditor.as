package com.wehaverhythm.physics
{
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;

	public class PhysicsEditor
	{
		public function PhysicsEditor()
		{
		}
		
		public static function getNapeBody(data:String, bodyType:BodyType, mat = null):Body
		{
			var parts:Array = data.split("n");
			var b:Body = new Body(bodyType);
			
			for each(var polyStr:String in parts)
			{
				var polyData:Vector.<Vec2> = new Vector.<Vec2>();
				var points:Array = polyStr.split(",");
				//trace("DATA: " + points);
				
				for(var i:int = 0; i < points.length; i+=2)
					polyData.push(Vec2.get(int(points[i]),int(points[i+1])));
				
				//trace("POLY DATA: " + polyData);
				
				b.shapes.add(new Polygon(polyData, mat));
			}
			
			return b;
		}
	}
}