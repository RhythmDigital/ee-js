package com.wehaverhythm.utils
{
	import com.dynamicflash.util.Base64;
	
	
	public class Crypto
	{
		public static var KEY:String = "HjRUPxRjRUPxRdVDYFdVDFS0HjRUPxRdVDYF6PkFBK3YlXjc"
		
		
		public function Crypto()
		{
		}
		
		
		public static function xor(source:String):String
		{
			var key:String = KEY;
			var result:String = new String();
			for(var i:Number = 0; i < source.length; i++) {
				if(i > (key.length - 1)) {
					key += key;
				}
				result += String.fromCharCode(source.charCodeAt(i) ^ key.charCodeAt(i));
			}
			return result;
		}
		

		public static function encrypt(txtToEncrypt:String):String
		{	
			return Base64.encode(xor(txtToEncrypt));	
		}
		
		
		public static function decrypt(txtToDecrypt:String):String
		{
			return xor(Base64.decode(txtToDecrypt)); 
		}
	}
}