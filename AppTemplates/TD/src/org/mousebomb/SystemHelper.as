package org.mousebomb
{
	import flash.system.Capabilities;

	/**
	 * @author rhett
	 */
	public class SystemHelper
	{
		public static function isIOS() : Boolean
		{
			var isIOS : Boolean = Capabilities.os.indexOf("iPhone") != -1;
			if (Capabilities.os.indexOf("iPad") != -1)
				isIOS = true;
			return isIOS;
		}

		public static function isDesktop():Boolean
		{
			if(Capabilities.os.indexOf("Mac OS") != -1) return true;
			return false;
		}


	}
}
