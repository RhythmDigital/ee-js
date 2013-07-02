package com.wehaverhythm.utils
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.display.IBitmapDrawable;
	

	public class BitmapDataUtils
	{
		
		public function BitmapDataUtils()
		{
		}
		
		public static function getFirstNonTransparentPixel( bmd:BitmapData ):Point
		{
			var hitRect:Rectangle = new Rectangle(0, 0, bmd.width, 1);
			var p:Point = new Point();
			
			for( hitRect.y = 0; hitRect.y < bmd.height; hitRect.y++ )
			{
				if( bmd.hitTest( p, 0x01, hitRect) )
				{
					var hitBMD:BitmapData=new BitmapData( bmd.width, 1, true, 0 );
					hitBMD.copyPixels( bmd, hitRect, p );
					
					return hitRect.topLeft.add( hitBMD.getColorBoundsRect(0xFF000000, 0, false).topLeft );
				}
			}
			return null;
		}
		
		
		public static function getAverageColor(drawable:IBitmapDrawable, x:int, y:int, area:int):uint
		{
			
			var bitmapData:BitmapData = new BitmapData(area, area);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, x*-.5, y*-.5);
			var clipRect:Rectangle = new Rectangle(0, 0, area, area);
			
			var red:Number = 0;
			var green:Number = 0;
			var blue:Number = 0;
			
			var count:Number = 0;
			var pixel:Number;

			bitmapData.draw(drawable, matrix, null, null, clipRect);
		
			for (var x:int = 0; x < bitmapData.width; x++)
			{
				for (var y:int = 0; y < bitmapData.height; y++)
				{
					pixel = bitmapData.getPixel(x, y);
					
					red += pixel >> 16 & 0xFF;
					green += pixel >> 8 & 0xFF;
					blue += pixel & 0xFF;
					
					count++
				}
			}
			
			red /= count;
			green /= count;
			blue /= count;
			
			return red << 16 | green << 8 | blue;
			
		}

	}
}