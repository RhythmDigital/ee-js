package com.wehaverhythm.twitter
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.LoaderStatus;
	
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	public class ProfilePictures extends EventDispatcher
	{
		private var assetsPath:String;
		private var cache:FollowerCache;
		private var bitmapCache:Dictionary;
		private var loader:LoaderMax;
		private var twitter:TwitterQueue;
		
		public function ProfilePictures(cacheData:Class, assetsPath:String)
		{
			//twitter = new TwitterQueue();
			loader = new LoaderMax();
			this.assetsPath = assetsPath;
			bitmapCache = new Dictionary();
			cache = new FollowerCache(cacheData);
		}
		
		public function findProfilePicture(screenName:String):void
		{	
			var existingLoader:ImageLoader = LoaderMax.getLoader(screenName);
			
			var dotIndex:int = screenName.indexOf(".");
			var screenNameNoSuffix:String = screenName.substr(0, dotIndex != -1 ? dotIndex : screenName.length);
			// trace(new Error(correctScreenname));
			
			if(existingLoader != null && existingLoader.status == LoaderStatus.LOADING) {
				trace("Loader is already working on " + screenName + ". Be patient!");
			}
			
			// check if we have stored the loaded bitmap.
			/*if(bitmapCache[screenName]) {
				trace(this, " getting cached bitmap for " + screenName);
				imageReady(screenName, bitmapCache[screenName]);
				return;
			}*/
			
			if(cache && cache.lookup[screenNameNoSuffix]) {
				loadLocalImage(screenNameNoSuffix, screenName);
				return;
			} else {
				trace("NOT IN CACHE");
			}
			
			// try and grab from twitter.
			//twitter.requestProfileData(screenName);
			
			dispatchEvent(new ProfilePictureEvent(ProfilePictureEvent.ERROR, true, false, screenName, null));
		}
		
		private function imageReady(screenName:String, bmp:Bitmap):void
		{
			bitmapCache[screenName] = bmp;
			dispatchEvent(new ProfilePictureEvent(ProfilePictureEvent.GOT_PROFILE_PICTURE, true, false, screenName, bmp));
		}
		
		private function loadLocalImage(imageName:String, screenName:String):void {
			trace(this," loading local image for " + screenName + ": " + imageName+".png");
			var f:File = File.applicationDirectory.resolvePath(assetsPath+"/"+imageName+".png");
			loadImage(screenName, f.url);
		}
		
		private function loadImage(screenName:String, url:String):void
		{
			var l:ImageLoader = new ImageLoader(url, {name:screenName, onComplete:onImageLoaded, onError:onImageLoadError});
			loader.insert(l);
			l.load();
		}
		
		private function onImageLoaded(e:LoaderEvent):void
		{
			var img:ImageLoader = ImageLoader(e.target);
			imageReady(img.name, Bitmap(img.rawContent));
		}
		
		private function onImageLoadError(e:LoaderEvent):void
		{
			var img:ImageLoader = ImageLoader(e.target);
			trace(this, " error loading profile image for " + img.name);
			dispatchEvent(new ProfilePictureEvent(ProfilePictureEvent.ERROR, true, false, img.name, null));
		}
		
	}
}