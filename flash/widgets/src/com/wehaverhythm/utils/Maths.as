package com.wehaverhythm.utils
{
	public class Maths
	{
		public function Maths()
		{
		}
		
		public static function randomIntBetween(a:int, b:int):int
		{
			return Math.round(a + Math.random()*(b-a));
		}
		
		/**
		 * 
		 * @v Value (your number you want to map)
		 * @a Range 1 Lower
		 * @b Range 1 Upper
		 * @x Range 2 Lower
		 * @y Range 2 Upper
		 * 
		 * This function finds where "v" sits in range "ab",
		 * and finds its proportional position in range "xy"
		 */
		public static function map(v:Number, a:Number, b:Number, x:Number = 0, y:Number = 1):Number {
			return (v == a) ? x : (v - a) * (y - x) / (b - a) + x;
		}
	}
}