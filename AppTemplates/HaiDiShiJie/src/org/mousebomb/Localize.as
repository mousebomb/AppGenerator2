package org.mousebomb
{
	import flash.utils.getDefinitionByName;

	/**
	 * @author Mousebomb
	 */
	public class Localize
	{
		/**  */
		private static const _notificationTitle : Object = {"Cn":"我们饿了", "En":"We are hungry"};
		private static const _notificationIntro : Object = {"Cn":"和我一起成长", "En":"Let's grow up together"};
		private static const _notificationAction : Object = {"Cn":"喂养", "En":"feed"};

		public static function get notificationAction() : String
		{
			return _notificationAction[GameConf.LANG];
		}

		static public function get notificationIntro() : String
		{
			return _notificationIntro[GameConf.LANG];
		}

		static public function get notificationTitle() : String
		{
			return _notificationTitle[GameConf.LANG];
		}

		public static function getClass(clazz : String) : Class
		{
			return getDefinitionByName(clazz + GameConf.LANG) as Class;
		}
	}
}
