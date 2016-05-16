package org.mousebomb
{
	import flash.utils.getDefinitionByName;

	/**
	 * @author Mousebomb
	 */
	public class Localize
	{
		/**  */
		private static const _notificationTitle : Object = {"Cn":"来开动脑筋啦", "En":"Let us play"};
		private static const _notificationIntro : Object = {"Cn":"和我一起开发智力", "En":"Let's play"};
		private static const _notificationAction : Object = {"Cn":"玩", "En":"play"};

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
