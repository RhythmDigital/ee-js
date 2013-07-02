package com.wehaverhythm.terry.voter
{
	import flash.display.Sprite;
	
	
	public class ScalesBar extends Sprite
	{
		// timeline
		public var marker0:Sprite;
		public var marker1:Sprite;
		
		
		public function ScalesBar()
		{
			super();
			marker0.visible = marker1.visible = false;
		}
	}
}