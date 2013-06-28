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
		p.degrees = 0;
		p.startAngle = null;
		p.offset = -90;
		
		p.init = function(x, y, radius, color, angle) {
			this.radius = radius;
			this.color = color;
			this.x = x;
			this.y = y;
			this.scale = 1;
			this.degrees = angle+this.offset;
			this.startAngle = this.getRad(this.degrees);
		};

		p.setAngle = function(deg, time) {
			TweenLite.to(this, time, {degrees:deg+this.offset, onUpdate:this.updateWedge.bind(this), ease:Sine.easeOut});
		};

		p.updateWedge = function() {
			this.endAngle = this.getRad(this.degrees);
		};

		p.getRad = function(deg) {
			return deg*Math.PI/180;
		};

		p.draw = function(ctx) {
			ctx.beginPath();
			ctx.moveTo(20, 20);
			ctx.arc(20,20, this.radius, this.startAngle, this.endAngle, false);
			ctx.fillStyle = this.color;
			ctx.fill();
			ctx.closePath();
		};

	}

})();