(function(){

    var namespace = MAIN.namespace('widgets');
    var ctxWidth = 40;
    var ctxHeight = 40;

    if (namespace.FilterCounter === undefined) 
	{
        namespace.FilterCounter = function()
		{	
		};

		var p = namespace.FilterCounter.prototype;
		p.canvas = null;
		p.context = null;
		p.animationID = null;
		p.counter = null;
		p.circleBG = null;
		p.circleWhite = null;
		p.wedge = null;
		p.centre = null;
		p.maxValue = null;
		p.params = null;
		p.val = null;

		p.init = function(params) {

			if(!isCanvasSupported()) {
				return;
			}

			this.params = params;

			this.centre = {x:20, y:20};
			this.maxValue = params.maxValue;
			this.canvas = params.canvas[0];
			this.context = this.canvas.getContext("2d");
			this.counter = $(params.counter[0]);

			this.context.width = ctxWidth;
			this.context.height = ctxHeight;

			// make circles
			this.circleBG = new namespace.BasicCircle();
			this.circleBG.init(this.centre.x, this.centre.y, 20, "#eae3c9");

			this.wedge = new namespace.Wedge();
			this.wedge.init(this.centre.x, this.centre.y, 20, "#009c9c", 0);

			this.circleWhite = new namespace.BasicCircle();
			this.circleWhite.init(this.centre.x, this.centre.y, 16, "#ffffff");

			this.val = 0;
			this.updateValue(0, true);
			this.draw();

			TweenLite.delayedCall(params.initialDelay, this.delayedInitialUpdate.bind(this));
		};

		p.delayedInitialUpdate = function() {
			this.updateValue(this.params.initialValue);
		};

		p.enterFrame = function() {
			this.animationID = requestAnimationFrame( this.enterFrame.bind(this) );

			this.context.clearRect ( 0 , 0 , ctxWidth , ctxHeight );
			this.draw();
		};

		p.draw = function() {
			this.circleBG.draw(this.context);
			this.wedge.draw(this.context);
			this.circleWhite.draw(this.context);
		};

		p.updateValue = function(val, immediateRender) {

			TweenLite.killDelayedCallsTo(this.delayedInitialUpdate);
			var immediate = immediateRender || false; // animate it?
			var angle = RHYTHM.Utils.mapRange(val, 0, this.maxValue, 0, 360);

			if(!immediate) {

				if(!this.animationID) {
					this.enterFrame();
				}

				this.wedge.setAngle(angle, 0.3);
				TweenLite.to(this, 0.4, {val:val, ease:Sine.easeOut, onUpdate:this.setValueText.bind(this), onComplete:this.stopAnimating.bind(this), overwrite:2});
			
			} else {
				this.counter.text(val);
			}

		};

		p.stopAnimating = function() {
			cancelAnimationFrame( this.animationID );
			this.animationID = null;
		};

		p.setValueText = function() {
			this.counter.text(Math.ceil(this.val));
		};

	}

})();