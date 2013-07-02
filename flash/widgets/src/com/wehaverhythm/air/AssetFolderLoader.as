package com.wehaverhythm.air
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	public class AssetFolderLoader extends EventDispatcher
	{
		public static var instance:AssetFolderLoader;
		private static var loader:LoaderMax;
		
		public function AssetFolderLoader(pvt:SingletonEnforcer)
		{
			super(null);
		}
		
		public static function load(folder:File):void
		{
			var i:AssetFolderLoader = getInstance();
			
			if(!folder.exists) folder.createDirectory();
			
			loader = new LoaderMax({onComplete:onLoadComplete});
			
			var files:Array = folder.getDirectoryListing();
			
			if(!files.length) trace("There are no files in directory " + folder.nativePath);
			
			for each(var f:File in files) {
				var ext:String = f.extension.toLowerCase();
				
				switch(ext) {
					case "xml":
						loader.append(new XMLLoader(f.url, {name:f.name}));
						break;
					default:
						trace(new Error("Don't know how to handle *." + ext + " files!\n"));
				}
			}
			
			loader.load(true);
		}
		
		private static function onLoadComplete(e:LoaderEvent):void
		{
			getInstance().dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public static function getXML(name:String):XML
		{
			return XML(loader.getContent(name));
		}
		
		public static function getFiles():Array
		{
			return loader.getChildren(true, false);
		}
		
		public static function getInstance():AssetFolderLoader
		{
			if ( instance == null ) instance = new AssetFolderLoader( new SingletonEnforcer() );
			return instance;
		}
	}
}
internal class SingletonEnforcer{};