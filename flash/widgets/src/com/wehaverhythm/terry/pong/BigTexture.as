package com.wehaverhythm.terry.pong
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import starling.display.Image;
	import starling.textures.Texture;

	public class BigTexture
	{
		private var w:Number;
		private var h:Number;
		private var bmp:Bitmap;
		private var texture:Texture;
		public var image:Image;
		
		public function BigTexture(w:Number, h:Number)
		{
			this.w = w;
			this.h = h;
			reset();
		}
		
		public function addUser(u:PongUser):void
		{
			var userBMD:BitmapData = u.userBitmap.bitmapData;
			var userImg:Image = u.profileImg;
			
			var s:Sprite = new Sprite();
			var sContain:Sprite = new Sprite();
			sContain.addChild(u.userBitmap);
			s.addChild(sContain);
			sContain.alpha = u.defaultAlpha;
			
			
			var mtx:Matrix = new Matrix();
			mtx.tx = userImg.x;
			mtx.ty = userImg.y;
			
			bmp.bitmapData.draw(s, mtx);
			
			sContain.removeChild(u.userBitmap);
			s.removeChild(sContain);
			s = null;
			//bmp.bitmapData.copyPixels(userBMD, userBMD.rect, new Point(userImg.x, userImg.y));
		}
		
		public function reset():void
		{
			if(bmp) {
				bmp.bitmapData.dispose();
			}
			
			bmp = new Bitmap(new BitmapData(w, h, false, 0x000000));
		}
		
		public function makeTexture():Image
		{
			if(texture != null) {
				if(image && image.parent) image.parent.removeChild(image);
				texture.dispose();
			}
			
			texture = Texture.fromBitmap(bmp);
			
			if(!image) image = new Image(texture);
			else image.texture = texture;
		
			return image;
		}
	}
}