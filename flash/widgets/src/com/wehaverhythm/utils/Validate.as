package com.wehaverhythm.utils
{

	public class Validate extends Object
	{
	
		public function Validate()
		{
			super();
		}
		
		public static function isValidEmail(email:String):Boolean
		{
			// NB: email must be lowercase!
			
		    var emailExpression:RegExp = /([a-z0-9._-]+?)@([a-z0-9.-]+)\.([a-z]{2,4})/;
		    return emailExpression.test(email);
		}
	
	}

}

