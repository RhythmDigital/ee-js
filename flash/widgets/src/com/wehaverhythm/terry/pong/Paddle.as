package com.wehaverhythm.terry.pong
{
	import com.wehaverhythm.terry.pong.PongUser;
	
	import starling.display.Quad;
	

	public class Paddle
	{
		//	public var userID:int;
		public var teamNum:int;
		public var user:PongUser;

		public var pad:Quad;
		public var colour:Object;
		
		
		public function Paddle(user:PongUser)
		{
			//	this.userID = userID;
			this.user = user;
		}
		
		public function makePaddleShape(w:Number, h:Number):void
		{
			pad = new Quad(w, h, 0xffffff);
			this.user.paddle = pad;
		}
		
		public function updatePaddleHeight(h:Number):void
		{
			pad.height = h;
		}
	}
}