package com.wehaverhythm.terry.voter
{
	import com.greensock.TweenMax;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.text.TextField;
	
	public class ScalesMain extends VotesDisplay
	{
		// timeline
		public var scales:Scales;
		public var question:TextField;
		public var answer0:TextField;
		public var answer1:TextField;
		public var txtVotesCount:TextField;
		
		// class
		private var votes:Array;
		
		
		public function ScalesMain()
		{
			super();
			
		//	scales.addEventListener("UPDATE_VOTES_COUNT", onUpdateVotesCount);
		}	
		
		/*protected function onUpdateVotesCount(e:CustomEvent):void
		{
			updateVotesCountTF(e.params.totalVotes);
		}
		*/
		
		override public function reset():void
		{
			super.reset();
			trace("resetting scales...");
			votes = [];
			scales.reset();
		}
		
		override public function show(q:Object, questionNumber:int, totalQuestions:int):void
		{
			super.show(q, questionNumber, totalQuestions);
			votes = [];
			
			for (var i:int=0; i<q.answers.length; ++i)
			{
				votes[i] = 0;
			}
			
			question.text = q.q;
			answer0.text = q.answers[0];
			answer1.text = q.answers[1];
			
			TweenMax.to(scales, 0, {autoAlpha:0});
		}
		
		override public function showGraph():void
		{
			TweenMax.to(scales, .4, {autoAlpha:1});
		}
	
		override public function setStatusText(answeredCount:int, totalPlayers:int):void
		{
			txtVotesCount.text = String(answeredCount+" OF "+totalPlayers+" PLAYERS HAVE VOTED");
		}
		
		override public function registerVote(vote:String):void
		{
			super.registerVote(vote);
			
			++votes[int(vote)];
			
			var totalVotes:int = votes[0] + votes[1];	
			
			var left:Number = votes[0] / totalVotes;
			var right:Number = votes[1] / totalVotes;
			var diff:Number = right - left;
			
			scales.tip(int(vote), votes);
		}
	}
}