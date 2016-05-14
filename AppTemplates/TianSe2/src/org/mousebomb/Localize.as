package org.mousebomb
{
	import flash.utils.getDefinitionByName;

	/**
	 * @author Mousebomb
	 */
	public class Localize
	{
		ReplayBtnCn;
		ReplayBtnEn;
		MoreBtnCn;
		MoreBtnEn;
		ReplayConfirmCn;
		ReplayConfirmEn;
		LevelItemCn;
		LevelItemEn;
		public static function getClass(clazz : String) : Class
		{
			return getDefinitionByName(clazz + GameConf.LANG) as Class;
		}

		public static function get LevelItem() : Class
		{
			return getClass("LevelItem");
		}
		ColorSfxEn;
		ColorSfxCn;
		public static function get ColorSfx() : Class
		{
			return getClass("ColorSfx");
		}
		PicSfxCn;
		PicSfxEn;
		public static function get PicSfx() : Class
		{
			return getClass("PicSfx");
		}
		
		
		
		
		//
		/**  */
		private static const _notificationTitle : Object = {"Cn":"填色时间", "En":"Painting time"};
		private static const _notificationIntro : Object = {"Cn":"天天来填色，越填越快乐", "En":"We need to paint"};
		private static const _notificationAction : Object = {"Cn":"填色", "En":"paint"};

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
	}
}
