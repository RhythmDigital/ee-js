package com.wehaverhythm.terry.voter
{
	import com.wehaverhythm.utils.AutoTextResizer;
	
	import flash.text.TextField;

	public class StandardQuestion extends VotesDisplay
	{
		public var txtQuestionNumber:TextField;
		public var txtQuestionText:TextField;
		public var txtVotesCount:TextField;
		
		private var qTF:AutoTextResizer;
		
		public function StandardQuestion()
		{
			super();
		}
		
		override public function show(q:Object, questionNumber:int, totalQuestions:int):void
		{
			super.show(q, questionNumber, totalQuestions);
			
			trace("QUESTION SHOWING " + questionNumber + " / " + totalQuestions);
		//	txtQuestionText.text = q.q;
			txtQuestionNumber.text = "QUESTION " + (questionNumber+1) + " OF " + totalQuestions;
			
			questionText.newString(q.q);
		}
		
		override public function setStatusText(answeredCount:int, totalPlayers:int):void
		{
			txtVotesCount.text = String(answeredCount+" OF "+totalPlayers+" PLAYERS HAVE ANSWERED");
		}
		
		override public function reset():void
		{
			super.reset();
			
			if(qTF)
			{
				removeChild(qTF);
				qTF = null;
			}
			
			trace("RESETTING STANDARD QUESTION...");
		}
	}
}