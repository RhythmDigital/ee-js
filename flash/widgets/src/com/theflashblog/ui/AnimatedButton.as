package
{
	// Import Flash classes
	import flash.display.*;
	import flash.events.*;

	public class AnimatedButton extends MovieClip
	{
		public function AnimatedButton():void
		{
			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		private function onOver(e:MouseEvent):void
		{
			gotoAndPlay("over");
		}
		
		private function onOut(e:MouseEvent):void
		{
			gotoAndPlay("out");
		}
	}
}

