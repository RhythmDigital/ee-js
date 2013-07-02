package com.wehaverhythm.utils
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.utils.getQualifiedClassName;
	
	
	public class Debug
	{
		public static var ENABLED:Boolean = true;
		
		
		public function Debug()
		{
		}
		
		/**
		 * Traces out the displayList for this object
		 */
		public static function showDisplayList($displayObject:*):void
		{
			trace("");
			trace("\n**** DISPLAY LIST FOR: " + $displayObject + " ****\n");
			
			for (var i:int=$displayObject.numChildren-1; i >= 0; i--)
			{
				var kid:DisplayObject = $displayObject.getChildAt(i);
				trace(i + ": " + kid + " : " + kid.name);
			}
			
			trace("\n**********");
			trace("");
		}
		
		/**
		 * Takes an object (Array, whatever) and iterates through all its children.
		 */
		
		public static function deepTrace(obj:*, level:int=0, indent:String='    '):String
		{
			var msg:String = '\n';
			var tabs:String = indent;
			
			for (var i:int=0; i<level; ++i) tabs += indent;
			
			for (var prop:String in obj)
			{
				var display:String = obj[ prop ];
				var className:String = getQualifiedClassName((obj[ prop ]));	
				var brace1:String = '';
				var brace2:String = '';
				
				if (className == 'Array') 
				{
					display = className;
					brace1 = ' = [ ';
					brace2 = ' ] ';
				}
				
				if (className == 'Object') 
				{
					display = className;
					brace1 = ' = { ';
					brace2 = ' } ';
				}
				
				msg += tabs + prop + ' : ' + display + brace1;
				msg += deepTrace( obj[ prop ], level + 1 );
				
				if (display == 'Array' || display == 'Object') msg += tabs + brace2 + '\n\n';
			}
			
			return(msg);
		}

		
		/**
		 * Returns the function that called your function.
		 */
		public static function getCallee(calltStackIndex:int=3):String
		{
			var stackLine:String = new Error().getStackTrace().split( "\n" , calltStackIndex + 1 )[calltStackIndex];
			var functionName:String = stackLine.match( /\w+\(\)/ )[0];
			var className:String = stackLine.match( /(?<=\/)\w+?(?=.as:)/ )[0];
			var lineNumber:String = stackLine.match( /(?<=:)\d+/ )[0];
			return className + "." + functionName + ", line " + lineNumber;
		}
		
		/**
		 * Logs to the js console when available; traces if not.
		 */
		public static function log(... args):void // log, info, warn, debug, error
		{			
			if (ENABLED)
			{
				var msg:String = '';
			
				for (var i:int=0; i<args.length; ++i)
				{
					msg += ' ' + args[i];
				}
				
				if (ExternalInterface.available) ExternalInterface.call('console.log', msg);
				else trace(msg);
			}			
		}
		
		public static function logObject(obj:Object):void
		{
			if (ENABLED && ExternalInterface.available) ExternalInterface.call('console.log', obj);
		}
		
		public static function toString():String
		{
			return 'Debug ::';
		}
	}
}