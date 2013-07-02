package com.wehaverhythm.starling.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	
	public class StarlingUtils
	{
		public function StarlingUtils()
		{
			
		}
		
		public static function imageFromDisplayObject(obj:DisplayObject):Image
		{		
			var bmd:BitmapData = new BitmapData(obj.width, obj.height, true, 0x000000);
			bmd.draw(obj);			
			return StarlingUtils.imageFromBitmapData(bmd);
		}
		
		public static function imageFromBitmapData(bmd:BitmapData):Image
		{
			var textureSize:int = StarlingUtils.upperPowerOfTwo(Math.max(bmd.width, bmd.height));
			
			var texture:Texture = Texture.fromBitmap(new Bitmap(bmd), false, false, 1);			
			return new Image(texture);
		}
		
		public static function imageFromBitmap(bmp:Bitmap):Image
		{
			var textureSize:int = StarlingUtils.upperPowerOfTwo(Math.max(bmp.width, bmp.height));
			
			var texture:Texture = Texture.fromBitmap(bmp, false, false, 1);			
			return new Image(texture);
		}
		
		public static function upperPowerOfTwo(num:uint):uint
		{
			num--;
			num |= num >> 1;
			num |= num >> 2;
			num |= num >> 4;
			num |= num >> 8;
			num |= num >> 16;
			
			num++;			
			return num;
		}
	}
}