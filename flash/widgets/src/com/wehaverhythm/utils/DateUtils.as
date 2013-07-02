package com.wehaverhythm.utils
{
	public class DateUtils
	{
		public function DateUtils()
		{
		}
		
		public static function compareDates (date1 : Date, date2 : Date) : Number
		{
			var date1Timestamp : Number = date1.getTime ();
			var date2Timestamp : Number = date2.getTime ();
			
			var result : Number = -1;
			
			if (date1Timestamp == date2Timestamp)
			{
				result = 0;
			}
			else if (date1Timestamp > date2Timestamp)
			{
				result = 1;
			}
			
			return result;
		}
		
		public static function getDaysBetweenDates(date1 : Date, date2 : Date) : int
		{
			var days:Number = 0;
			var timeDiff:Number = date1.valueOf() - date2.valueOf();
			days = timeDiff / (24*60*60*1000);
			
			return days;			
		}
	}
}