package com.wehaverhythm.twitter
{
	import flash.display.Bitmap;
	import flash.events.Event;
	
	public class ProfilePictureEvent extends Event
	{
		public static const GOT_PROFILE_PICTURE:String = "GOT_PROFILE_PICTURE";
		public static const ERROR:String = "PROFILE_PICTURE_ERROR";
		
		public var screenName:String;
		public var bmp:Bitmap;
		
		public function ProfilePictureEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, screenName:String="", bmp:Bitmap = null)
		{
			this.screenName = screenName;
			this.bmp = bmp;
			super(type, bubbles, cancelable);
		}
		
		override public function toString():String
		{
			return "ProfilePictureEvent :: " + this.screenName;
		}
	}
}