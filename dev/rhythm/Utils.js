// Request animation frame polyfill.
(function() {
    var lastTime = 0;
    var vendors = ['webkit', 'moz'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelAnimationFrame =
          window[vendors[x]+'CancelAnimationFrame'] || window[vendors[x]+'CancelRequestAnimationFrame'];
    }

    if (!window.requestAnimationFrame) {
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); },
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };
    }

    if (!window.cancelAnimationFrame) {
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
    }
}());

// bind fix
if (!Function.prototype.bind) {
  Function.prototype.bind = function (oThis) {
    if (typeof this !== "function") {
      // closest thing possible to the ECMAScript 5 internal IsCallable function
      throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
    }
 
    var aArgs = Array.prototype.slice.call(arguments, 1), 
        fToBind = this, 
        fNOP = function () {},
        fBound = function () {
          return fToBind.apply(this instanceof fNOP && oThis ? this : oThis, aArgs.concat(Array.prototype.slice.call(arguments)));
        };
 
    fNOP.prototype = this.prototype;
    fBound.prototype = new fNOP();
 
    return fBound;
  };
}

var RHYTHM = RHYTHM || {};

/**
*	Rhythm Tools Class
*/
RHYTHM.namespace = RHYTHM.namespace || function (aNamespace) {
    var parts = aNamespace.split('.'),
        parent = RHYTHM,
        i;
    if (parts[0] === "RHYTHM") {
        parts = parts.slice(1);
    }

    for (i = 0; i < parts.length; i += 1) {
        if (typeof parent[parts[i]] === "undefined") {
            parent[parts[i]] = {};
        }
        parent = parent[parts[i]];
    }

    return parent;
};

RHYTHM.Utils = RHYTHM.Utils || (function(){

	return {
		mapRange: function(v, a, b, x, y) {
			return (v === a) ? x : (v - a) * (y - x) / (b - a) + x;
		},

        arrayClone: function(arrayIn) {
            var arrayOut = [];

            for(var i=0; i<arrayIn.length; ++i) {
                arrayOut.push(arrayIn[i]);
            }

            return arrayOut;
        },

        arrayGetRandom: function(numItems, arrayIn) {
            var clone = RHYTHM.Utils.arrayClone(arrayIn);
            var arrayOut = [];
            while(numItems > 0) {
                var seed = Math.floor(Math.random()*clone.length);
                arrayOut.push(clone.splice(seed,1)[0]);
                numItems--;
            }

            return arrayOut;
        }
    };
		
})();

RHYTHM.Trig = RHYTHM.Trig || (function() {
    return {
        getDistance: function(p1, p2){
            var x_cord = p2.x-p1.x;
            var y_cord = p2.y-p1.y;
            return Math.sqrt(x_cord*x_cord + y_cord*y_cord);
        }
    };
})();