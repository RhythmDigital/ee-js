package com.wehaverhythm.utils
{	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;


	/**
	 *	TextTyper - types text out
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Adam Palmer
	 *	@since  26.01.2011
	 */

	public class TextTyper extends Sprite
	{			
		//--------------------------------------
		//  VARIABLES
		//--------------------------------------
		
		private var xml:XML;
		private var text:String;
		private var textField:TextField;
		private var tempTextField:TextField;
		private var maxWidth:int;
		private var counter:int;
		private var lastSpace:int;
		private var timer:Timer;
		
				
		public function TextTyper():void
		{
			
		}
		
		public function reset():void
		{
			if (textField != null) {
				textField.text = "";
			}
		}
		
		public  function typeText(text:String, textField:TextField, maxWidth:int, interval:int):void
		{			
			this.text = text;
			this.textField = textField;
			this.maxWidth = maxWidth;
			counter = 0;
			lastSpace = 0;
			
			reset();
			
			// start loop
			timer = new Timer(interval);
			timer.addEventListener(TimerEvent.TIMER, onTimerTick,false, 0, true);
			timer.start();
		}
		
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		private function onTimerTick(e:TimerEvent):void
		{
			if(counter<text.length)
			{
				// get next character
				var c:String = text.substring(counter, counter+1);
				
				// find whole word
				var word:String = c;
				
				for (var i:int=counter+1; i < text.length; i++) 
				{
					word = text.substring(lastSpace, i);
					if (word.indexOf(" ") > -1) 
					{
						lastSpace = i;
						break;
					}
				}
				
				// check word will fit on line
				
				//trace(word)
				
				// type it out
				textField.appendText(c);
				
				// advance
				++counter;
			}else{
				timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
				timer.stop();
			}
		}
		

	}
}