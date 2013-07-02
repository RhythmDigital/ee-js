package com.wehaverhythm.terry.pong
{
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;

	public class PongSFX
	{
		/* BOOM */
		[Embed(source="/assets/pong/sfx/boom1.mp3")]
		public static const BOOM_1:Class;
		
		[Embed(source="/assets/pong/sfx/boom2.mp3")]
		public static const BOOM_2:Class;
		
		[Embed(source="/assets/pong/sfx/boom3.mp3")]
		public static const BOOM_3:Class;
		
		[Embed(source="/assets/pong/sfx/boom4.mp3")]
		public static const BOOM_4:Class;
		
		/* PING */
		[Embed(source="/assets/pong/sfx/ping.mp3")]
		public static const PING:Class;
		
		[Embed(source="/assets/pong/sfx/ping1.mp3")]
		public static const PING_1:Class;
		
		[Embed(source="/assets/pong/sfx/ping2.mp3")]
		public static const PING_2:Class;
		
		[Embed(source="/assets/pong/sfx/ping3.mp3")]
		public static const PING_3:Class;
		
		[Embed(source="/assets/pong/sfx/ping4.mp3")]
		public static const PING_4:Class;
		
		[Embed(source="/assets/pong/sfx/ping5.mp3")]
		public static const PING_5:Class;
		
		[Embed(source="/assets/pong/sfx/ping6.mp3")]
		public static const PING_6:Class;
		
		//1up
		[Embed(source="/assets/pong/sfx/newPlayer.mp3")]
		public static const NEW_PLAYER:Class;
		
		public static var sounds:Dictionary;
		public static var channels:Dictionary;
		
		public function PongSFX()
		{
		}
		
		public static function init():void
		{
			sounds = new Dictionary(false);
			channels = new Dictionary(false);
			
			var soundClasses:Array = ["BOOM_1", "BOOM_2", "BOOM_3", "BOOM_4", "PING", "PING_1", "PING_2", "PING_3", "PING_4", "PING_5", "PING_6", "NEW_PLAYER"];
			
			for each(var snd:String in soundClasses) {
				sounds[snd] = new PongSFX[snd]();
			}
		}
				
		public static function play(name:String, vol:Number = 0.8):void
		{
			channels[name] = Sound(sounds[name]).play(0, 0, new SoundTransform(vol));
		}
	}
}