package com.wehaverhythm.utils
{	
	import flash.events.Event;
	
	
	
	/**
	 *	CustomEvent
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9
	 *	@author Adam Palmer (www.palmerama.tv)
	 */
	
	
	public class CustomEvent extends Event 
	{		
		public var params:Object;
		
				
		public function CustomEvent(type:String, params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.params =  params;
			

		}		
	}
}