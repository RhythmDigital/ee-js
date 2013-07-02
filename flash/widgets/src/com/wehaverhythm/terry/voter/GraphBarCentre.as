package com.wehaverhythm.terry.voter
{
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class GraphBarCentre extends VotesDisplay
	{
		private var bars:Array;
		private var votes:Array;
		public var txtVotesCount:TextField;
		
		public function GraphBarCentre()
		{
			super();
		}
		
		override public function reset():void
		{
			super.reset();
			//while (numChildren > 0) removeChildAt(0);
			for(var i:int = 0; i < numChildren; ++i) {
				var c:* = getChildAt(i);
				
				if(c is GraphBar) {
					removeChild(c);
				}
			}
		}
		
		override public function show(q:Object, questionNumber:int, totalQuestions:int):void
		{
			super.show(q, questionNumber, totalQuestions);
			
			questionText.newString(q.q);
			
			bars = [];
			votes = [];
			
			var pos:Point = new Point(stage.stageWidth >> 1, 0);
			var ySpacing:Number = 600 / q.answers.length;
			
			for (var i:int=0; i<q.answers.length; ++i)
			{
				var bar:GraphBar = new GraphBarDisplay();
				bar.x = pos.x;
				bar.y = ySpacing*i;
				bar.height = ySpacing*.95;
				bar.width = (stage.stageWidth >> 1) - 100;
				bar.min = .1;
				if (i%2 == 1) bar.scaleX = -bar.scaleX;
				
				addChild(bar);
				bars.push(bar);
				
				votes[i] = 0;
			}
		}
		
		override public function setStatusText(answeredCount:int, totalPlayers:int):void
		{
			trace("WORKING!");
			txtVotesCount.text = String(answeredCount+" OF "+totalPlayers+" PLAYERS HAVE VOTED");
		}
		
		override public function registerVote(vote:String):void
		{
			super.registerVote(vote);
			
			votes[int(vote)]++;		
			var totalVotes:int = 0;
			var largest:int = 0;
				
			for (var i:int=0; i<votes.length; ++i)
			{
				totalVotes += votes[i];
				if (votes[i] > votes[largest]) largest = i;
			}
			
			var adjustment:Number = totalVotes / votes[largest];
			
			for (i=0; i<votes.length; ++i)
			{
				bars[i].showPerc((votes[i] / totalVotes)*adjustment);
			}			
		}
	}
}