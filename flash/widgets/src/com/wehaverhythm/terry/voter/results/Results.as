﻿package com.wehaverhythm.terry.voter.results{	import com.wehaverhythm.terry.voter.PointTally;		import flash.utils.Dictionary;
	public class Results	{		public var xml:XML;		public var list:Array;		public var scores:Array;		public var playerPoints:Dictionary;		private var playerCount:int;				public function Results()		{			playerPoints = new Dictionary();			playerCount = 0;		}				public function initXML(xml:XML):void		{			this.xml = xml;			list = new Array();		}				public function addQuestionResult(questionResult:Dictionary, question:Object, totalPlayers:int):void		{			var questionXML:XMLList = question.xml;			var answerList:Array = question.answers;			var tally:Array = new Array(answerList.length);			var correctAnswer:int = question.correct;						for(var i:int = 0; i < answerList.length; ++i) {				//answerList[i] = 0;				tally[i] = 0;			}						for(var u:String in questionResult) {				var userID:int = int(u);				tally[questionResult[u]]++;				playerPoints[userID].add(1);			}						var result:Object = {resultTally:tally, totalPlayers:totalPlayers, userAnswers:questionResult};						// add correct answer if applicable.			if(question.hasOwnProperty("correct")) {				result.correct = question.correct;			}						list.push(result);		}				public function getPollResults():Array		{			var i:int = 0;			var result:Object;			var preppedResults:Array = new Array();			for each(result in list) {				preppedResults.push({tally:result.resultTally, numPlayers:result.totalPlayers});				++i;			}						return preppedResults;		}				public function getQuizResults():Array		{			var i:int = 0;			var result:Object;			var preppedResults:Array = new Array();			for each(result in list) {				preppedResults.push({tally:result.resultTally, userAnswers:result.userAnswers, numPlayers:result.totalPlayers, correctAnswer:result.correct});				++i;				trace("CORRECT ANSWER :: " + result.correct);			}						scores = getUserPoints(preppedResults);						return preppedResults;		}				public function getUserPoints(r:Array):Array		{			var userScores:Dictionary = new Dictionary();			var user:String;						for each(var answer:Object in r)			{				for (user in playerPoints)				{					if(!userScores[user]) userScores[user] = 0;										trace(user + ": " + answer.userAnswers[user] + " >> " + answer.correctAnswer);										if(answer.userAnswers[user]-1 == answer.correctAnswer)					{						trace("CORRECT: " + answer.correctAnswer);						userScores[user] ++;					}				}			}						var s:Array = [];						for (user in userScores) {				trace("USER: " + user);				s.push({uid:int(user), score:userScores[user]});			}						return s;		}				public function addUser(id:int):void		{			if(playerPoints[id]) return;						playerPoints[id] = new PointTally();			playerCount++;		}				public function get numConnectedPlayers():int		{			return playerCount;		}				public function getQuizScores():Array {			var results:Array = getUserPoints(getQuizResults()).sortOn("score", Array.DESCENDING); // force this to execute			return results;		}				// return game type.		public function get contentType():String {			return String(xml.info.@type);		}				public function get name():String {			return String(xml.info.title);		}				public function toString():String		{			return "Results :: " + contentType + " >> " + name + " | RESULTS: " + list;		}	}}