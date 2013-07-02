package com.wehaverhythm.twitter
{
	import flash.utils.Dictionary;

	public class FollowerCache
	{
		public var lookup:Dictionary;
		
		public function FollowerCache(cache:Class)
		{
			lookup = new Dictionary();
			
			var b:String = String(new cache());
			//var j:Object = JSON.parse(b);
		
			addCache(JSON.parse(b));
			
//			trace("JAMIE WHITE: " + lookup["jamiemarkwhite"]);
//			trace("ED BALDRY: " + lookup["edbaldry"]);
//			trace("ADAM PALMER: " + lookup["palmerama"]);
		}
		
		public function addCache(json:Object):void
		{
			var users:Array = json.users;
			
			for(var i:int = 0; i < users.length; ++i) {
				lookup[users[i]["screen_name"].toLowerCase()] = decodeURIComponent(users[i]["profile_image_url"]);
			}
		}
	}
}