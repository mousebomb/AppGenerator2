package game.model.vo
{
	import org.mousebomb.utils.DateAndTime;

	/**
	 * 每日总结果
	 * @author Mousebomb
	 */
	public class DailyResultVO
	{
		public function DailyResultVO(date_ : Date)
		{
			this.date = date_;
		}

		/**
		 * 这天是否玩了
		 */
		public var isPlayed : Boolean = false;
		/**
		 * 做题的日期
		 */
		public var date : Date;

		public function get dateYmd() : String
		{
			return DateAndTime.formatDate("%Y年%m月%d日", date);
		}

		public function get weekday() : String
		{
			switch( date.day)
			{
				case 0:
					return "星期日";
				case 1:
					return "星期一";
				case 2:
					return "星期二";
				case 3:
					return "星期三";
				case 4:
					return "星期四";
				case 5:
					return "星期五";
				case 6:
					return "星期六";
			}
			return "";
		}

		// 本次游戏 总答题次数
		public var totalAnswer : int = 0;
		// 答题正确次数
		public var correctAnswer : int = 0;
		/**
		 * 比上次提升了多少 百分比  0.0-9999.0
		 */
		public var improved : Number = 0.0;

		/**
		 * 正确率  0.0-100.0
		 */
		public function get correctPer() : Number
		{
			if (totalAnswer == 0)
			{
				return 0.0;
			}
			return correctAnswer / totalAnswer * 100;
		}

		public function encode() : Object
		{
			var end : Object = {totalAnswer:totalAnswer, correctAnswer:correctAnswer, improved:improved, date:date.time, isPlayed:isPlayed};
			return end;
		}

		public static function decode(obj : Object) : DailyResultVO
		{
			var end : DailyResultVO = new DailyResultVO(new Date(obj.date));
			end.totalAnswer = obj.totalAnswer;
			end.correctAnswer = obj.correctAnswer;
			end.improved = obj.improved;
			end.isPlayed = obj.isPlayed;
			return end;
		}
	}
}
