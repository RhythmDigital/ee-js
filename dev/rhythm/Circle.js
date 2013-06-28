(function(){

    var namespace = MAIN.namespace('widgets');

    if (namespace.BasicCircle === undefined) 
	{
        namespace.BasicCircle = function()
		{	
			
		};

		var p = namespace.BasicCircle.prototype;
		p.radius = null;
		p.color = null;
		p.x = null;
		p.y = null;
		p.scale = null;
		p.dist = 0;
		
		p.init = function(x, y, radius, color, dist) {
			this.radius = radius;
			this.color = color;
			this.x = x;
			this.y = y;
			this.scale = 1;
			this.dist = dist || 0;
		};

		p.draw = function(ctx) {
			ctx.beginPath();
			ctx.arc(this.x, this.y, this.radius*this.scale, 0, 2 * Math.PI, false);
			ctx.fillStyle = this.color;
			ctx.fill();
			ctx.closePath();
		};

	}

})();