(function(){

    var namespace = MAIN.namespace('widgets');
    var circleRadius = 9.5;
    var circleDiameter = circleRadius*2;
    var ctxWidth = 882;
    var ctxHeight = 218;
    var margX = 3.12;
    var margY = 3.12;
    var cols = 40;
    var rows = 10;
    var circleColour = "#6d6e71";

    var circleCount = cols*rows;

    if (namespace.BookingVisualiser === undefined) 
	{
        namespace.BookingVisualiser = function()
		{	
		};

		var p = namespace.BookingVisualiser.prototype;
		p.params = null;
		p.canvas = null;
		p.context = null;
		p.counter = null;
		p.animationID = null;
		p.circles = null;
		p.total = null;
		p.remainingSeats = null;
		p.seatCounter = null;
		p.bookedSeats = null;
		p.animateSeatsInTime = null;
		p.animateSeatsOutMaxTime = null;
		p.initialDelay = null;

		p.init = function(params) {

			this.params = params;
			this.canvas = params.canvas[0];	// main canvas
			this.context = this.canvas.getContext('2d');
			this.counter = params.counter;	// the counter!
			this.total = params.totalSeats; // total number of seats available.
			this.remainingSeats = params.remainingSeats; // calculate number of booked seats
			this.bookedSeats = this.total - this.remainingSeats;
			this.context.width = ctxWidth;
			this.context.height = ctxHeight;
			this.seatCounter = 0;
			this.animateSeatsInTime = params.animateSeatsInTime;
			this.animateSeatsOutMaxTime = params.animateSeatsOutMaxTime;
			this.initialDelay = params.initialDelay;

			this.counter.text(this.seatCounter);
			this.makeCircles(circleCount);
			this.enterFrame();
			this.animate();
		};

		p.makeCircles = function(count) {

			this.circles = [];

			var next = null;
			var c = 0;
			var r = 0;
			var zero = {x:0, y:0};
			var i=0;

			nextY = circleRadius;

			for(r = 0; r < rows; ++r) {
				nextX = circleRadius;
				for(c = 0; c < cols; ++c) {
					next = new namespace.BasicCircle();
					next.init(nextX, nextY, circleRadius, circleColour, RHYTHM.Trig.getDistance(zero, {x:nextX,y:nextY})/ctxWidth); // x, y, radius, color
					this.circles.push(next);
					this.circles[i].scale = 0;
					nextX += (circleDiameter+margX);
					++i;
				}
				nextY += (circleDiameter+margY);
			}

		};

		p.animate = function() {
			
			var maxCircleDelay = (this.animateSeatsInTime / circleCount);
			//alert(maxCircleDelay);
			var tweenTime = 0.4;
			var nextDelay = this.initialDelay;
			var totalTime = 0;
			var pauseBeforeCountdown = 0.3;
			var i=0;

			for(i = 0; i < circleCount; ++i) {
				nextDelay = this.initialDelay+(0.2+this.circles[i].dist*this.animateSeatsInTime);//*this.animateSeatsInTime
				TweenLite.to(this.circles[i], tweenTime, {delay:nextDelay, scale:1, ease:Sine.easeOut, overwrite:2});
				totalTime = Math.max(totalTime, tweenTime+nextDelay);
			}

			this.countNumbers(this.remainingSeats, totalTime+0.4, this.initialDelay);

			TweenLite.delayedCall(totalTime+pauseBeforeCountdown, function(){
				this.showRemaining();
			}.bind(this));

		};

		p.showRemaining = function() {
			var items = RHYTHM.Utils.arrayGetRandom(this.total-this.remainingSeats, this.circles);
			var delay = 0.04;
			var totalTime = 0;
			var tweenTime = 0.4;
			var i = 0;
			//var countTime = tweenTime;

			for(i = 0; i < items.length; ++i) {
				totalTime+=delay*i;
			}

			if(totalTime > this.animateSeatsOutMaxTime) {
				delay = this.animateSeatsOutMaxTime / items.length;
				totalTime = this.animateSeatsOutMaxTime;
			}

			for(i = 0; i < items.length; ++i) {
				TweenLite.to(items[i], tweenTime, {scale:0.2, delay:delay*i, ease:Sine.easeOut, overwrite:2});
				//countTime+=delay;
			}

			TweenLite.delayedCall((totalTime+tweenTime)*1.5, function(){
				cancelAnimationFrame( this.animationID );
			}.bind(this));

			//this.countNumbers(this.bookedSeats, time+delay, 0);
		};

		p.countNumbers = function(to, time, countDelay) {
			var diff = (to-this.seatCounter);
			var delay = countDelay || 0;

			TweenLite.to(this, time, {delay:delay, seatCounter:to, onUpdate:function(){
				this.counter.text(Math.ceil(this.seatCounter));
			}.bind(this), ease:Expo.easeOut});
		};

		p.enterFrame = function() {
			this.animationID = requestAnimationFrame( this.enterFrame.bind(this) );
			this.context.clearRect ( 0 , 0 , ctxWidth , ctxHeight );

			for(var i = 0; i < circleCount; ++i) {
				this.circles[i].draw(this.context);
			}
		};

	}

})();