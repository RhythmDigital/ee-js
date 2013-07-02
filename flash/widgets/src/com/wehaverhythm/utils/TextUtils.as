package com.wehaverhythm.utils
{
	public class TextUtils
	{
		public function TextUtils()
		{
		}
		
		//word count  
		public static function wordCountString($string:String):Number {  
			var tmp:Array = $string.split(" ");  
			for (var i:int = tmp.length; i>0; i--) {  
				if (tmp[i] == "") {  
					tmp.splice(i,1);  
				}  
			}  
			return tmp.length;  
		} 
	}
}