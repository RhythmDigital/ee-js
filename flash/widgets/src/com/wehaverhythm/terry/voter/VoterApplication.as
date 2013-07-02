package com.wehaverhythm.terry.voter
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quad;
	import com.wehaverhythm.air.AssetFolderLoader;
	import com.wehaverhythm.gui.ClockFaceTimer;
	import com.wehaverhythm.playnow.PlayNowEvent;
	import com.wehaverhythm.playnow.PlayNowSocket;
	import com.wehaverhythm.terry.generic.GameBaseNative;
	import com.wehaverhythm.terry.voter.results.Results;
	import com.wehaverhythm.terry.voter.results.ResultsDisplay;
	import com.wehaverhythm.utils.CustomEvent;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import starling.core.Starling;
	
	
	public class VoterApplication extends GameBaseNative
	{
		private const TIMER_LENGTH:int = 10;
		private const FADE_IN_TIME:Number = 0.5;
		private const FADE_OUT_TIME:Number = 0.5;
		private const PAUSE_TIME:Number = 1;
		
		private const END_SCREENS:Array = [ResultsPollBasicDisplay, ResultsQuizBasicDisplay];
		
		private var questionMaster:QuestionMaster;
		private var displays:Array;

		private var currentDisplay:VotesDisplay;
		private var graphBarCentre:GraphBarCentreDisplay;
		private var scales:ScalesMainDisplay;
		private var barLeft:BarsLeftDisplay;
		private var standardQuest:StandardQuestionDisplay;
		private var endOfQuestionScreen:EndOfQuestionDisplay;
		private var endOfRoundScreen:ResultsDisplay;

		private var autoVote:Boolean;
		private var autoVoteTimer:Timer;
		private var question:Object;
		private var answers:Dictionary;
		private var adminKeysCallback:Function;
		
		private var questionActive:Boolean = false;
		private var splashScreen:SplashScreen;
		private var timer:ClockFaceTimer;
		private var hint:Sprite;
		private var selectedQuiz:String = "";
		private var voterMenu:ChooseContent;
		private var results:Results;
		
		public function VoterApplication()
		{
			super();
			
			trace("Voter Application");
			
			minPlayers = 1;
			PlayNowSocket.VERBOSE = false;
			autoVote = false;
			
			timer = new ClockFaceTimer();
			timer.create({x:0, y:0, color:0xffffff, radius:70});
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onNotifyQuestionEnd);
		
			
			// DRAW HINT RECT
			hint = new Sprite();
			
			with(hint.graphics) {
				beginFill(0xff0000, 1);
				drawRect(-12,-12,24,24);
				endFill();
			}
		}
		
		private function initDisplays():void
		{			
			trace("Init displays!");
			
			graphBarCentre = new GraphBarCentreDisplay();
			addChild(graphBarCentre);
			
			scales = new ScalesMainDisplay();
			addChild(scales);
			
			standardQuest = new StandardQuestionDisplay();
			addChild(standardQuest);
			
			barLeft = new BarsLeftDisplay();
			addChild(barLeft);
			
			displays = [graphBarCentre, scales, barLeft, standardQuest];
		}
		
		override protected function waitForPlayers():void
		{
			super.waitForPlayers();
		}
		
		private function showSplashScreen():void
		{
			splashScreen = new SplashScreen();
			splashScreen.alpha = 0;
			splashScreen.blendMode = BlendMode.LAYER;
			TweenMax.fromTo(splashScreen, 2, {alpha:0}, {alpha:1, ease:Quad.easeOut, overwrite:2});
			updateSplashScreen();
			addChild(splashScreen);
		}
		
		private function nextQuestion():void
		{
			question = questionMaster.getNextQuestion();
			answers = new Dictionary();
			
			questionActive = true;
			
			switch (question.display)
			{
				case QuestionMaster.SCALES:
					switchDisplay(question, scales);
				break;
				
				case QuestionMaster.BAR_FROM_CENTRE:
					switchDisplay(question, graphBarCentre);
				break;
				
				case QuestionMaster.STANDARD_QUESTION:
					switchDisplay(question, standardQuest);
				break;
				
				case QuestionMaster.BAR_LEFT:
					switchDisplay(question, barLeft);
					break;
				
				default:
					throw(new Error("CANT FIND DISPLAY " + question.display));
			}
		}
		
		override public function addPlayer(d:Object):void
		{
			//super.addPlayer(d);
			results.addUser((d.id));
			
			++numPlayers;
			if(currentDisplay) currentDisplay.updatePlayerCount(numPlayers);
			
			trace("numPlayers",numPlayers);
			
			updateSplashScreen();

			trace("Question active? " + questionActive);
			if(questionActive) {
				questionMaster.askQuestionTo(d.id, answers[d.id]);
			}
		}
		
		private function updateSplashScreen():void
		{
			if(splashScreen) {
				splashScreen.playersConectedTF.text = String(numPlayers)+" PLAYERS CONNECTED";
			}
		}
		
		override protected function startCountdown():void
		{
			// cancel countdown!
		}
		
		override public function resetGame():void
		{
			super.resetGame();
			
			trace("Resetting VoterApplication");
			
			if (!questionMaster)
			{
				questionMaster = new QuestionMaster();
				questionMaster.addEventListener(DISPATCH_EVENT_TO_ALL, bubbleCustomEvent);
				questionMaster.addEventListener(DISPATCH_EVENT_TO_USER, bubbleCustomEvent);
				initDisplays();
				
				endOfQuestionScreen = new EndOfQuestionDisplay();
			}
			
			results = new Results();
			
			chooseContent();
		}
		
		private function chooseContent():void
		{
			trace("Choose Content...");
			
			if(voterMenu == null) {
				voterMenu = new ChooseContent();
				prepMenuButtons();
			} else {
				voterMenu.mouseChildren = voterMenu.mouseEnabled = true;
			}
			
			voterMenu.alpha = 0;
			addChild(voterMenu);
			TweenMax.to(voterMenu, FADE_IN_TIME, {autoAlpha:1, onComplete:function():void{
				trace("ready.");
				Mouse.show();
			}});
			
		}
		
		private function prepMenuButtons():void
		{
			var q:Array = VoterConstants.FILES;
			
			var totalHeight:int = voterMenu.header.height;
			
			for(var i:int = 0; i < q.length; ++i)
			{
				trace("BUTTON: " + AssetFolderLoader.getXML(q[i]).info.title);
				var btn:ContentButton = new ContentButton();
				btn.txtTitle.text = AssetFolderLoader.getXML(q[i]).info.title;
				btn.identifier = q[i];
				btn.x = -(btn.width >> 1);
				totalHeight += 18;
				btn.y = totalHeight;
				totalHeight += btn.height;
				voterMenu.header.addChild(btn);
				btn.addEventListener(MouseEvent.CLICK, onMenuClicked);
			}
			
			voterMenu.header.y = (voterMenu.height >> 1) - (voterMenu.header.height >> 1);
		}
		
		protected function onMenuClicked(e:MouseEvent):void
		{
			trace("Selected: " + e.target.identifier);
			voterMenu.mouseChildren = voterMenu.mouseEnabled = false;
			
			selectedQuiz = e.target.identifier;
			
			var qm:QuestionMaster = questionMaster;
			qm.initQuestions(selectedQuiz);
			
			results.initXML(qm.xml);
			
			TweenMax.to(voterMenu, FADE_OUT_TIME, {autoAlpha:0, onComplete:function():void{
				showSplashScreen();
				
				startGame();
				
				waitForAdmin(function():void{
					trace("STARTED!");
					TweenMax.to(splashScreen, FADE_OUT_TIME, {alpha:0, ease:Quad.easeOut, overwrite:2, onComplete:function():void{
						removeChild(splashScreen);
						nextQuestion();
						askQuestion();
					}});
				});
			}});
		}
		
		override protected function startGame():void
		{
			super.startGame();	
			
			answers = new Dictionary();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onAdminKeyDown);
		}
		
		override protected function endGame(winnerId:uint=0, data:Object = null):void
		{
			super.endGame(winnerId);
		}
		
		private function askQuestion():void
		{			
			questionMaster.askQuestion();
			currentDisplay.showGraph();
			
			// start timer
			if (autoVote) initAutoVote();
			
			TweenMax.delayedCall(PAUSE_TIME, function():void{
				waitForAdmin(function():void{
					// question ended
					trace("Question ended.");
					timer.startTimer(TIMER_LENGTH);
					addChild(timer);
				});
			});
			
		}
		
		private function onNotifyQuestionEnd(e:Event):void
		{
			removeChild(timer);
			timer.resetTimer(TIMER_LENGTH,false);
			
			questionActive = false;
			
			var data:Object = {contentType:questionMaster.type};
			
			// QUIZ RESULTS
			if(data.contentType == "poll") {
				data.results = calculatePollResults();
				
			} else if(data.contentType == "quiz") {
				// need correct answer?
				
			}
			
			dispatchEvent(new CustomEvent(GameBaseNative.DISPATCH_EVENT_TO_ALL, {type:'quest_results', params:data}));
			
			TweenMax.delayedCall(PAUSE_TIME, nextQuestionTrigger);
		}
		
		private function calculatePollResults():Array
		{
			var answerTally:Array = new Array(questionMaster.numAnswers);
			var total:int = 0;
			
			for(var i:int = 0; i < answerTally.length; ++i) {
				answerTally[i] = 0;
			}
			
			for(var u:String in answers) {
				answerTally[answers[u]-1] ++;
				total ++;
			}
			
			for(var j:int = 0; j < answerTally.length; ++j) {
				var val:int = Math.round((answerTally[j] / total)*100);
				//trace("valvalval: " + val);
				answerTally[j] = val; // percentages. 2 decimal places.
			}
			
			trace("ANSWERS: " + answerTally);
			
			return answerTally;
		}
		
		private function nextQuestionTrigger():void
		{
			//waitForAdmin(function():void{
				// question ended
				trace("Next Question.");
				
				if(questionMaster.isFinalQuestion()) {
					TweenMax.to(currentDisplay, FADE_OUT_TIME, {alpha:0, ease:Quad.easeOut, overwrite:2});
					endOfQuestion(true);
				} else {
					
					endOfQuestion();
					
				}		
			//});
		}
		
		private function endOfQuestion(roundEnded:Boolean = false):void
		{
			results.addQuestionResult(answers, questionMaster.question, numPlayers);
			
			TweenMax.to(currentDisplay, FADE_OUT_TIME, {autoAlpha:0, ease:Quad.easeOut, onComplete:function():void{
				
				if(currentDisplay) currentDisplay.reset();
				showEndOfQuestion(roundEnded);
				
			}});
		}
		
		private function showEndOfQuestion(roundEnded:Boolean):void
		{
			addChild(endOfQuestionScreen);
			endOfQuestionScreen.alpha = 0;
			
			TweenMax.to(endOfQuestionScreen, FADE_IN_TIME, {autoAlpha:1, onComplete:function():void{
				waitForAdmin(function():void{
					hideEndOfQuestionScreen(roundEnded);
				});
			}});
		}
		
		private function hideEndOfQuestionScreen(roundEnded:Boolean):void
		{
			TweenMax.to(endOfQuestionScreen, FADE_OUT_TIME, {autoAlpha:0, onComplete:function():void{
				removeChild(endOfQuestionScreen);
				
				if(roundEnded) {
					endOfRound();
				} else {
					nextQuestion();
					askQuestion();
				}
			}});
		}
				
		private function endOfRound():void
		{
			trace("End of round");
			
			//dispatchEvent(new CustomEvent(GameBaseNative.GAME_OVER, {event:"end"}));
			
			endOfRoundScreen = getEndOfRoundScreen();
			addChild(endOfRoundScreen);
			endOfRoundScreen.init(results);
			endOfRoundScreen.alpha = 0;
			
			var eventProps:Object = {event:"end", type:questionMaster.type};
			
			if(questionMaster.type == "poll") {
				dispatchEvent(new CustomEvent(GameBaseNative.GAME_OVER, eventProps));
				
			} else if(questionMaster.type == "quiz") {
				eventProps.results = results.getQuizScores();
				eventProps.numPlayers = results.numConnectedPlayers;
				dispatchEvent(new CustomEvent(GameBaseNative.GAME_OVER, eventProps));
			}
			
			TweenMax.to(endOfRoundScreen, FADE_IN_TIME, {autoAlpha:1, onComplete:function():void{
				waitForAdmin(function():void{
					hideEndOfRoundScreen();
				});
			}});
			
		}
		
		private function getEndOfRoundScreen():ResultsDisplay
		{
			var resultsDisplay:ResultsDisplay;
			/*
			switch(questionMaster.resultsDisplay) {
				case "ResultsDisplayDefault":
					break;
				default:
					throw(new Error("I can't recognise  " + questionMaster.resultsDisplay + "."));
			}
			*/
			var RD:Class;
			
			try {
				RD = getDefinitionByName(questionMaster.resultsDisplay) as Class;
				resultsDisplay = new RD();
			} catch (e:Error) {
				throw(new Error("Make sure " + questionMaster.resultsDisplay + "'s class is activated!\n" + e.getStackTrace()));
			}
			
			return resultsDisplay;
		}
		
		private function hideEndOfRoundScreen():void
		{
			TweenMax.to(endOfRoundScreen, FADE_OUT_TIME, {autoAlpha:0, onComplete:function():void{
				trace("Resetting game.");
				
				removeChild(endOfRoundScreen);
				endOfRoundScreen.destroy();
				endOfRoundScreen = null;
				
				resetGame();
			}});
		}
		
		private function initAutoVote():void
		{
			autoVoteTimer = new Timer(200);
			autoVoteTimer.addEventListener(TimerEvent.TIMER, onAutoVoteTimerTick);
			autoVoteTimer.start();
		}
		
		protected function onAutoVoteTimerTick(e:TimerEvent):void
		{
			e.target.delay = 100 + Math.random()*1000;
			currentDisplay.registerVote(String(Math.floor(Math.random()*5)));
		}
		
		private function switchDisplay(q:Object, display:VotesDisplay):void
		{			
			trace("SHOW DISPLAY: " + display);
			for each (var d:VotesDisplay in displays)
				d.reset();
				
			currentDisplay = display;
			currentDisplay.show(q, questionMaster.current, questionMaster.total);
			currentDisplay.updatePlayerCount(numPlayers);
			display.addChild(timer);
			
			placeTimerIn(currentDisplay);
		}
		
		private function placeTimerIn(votesDisplay:VotesDisplay):void
		{
			votesDisplay.timerPosition.visible = false;
			
			timer.x = votesDisplay.timerPosition.x;
			timer.y = votesDisplay.timerPosition.y;
			timer.radius = votesDisplay.timerPosition.width;
			//if(show) {
			votesDisplay.addChild(timer);
			timer.fill();
			timer.resetTimer(TIMER_LENGTH, false);
			//}
		}
		
		private function onAdminKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.SPACE && adminKeysCallback != null) {
				trace("ADMIN SPACEBAR PRESSED.");
				var temp:Function = adminKeysCallback;
				adminKeysCallback = null;
				temp();
			}
		}
		
		private function waitForAdmin(callback:Function):void
		{
			trace("WAITING FOR ADMIN SPACEBAR.");
			showHint = true;
			adminKeysCallback = function():void{
				showHint = false;
				callback();
			};
		}
		
		private function set showHint(show:Boolean):void
		{
			if(show) {
				addChild(hint);
				hint.alpha = 0;
				hint.x = stage.stageWidth - (hint.width+10);
				hint.y = stage.stageHeight - (hint.height+10);
				hint.scaleX = hint.scaleY = 0;
				
				TweenMax.to(hint, .2, {scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, overwrite:2});
			} else {
				if(this.contains(hint)) {
					TweenMax.to(hint, .25, {alpha:0, ease:Quad.easeOut, overwrite:2, onComplete:function():void{
					
						removeChild(hint);
					
					}});
				}
			}
		}
		
		public function registerVote(e:PlayNowEvent):void
		{
			// Only allow votes if the question is active.
			if(questionActive) {
				currentDisplay.registerVote(String(e.data));
				
				// never use zero in here, it's the same as undefined in a Dictionary...
				// ... so add one, and subtract it later so answers[e.userID] works.
				answers[e.userID] = int(e.data)+1;			
				
			} else {
				trace(new Error("Vote submitted when question is closed."));
			}
		}
	}
}