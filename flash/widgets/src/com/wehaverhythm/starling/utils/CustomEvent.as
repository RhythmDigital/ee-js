package com.wehaverhythm.starling.utils
{
	import starling.events.Event;
	
	public class CustomEvent extends Event
	{
		public function CustomEvent(type:String, bubbles:Boolean=false, data:Object=null)
		{
			super(type, bubbles, data);
		}
	}
}