package
{
	import com.adobe.serialization.json.JSON;
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	import com.theflashblog.drawing.Wedge;
	import com.wehaverhythm.utils.Maths;
	import com.wehaverhythm.utils.Trig;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	[SWF (frameRate="60", width="40", height="40")]
	public class FilterCounter extends Sprite
	{
		private var view:FilterCounterDisplay;
		public var value:int = 150;
		private var maxValue:int = 0;
		private var angle:int;
		
		public function FilterCounter()
		{
			super();
			
			stage.align="TL";
			stage.scaleMode = "noScale";
			
			view = new FilterCounterDisplay();
			//view.x = 110;
			//view.y = 110;
			addChild(view);
			
			view.wedge.rotation = -90;
			value = 0;
			
			updateValue(0, true);
			
			if(ExternalInterface.available) {
				ExternalInterface.addCallback("init", init);
				ExternalInterface.addCallback("updateValue", updateValueFromJS);
				trace("CALL FLASH READY");
				ExternalInterface.call("flashReady", this.loaderInfo.parameters.flashID);
			} else {
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseClick);
				
				var params:Object = {
						initialValue:0
					,	maxValue:350
					,	initialDelay:0.5
				};
				
				init(params);
				
			}
			
		}
		
		protected function onMouseClick(e:MouseEvent):void
		{
			updateValue(Math.random()*maxValue);
		}
		
		public function init(params:Object):void
		{	
			this.maxValue = params.maxValue;
			updateValue(0, true);
			
			TweenMax.delayedCall(params.initialDelay, updateValue, [params.initialValue]);
		}
		
		public function updateValueFromJS(v:String):void
		{
			updateValue(int(v), false);
		}
		
		public function updateValue(value:int, immediate:Boolean = false):void
		{
			trace("Animate to: " + value);
			TweenMax.killDelayedCallsTo(updateValue);
			animate = false;
			//
			
			if(!immediate) {
				animate = true;
				TweenMax.to(this, 0.4, {value:value, ease:Sine.easeOut, overwrite:2, onUpdate:setValue, onComplete:stopAnimation});
			} else {
				this.value = value;
			}
			angle = Maths.map(value, 0, maxValue, 0, 360);
			setValue();
		}
		
		private function setValue():void
		{
			
			view.txtNumber.text = String(Math.ceil(value));
			
		}
		
		private function stopAnimation():void
		{
			animate = false;
		}
		
		private function drawWedge():void
		{
			view.wedge.graphics.clear();
			view.wedge.graphics.beginFill(0x009C9C, 1);
			Wedge.draw(view.wedge, 0, 0, 20, angle, 0);
			view.wedge.graphics.endFill();
		}
		
		public function set animate(run:Boolean):void
		{
			if(run) {
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			} else {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		protected function onEnterFrame(e:Event):void
		{
			angle = Maths.map(value, 0, maxValue, 0, 360);
			drawWedge();
		}
	}
}