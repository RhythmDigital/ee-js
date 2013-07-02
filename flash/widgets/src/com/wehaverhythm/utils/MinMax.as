package com.wehaverhythm.utils
{	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	
	/**
	 *	Simple class for Min Max values
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Adam Palmer
	 *	@since  06.08.2009
	 */
	
	public class MinMax
	{			
		public var min:Number;
		public var max:Number;
		
		
		public function MinMax(min:Number, max:Number):void
		{
			this.min = min;
			this.max = max;
		}
		
		/**
		 * Get an evenly-spaced array of numbers between min and max.
		 * 
		 * @param elements the number of elements in the array.
		 * @param decimelPlaces the number of decimel places to round to.
		 * 
		 * @return The array.
		 */
		public function getEvenlySpacedArray(elements:int, decimelPlaces:int=2):Array
		{
			var spacing:Number = (max - min) / (elements-1);			
			var spacedArray:Array = [];
			
			for (var i:int=0; i<elements; i++)
			{
				var nextStep:Number = min + i*spacing;				
				if (decimelPlaces > 0) nextStep = Number(nextStep.toFixed(decimelPlaces));
				else nextStep = Math.ceil(nextStep);
				
				spacedArray.push(nextStep);
			}
			
			return spacedArray;
		}
		
		/**
		 * Get an unevenly-spaced array of numbers between min and max.
		 * 
		 * @param elements the number of elements in the array.
		 * @param decimelPlaces the number of decimel places to round to.
		 * @param percentageSpread a value between 0 and 1, the amount by which to randomly vary the spacing from the norm.
		 * 
		 * @return The array.
		 */
		public function getUnEvenlySpacedArray(elements:int, decimelPlaces:int=2, percentageSpread:Number=.9):Array
		{
			var unevenlySpacedArray:Array = getEvenlySpacedArray(elements, decimelPlaces);
			var spread:Number = unevenlySpacedArray[1]*percentageSpread;
			
			for (var i:int=1; i<elements-1; i++)
			{
				var range:MinMax = new MinMax(unevenlySpacedArray[i]-spread/2, unevenlySpacedArray[i]+spread/2);
				var nextStep:Number = range.random;
				
				if (decimelPlaces > 0) nextStep = Number(nextStep.toFixed(decimelPlaces));
				else nextStep = Math.ceil(nextStep);
				
				unevenlySpacedArray[i] = nextStep;
			}
			
			unevenlySpacedArray.sort(Array.NUMERIC);			
			return unevenlySpacedArray;			
		}
		
		/**
		 * Get a random number between min and max.
		 * 
		 * @return The random number.
		 */
		public function get random():Number
		{
			return min + Math.random()*(max - min);			
		}
		
		/**
		 * Get a value a certain percentage between min and max
		 * 
		 * @param perc the point between min and max, expressed as 0 to 1. 
		 * @return the value at the point between min and max.
		 */
		public function getValueAtPercentage(perc:Number):Number
		{
			return min + ((max - min) * perc);
		}
		
		/**
		 * Quickly get a value a certain percentage between a temporary min and temporary max.
		 * 
		 * @param tempMin the temporary min.
		 * @param tempMax the temporary max.
		 * @param perc the point between tempMin and tempMax, expressed as 0 to 1.
		 *  
		 * @return the value at the point between tempMin and tempMax.
		 */
		public static function getValueAtPercentageBetween(tempMin:Number, tempMax:Number, perc:Number):Number
		{
			return tempMin + ((tempMax - tempMin) * perc);
		}
		
		/**
		 * Quickly get a random number between a temporary min and temporary max.
		 * 
		 * @param tempMin the temporary min.
		 * @param tempMax the temporary max.
		 * 
		 * @return The random number.
		 */
		public static function randomBetween(tempMin:Number, tempMax:Number):Number
		{
			return tempMin + Math.random()*(tempMax - tempMin);		
		}
	}
}