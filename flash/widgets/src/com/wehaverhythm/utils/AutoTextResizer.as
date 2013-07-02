package com.wehaverhythm.utils
{
	import com.greensock.TweenMax;
	import com.wehaverhythm.utils.MinMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class  AutoTextResizer extends Sprite
	{
		private var textLimits:MinMax = new MinMax(20, 800);	
		private var size:Number;
		private var textFormat:TextFormat;
		private var lastText:String;
		public  var initText:String = "THIS IS A QUESTION";
		private var showPublishOnNextChange:Boolean;
		private var impact:Font;
		private var textField:TextField;
		private var dummyTextField:TextField;
		private var usableWidth:Number;
		private var fitAreaHeight:Number;
		private var marginY:Number;
		
		public function AutoTextResizer(position:*, marginX:Number = 0, color:uint = 0xffffff, tAlign:String = "center")
		{
			
			
			var fitAreaWidth:Number = position.width;
			var fitAreaHeight:Number = position.height;
			x = position.x;
			y = position.y;
			tint(color);
			//trace("MAIN INIT");
			
			Font.registerFont(ImpactF);
			impact = new ImpactF() as Font;
			
			
			textField = new TextField();
			textField.type = "dynamic";
			textField.selectable = false;
			
			
			var left:Number = marginX;
			usableWidth = fitAreaWidth - (marginX*2);
			var right:Number = left+usableWidth;
			
			textField.x = left;
			
			this.fitAreaHeight = fitAreaHeight;
			
			dummyTextField = new TextField();
			dummyTextField.width = textField.width = usableWidth;
			dummyTextField.height = textField.height = fitAreaHeight;
			
			addChild(textField);
			addChild(dummyTextField);
			
			//textField.selectable = dummyTextField.selectable = false;
			
			
			dummyTextField.visible = false;
			
			textField.wordWrap = textField.multiline = dummyTextField.wordWrap = dummyTextField.multiline = true;
			textField.addEventListener(Event.CHANGE, onTextChange);
			
			size = textLimits.max;		
			textFormat = new TextFormat();
			textFormat.align = tAlign;
			textFormat.font = impact.fontName;
			textFormat.color = "0xFFFFFF"
			
			setText(initText);
			onTextChange();
		}
		
		public function tint(col:uint):void
		{
			TweenMax.to(this, 0, {immediateRender:true, overwrite:2, tint:col});
		}
		
		private function onTextChange(e:Event = null):void
		{
			fitText(textField.text.toUpperCase());
			adjustSizeForLongWords();
			//setText(lastText);
			
		}
		
		private function fitText(text:String):void
		{
			textField.width = usableWidth;
			size = textLimits.max;			
			setText(text);
			
			while (textField.textHeight > textField.height*.95 && size > textLimits.min)
			{
				size *= .99;
				setText(text);
				// trace("\t=======> textHeight:", textField.textHeight, "height:", textField.height, "text size:", size);
			}
			
			if (textField.textHeight > textField.height*.95) fitText(lastText);
			lastText = textField.text;
			
			textField.width+=10;
		}
		
		private function adjustSizeForLongWords():void
		{
			var words:String = escape(textField.text);
			
			var myPattern:RegExp = /%0D/gi; 
			words = unescape(words.replace(myPattern, "%20"));
			
			var wordsList:Array = words.split(" ");
			var longestWord:String = "";
			
			for (var i:int=0; i < wordsList.length; ++i)
			{
				if (wordsList[i].length > longestWord.length) longestWord = wordsList[i];
			}
			
			// make it fit on a single line
			setDummyText(longestWord);
			
			while (dummyTextField.numLines > 1 && size > textLimits.min)
			{
				size *= .99;
				setDummyText(longestWord);
				
				 //trace("\t\t\t==> trying text size:", size, "LINES:", dummyTextField.numLines);
			} 
		}
		
		public function newString(text:String):void
		{
			setText(text);
			onTextChange();
		}
		
		private function setText(text:String):void
		{
			textFormat.size = size;
			textFormat.leading = Math.max(-13, -size/10); // trace(textFormat.leading);
		//	textFormat.letterSpacing = Math.max(-6, -size/10);
			textField.defaultTextFormat = textFormat;
			textField.text = text;
			
			
			//trace(textField.textWidth);
			//trace("\t"+textField.width);
			
			//textField.width = textField.textWidth;
			
			textField.y = getOffsetY(textField);
			
			//textField.y = 0;//15 + 170 - textField.textHeight/2;
					
		}
		
		private function getOffsetY(tf:TextField):Number
		{
			//tf.height = tf.textHeight;
			
			tf.borderColor = 0xffffff;
			//tf.border = true;
			
			var newY:Number = (fitAreaHeight-(tf.height)); 
			
			//tf.height = fitAreaHeight;
			
			return newY;
		}
		
		private function setDummyText(text:String):void
		{
			textFormat.size = size;
			textFormat.leading = -size/20;
			textFormat.letterSpacing = Math.max(-6, -size/30);
			dummyTextField.defaultTextFormat = textFormat;
			dummyTextField.text = text;
			
		//	dummyTextField.y = += 15 + 170 - dummyTextField.textHeight/2
			
			dummyTextField.y = getOffsetY(dummyTextField)//(fitAreaHeight>>1) + (fitAreaHeight-textField.textHeight);
		}
		
		public function get textBottom():Number
		{
			return y + textField.y + textField.textHeight;
		}
		
		public function get textBoxWidth():Number
		{
			return textField.width;
		}
		
	}
}
