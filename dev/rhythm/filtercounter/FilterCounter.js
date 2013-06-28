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

		p.init = function(params) {
			console.log("New counter");

			this.params = params;

			this.centre = {x:20, y:20};
			this.maxValue = params.maxValue;
			this.canvas = params.canvas[0];
			this.context = this.canvas.getContext("2d");
			this.counter = params.counter[0];

			// make circles
			this.circleBG = new namespace.BasicCircle();
			this.circleBG.init(this.centre.x, this.centre.y, 20, "#eae3c9");

			this.wedge = new namespace.Wedge();
			this.wedge.init(this.centre.x, this.centre.y, 20, "#009c9c", 0);

			this.circleWhite = new namespace.BasicCircle();
			this.circleWhite.init(this.centre.x, this.centre.y, 16, "#ffffff");

			this.updateValue(params.initialValue, true);
			this.enterFrame();
		};

		p.enterFrame = function() {
			this.animationID = requestAnimationFrame( this.enterFrame.bind(this) );

			
			this.wedge.update(this.wedgeTarget);

			this.context.clearRect ( 0 , 0 , ctxWidth , ctxHeight );
			this.circleBG.draw(this.context);
			this.wedge.draw(this.context);
			this.circleWhite.draw(this.context);
		};

		p.calculateWedge = function() {
			//console
		}

		p.updateValue = function(val, immediateRender) {
			var immediate = immediateRender || false; // animate it?
			console.log("update val to " + val);

			this.wedgeTarget = this.calculateWedge();
			//this.
		};

	}

})();