package com.wehaverhythm.terry.voter.results
{
	public class ResultsQuizBasic extends ResultsDisplay
	{
		private var answers:Array;
		
		public function ResultsQuizBasic()
		{
			super();
		}
		
		override public function destroy():void
		{
			if(answers)
			{
				while(answers.length)
				{
					if(contains(answers[0])) {
						removeChild(answers[0]);
					}
						
					answers[0] = null;
					answers.shift();
				}
			}
		}
		
		override public function init(results:Results):void
		{
			var info:Array = results.getQuizResults();
			var scores:Array = results.getQuizScores();
			
			trace("************************");
			var i:int = 0;
			var nextScore:QuizResultsItem;
			var startY:int = 259;
			var startX:int = 192;
			
			answers = new Array();
			
			for each(var score:Object in scores) {
				
				nextScore = new QuizResultsItem();
				answers.push(nextScore);
				nextScore.txtName.text = "Player " + (score.uid+1);
				nextScore.txtPos.text = String(i+1);
				nextScore.txtScore.text = String(score.score + "/" + info.length);
				addChild(nextScore);
				
				nextScore.x = startX;
				nextScore.y = startY + (i*nextScore.height) + 25;
				
				trace("Player " + score.uid + " is number " + i + " scoring " + score.score + "/"+info.length);
				++i;
			}
			trace("************************");
			
			/*
			
			OVERRIDE THIS
			
			Results is an array of objects with the following properties
			{tally, userAnswers, numPlayers, correctAnswer}
			
			tally[i] = quantity of votes per answer (i)
			userAnswers = dictionary of keys(userID) and their value(answer)
			numPlayers = number of players connected during that question
			correctAnswer = (int) correct answer index
			
			*/
		}
	}
}