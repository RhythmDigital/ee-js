package
{
	import com.adobe.serialization.json.JSON;
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	import com.theflashblog.drawing.Wedge;
	import com.wehaverhythm.utils.ArrayUtils;
	import com.wehaverhythm.utils.Maths;
	import com.wehaverhythm.utils.Trig;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	
	[SWF (frameRate="60", width="822", height="218", backgroundColor="#ffe500")]
	public class BookingVisualiser extends Sprite
	{
		private var params:Object;
		private var circleColour:uint = 0x6d6e71;
		private var circleRadius:Number = 9;
		private var circleDiameter:Number = circleRadius*2;
		private var ctxWidth:int = 882;
		private var ctxHeight:int = 218;
		private var margX:Number = 3.13;
		private var margY:Number = 4.1;
		private var cols:int = 40;
		private var rows:int = 10;
		private var circleCount:int = 400;
		private var circles:Array;
		
		public function BookingVisualiser()
		{
			super();
			
			if(ExternalInterface.available) {
				ExternalInterface.addCallback("init", init);
				ExternalInterface.call("flashReady");
				
			} else {
				
				var params:Object = {
					   remainingSeats: 100
					,   initialDelay: 1
					,   animateSeatsInTime: 1.5
					,   animateSeatsOutMaxTime: 4
				};
				
				init(JSON.encode(params));
				
			}
		}
		
		public function init(params:Object):void
		{
			trace("INIT CALLED.");
			trace(params);
			
			for(var k:String in params) {
				trace(k+": " + params[k]);
			}
			this.params = params;
			
			makeCircles(circleCount);
			animate();
		}
		
		private function makeCircles(count:int):void
		{
			this.circles = new Array();
			
			var next:VisCircle;
			var c:int = 0;
			var r:int = 0;
			var zero:Point = new Point(0,0);
			var i:int=0;
			
			var nextY:Number = circleRadius;
			var nextX:Number = 0;
			
			for(r = 0; r < rows; ++r) {
				nextX = circleRadius;
				for(c = 0; c < cols; ++c) {
					next = new VisCircle(Trig.getDistance(zero, new Point(nextX,nextY))/ctxWidth, circleColour, circleRadius);
					next.x = nextX;
					next.y = nextY;
					circles.push(next);
					circles[i].scale = 0;
					nextX += (circleDiameter+margX);
					addChild(next);
					++i;
				}
				nextY += (circleDiameter+margY);
			}
		}
		
		public function animate():void
		{
			
			var maxCircleDelay:Number = (params.animateSeatsInTime / circleCount);
			var tweenTime:Number = 0.4;
			var nextDelay:Number = params.initialDelay;
			var totalTime:Number = 0;
			var pauseBeforeCountdown:Number = 0.3;
			var i:int = 0;
			
			for(i = 0; i < circleCount; ++i) {
				nextDelay = params.initialDelay+(0.2+circles[i].dist*params.animateSeatsInTime);//*this.animateSeatsInTime
				TweenMax.to(this.circles[i], tweenTime, {delay:nextDelay, scale:1, ease:Sine.easeOut, overwrite:2});
				totalTime = Math.max(totalTime, tweenTime+nextDelay);
			}
			
			TweenMax.delayedCall(totalTime+pauseBeforeCountdown, showRemaining);
		}
		
		public function showRemaining():void {
			
			var items:Array = ArrayUtils.arrayGetRandom(circleCount-params.remainingSeats, circles);
			var delay:Number = 0.04;
			var totalTime:Number = 0;
			var tweenTime:Number = 0.4;
			var i:int = 0;
			
			for(i = 0; i < items.length; ++i) {
				totalTime+=delay*i;
			}
			
			if(totalTime > params.animateSeatsOutMaxTime) {
				delay = params.animateSeatsOutMaxTime / items.length;
				totalTime = params.animateSeatsOutMaxTime;
			}
			
			for(i = 0; i < items.length; ++i) {
				TweenMax.to(items[i], tweenTime, {scale:0.2, delay:delay*i, ease:Sine.easeOut, overwrite:2});
			}
		};
	}
}