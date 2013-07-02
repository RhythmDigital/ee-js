package com.wehaverhythm.terry.voter
{
	
	import com.wehaverhythm.terry.terrytest.Bar;
	import com.wehaverhythm.utils.AutoTextResizer;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class BarsLeft extends VotesDisplay
	{
		private var bars:Array;
		private var votes:Array;
		private var maxBarLength:int;
		private var oneVoteGirth:int;
		
		public var txtVotesCount:TextField;
		
		public function BarsLeft()
		{
			super();
			
		}
		
		override public function reset():void
		{
			super.reset();
			clearStage();
			
		}
		
		private function clearStage():void
		{
			for(var i:int = 0; i < numChildren; ++i) {
				var c:* = getChildAt(i);
				
				if(c is GraphBar || (c!=questionText && c is AutoTextResizer) || c is Bar) {
					removeChild(c);
					clearStage();
				}
			}
		}
		
		override public function show(q:Object, questionNumber:int, totalQuestions:int):void
		{
			super.show(q, questionNumber, totalQuestions);
			
			questionText.newString(q.q);
			
			bars = [];
			votes = [];
			maxBarLength = questionText.textBoxWidth;
			
			var pos:Point = new Point((stage.stageWidth - questionText.textBoxWidth)*.5,0);
			var ySpacing:Number = 300 / q.answers.length;
			var yStart:int = questionText.textBottom+20;
			for (var i:int=0; i<q.answers.length; ++i)
			{
				var bar:GraphBar = new GraphBarDisplay();
				bar.x = pos.x;
				bar.y = yStart+(ySpacing*i);
				bar.height = ySpacing*.95;
				bar.width = (stage.stageWidth >> 1) - 100;
				bar.min = 10;
				bar.max = maxBarLength;
				
				addChild(bar);
				bars.push(bar);
				
				//bar text
				var barTF:AutoTextResizer = new AutoTextResizer(new Rectangle(bar.x,bar.y, maxBarLength, bar.height), 20, 0xFF0000, "left");
				barTF.newString(q.answers[i]);
				addChild(barTF);
				
				
				votes[i] = 0;
			}
		}
		
		override public function setStatusText(answeredCount:int, tPlayers:int):void
		{
			//trace("WORKING!");
			totalPlayers = tPlayers;
			oneVoteGirth = maxBarLength/totalPlayers;

			txtVotesCount.text = String(answeredCount+" OF "+totalPlayers+" PLAYERS HAVE VOTED");
		}
		
		override public function registerVote(vote:String):void
		{
			super.registerVote(vote);
			
			votes[int(vote)]++;		
			var totalVotes:int = 0;
			var largest:int = 0;

			for (var i:int=0; i<bars.length; ++i)
			{
				bars[i].showGirth(votes[i] * oneVoteGirth);
			}			
		}
	}
}


