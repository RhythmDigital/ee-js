package com.wehaverhythm.utils
{
	import com.greensock.TweenMax;
	import com.stardotstar.utils.IDestroyable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.ByteArray;

	public class Utils
	{
		private static const VERBOSE:Boolean = false;
		
		public function Utils()
		{
			
		}
		
		public static function cloneObject(source:Object):* 
		{ 
			var ba:ByteArray = new ByteArray(); 
			ba.writeObject(source); 
			ba.position = 0; 
			return(ba.readObject()); 
		}
		
		/**
		 * Cleanup Multiple Display Objects
		 * @items Comma seperated list of display objects to cleanup
		 */
		public static function cleanupMultipleObjects(... items):void
		{
			for each(var obj:Object in items) {
				cleanupObject(obj);
			}
		}
		
		/**
		 * Cleanup Display Object
		 * (doesn't remove event listeners)
		 */
		public static function cleanupObject(obj:Object):void
		{
			// Trace error if object is undefined.
			if(!obj) {
				if(Utils.VERBOSE) trace(new Error("Cannot destroy " + obj));
				return void;
			}
			
			// Bitmap Data
			if(obj is BitmapData) {
				if(Utils.VERBOSE) trace("Disposing bitmap data");
				BitmapData(obj).dispose();
			}
			
			// Arrays & Vectors
			if(obj is Array || obj is Vector) {
				
				if(Utils.VERBOSE) trace("We have an array! Clean it up!");
				// check if array
				while(obj.length) {
					
					if(obj[0] is DisplayObject)
						Utils.cleanupObject(obj[0]);
					
					obj[0] = null;
					obj.shift();
				}
				
				// job done for vectors & arrays
				return void;
			}
			
			if(obj is IDestroyable) {
				if(Utils.VERBOSE) trace(obj + " implements IDestroyable!");
				IDestroyable(obj).destroy();
			}
			
			if(obj is DisplayObject) {
				// kill tweens
				if(Utils.VERBOSE) trace("Killing tweens of " + obj);
				TweenMax.killTweensOf(obj);
			}
			
			if((obj is Sprite) || (obj is MovieClip)) {
				if(Utils.VERBOSE) trace("Killing child tweens of " + obj);
				TweenMax.killChildTweensOf(Sprite(obj));
				
				// if it's a movieclip, stop it.
				if(obj is MovieClip) {
					if(Utils.VERBOSE) trace("Stopping " + obj);
					MovieClip(obj).stop();
				}
				
				// remove objects children
				var child:*;
				while(obj.numChildren > 0) {
					
					child = obj.getChildAt(0);
					
					if(child is IDestroyable) {
						IDestroyable(child).destroy();
					}
					
					Utils.cleanupObject(child);
				}
			}
			
			if(obj is Bitmap) {
				if(Utils.VERBOSE) trace("Disposing bitmap");
				Bitmap(obj).bitmapData.dispose();
			}
			
			// remove it from parent
			if(obj.hasOwnProperty("parent")) {
				if(Utils.VERBOSE) trace("Removing " + obj + " from parent");
				if(obj.parent != null)
					obj.parent.removeChild(obj);
			}
			
		}
		
		public static function removeAllChildrenOf(disObj:*, recursive:Boolean = false):void
		{
			var child:*;
			if(Utils.VERBOSE) trace("Remove all children of: " + disObj);
			
			if(disObj.hasOwnProperty("numChildren"))
			{
				while(Sprite(disObj).numChildren)
				{
					child = Sprite(disObj).getChildAt(0);
					if(Utils.VERBOSE) trace("Process child: " + child);
					
					if(recursive)
						removeAllChildrenOf(child, recursive);
					
					if(Utils.VERBOSE) trace("Remove child: " + child);
					Sprite(disObj).removeChildAt(0);
				}
			}
			
		}
	}
}