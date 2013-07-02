package
{
	import flash.display.Sprite;
	
	public class VisCircle extends Sprite
	{
		public var dist:Number;
		private var colour:uint;
		
		public function VisCircle(dist:Number, colour:uint, radius:Number)
		{
			this.dist = dist;
			
			graphics.beginFill(colour, 1);
			graphics.drawCircle(0,0,radius);
			graphics.endFill();
			
			super();
		}
		
		public function set scale(s:Number):void
		{
			scaleX = scaleY = s;
		}
		
		public function get scale():Number
		{
			return scaleX;
		}
	}
}