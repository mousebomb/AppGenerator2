package tiezhi
{
	/**
	 * @author rhett
	 */
	public class ChengYuTimu
	{
		public static const CHENGYU : String = <![CDATA[${ChengYuTiMu}]]>;

		private static var timuArr :Array;
		public static const LINE: String = "-";

		public static function init() : void
		{
			timuArr = CHENGYU.split("==");
		}
		init();

		public static function getTextForPicI(i : int) : String
		{
			var timu  :String = timuArr[ int((i-1)/4) ];
			var chengyu :String = timu.split("-")[0];
			return chengyu.substr( (i-1)%4,1);
		}
		
		public static function getLevelName(level : int ):String
		{
			var timu  :String = timuArr[level-1];
			return timu.split("-")[0];
		}
		public static function getLevelDesc(level : int ):String
		{
			var timu  :String = timuArr[level-1];
            var str :String = timu.substr( timu.indexOf("-") );
            return str.split("-").join("\n");
		}

		public static function getLevels() : uint
		{
			return timuArr.length;
		}
	}
}
