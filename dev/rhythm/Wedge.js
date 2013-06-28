(function(){

    var namespace = MAIN.namespace('widgets');

    if (namespace.Wedge === undefined) 
	{
        namespace.Wedge = function()
		{	
			
		};

		var p = namespace.Wedge.prototype;
		p.radius = null;
		p.color = null;
		p.x = null;
		p.y = null;
		p.scale = null;
		
		p.init = function(x, y, radius, color, angle) {
			console.log("NEW WEDGE!");
			this.radius = radius;
			this.color = color;
			this.x = x;
			this.y = y;
			this.scale = 1;
			this.endAngle = angle;
		};

		p.update = function() {

		};

		p.draw = function(ctx) {

			ctx.beginPath()
			ctx.arc(this.x, this.y, this.radius, Math.PI*2, Math.PI*1, false);
			ctx.fillStyle = this.color;
			ctx.fill();
			ctx.closePath();
		};

	}

})();