package com.wehaverhythm.twitter
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import de.danielyan.twitterAppOnly.TwitterSocket;
	
	public class TwitterQueue extends EventDispatcher
	{
		private var queue:Vector.<String>;
		private var socket:TwitterSocket;
		
		public function TwitterQueue()
		{
			socket = new TwitterSocket("6kk9QneQPGPPsf44kYhjag", "OfnV2sigzEOua95wlp2KHX0b8yM58UZ3ewLfl9mfBs");
			socket.addEventListener(TwitterSocket.EVENT_TWITTER_READY, onTwitterReady);
			
			queue = new Vector.<String>();
			// when connected, get next 100 users or whateve is remaining from vector.
		}
		
		protected function onTwitterReady(e:flash.events.Event):void
		{
			trace("Twitter Ready");
			socket.removeEventListener(TwitterSocket.EVENT_TWITTER_READY, onTwitterReady);
			socket.addEventListener(TwitterSocket.EVENT_TWITTER_READY, checkForData);
			
		}
		
		protected function checkForData(e:Event):void
		{
			// check if there is data in queue
			// if yes, then get next 100 / total.
		}
		
		public function requestProfileData(screenname:String):void
		{
		//	queue.push(screenname);
		}
	}
}