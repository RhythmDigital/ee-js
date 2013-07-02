package com.wehaverhythm.terry.voter
{
	import com.wehaverhythm.air.AssetFolderLoader;
	import com.wehaverhythm.terry.generic.GameBaseNative;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.events.EventDispatcher;
	

	public class QuestionMaster extends EventDispatcher
	{
		public static const SCALES:String = 'SCALES';
		public static const BAR_FROM_CENTRE:String = 'BAR_FROM_CENTRE';
		public static const STANDARD_QUESTION:String = 'STANDARD_QUESTION';
		public static const BAR_LEFT:String = "BAR_LEFT";	
		private var contentXML:XML;
		private var questions:Array;
		private var currentQuestion:int;
		private var contentTitle:String;
		private var contentType:String;
		private var numQuestions:int;
		private var answersCount:int;
		private var resultsEndDisplay:String;
		
		public function QuestionMaster()
		{
			
		}
		
		public function initQuestions(name:String):void
		{
			contentXML = AssetFolderLoader.getXML(name);
			
			trace("Initialising questions...");
			//trace(questionXML.toXMLString());
			
			contentTitle = contentXML.info.title;
			contentType = contentXML.info.@type;
		
			if(contentXML.info.hasOwnProperty("@resultsDisplay")) {
				resultsEndDisplay = contentXML.info.@resultsDisplay;
			} else {
				resultsEndDisplay = "ResultsDisplayDefault";
			}
			
			trace("Title: " + contentTitle + ", Type: " + contentType);
			
			questions = [];
			
			var questionItems:XMLList = contentXML.questions.question;
			for(var i:int = 0; i < questionItems.length(); ++i)
			{
				trace("Next question");
				var q:Object = {};
				
				q.xml = questionItems;
				q.display = String(questionItems[i].@display);
				q.q = String(questionItems[i].questionText);
				q.correct = -1;
				q.answers = [];
				
				for(var a:int = 0; a < questionItems[i].answers.answer.length(); ++a)
				{
					// Is it the correct answer? (if applicable)
					if(questionItems[i].answers.answer[a].hasOwnProperty("@correct") &&
						questionItems[i].answers.answer[a].@correct == "yes")
					{
						q.correct = a;
					}
					
					q.answers.push(String(questionItems[i].answers.answer[a]));
				}
				
				questions.push(q);
				for(var k:String in q) {
					trace(k+": " + q[k]);
				}
				
			}
			
			numQuestions = questions.length;
			currentQuestion = -1;
		}
		
		public function isFinalQuestion():Boolean
		{
			return currentQuestion+1 == questions.length;
		}
		
		public function getNextQuestion():Object
		{
			if(isFinalQuestion()) return null;
			else {
				++currentQuestion;
				answersCount = questions[currentQuestion].answers.length;
				return questions[currentQuestion];
			}
		}
		
		public function askQuestionTo(id:int, answer:int):void
		{
			trace("Asking question to: " + id);
			dispatchEvent(new CustomEvent(GameBaseNative.DISPATCH_EVENT_TO_USER, {type:'quest', params:{
				user:id,
				answer:answer == 0 ? -1 : answer-1, // the answer they already gave (if reconnected.)
				id:currentQuestion,
				q:questions[currentQuestion].q,
				answers:questions[currentQuestion].answers,
				correct:questions[currentQuestion].correct
			}}));
		} 
		
		public function askQuestion():void
		{			
			dispatchEvent(new CustomEvent(GameBaseNative.DISPATCH_EVENT_TO_ALL, {type:'quest', params:{
				id:currentQuestion,
				q:questions[currentQuestion].q,
				answers:questions[currentQuestion].answers,
				correct:questions[currentQuestion].correct
			}}));
		}
		
		public function get resultsDisplay():String
		{
			return resultsEndDisplay;
		}
		
		public function get question():Object
		{					
			return questions[currentQuestion];
		}
		
		public function get total():int
		{
			return numQuestions;
		}
		
		public function get current():int
		{
			return currentQuestion;
		}
		
		public function get type():String
		{
			return contentType;
		}
		
		public function get title():String
		{
			return contentTitle;
		}
		
		public function get numAnswers():int
		{
			return answersCount;
		}
		
		public function get xml():XML
		{
			return contentXML;
		}
	}
}