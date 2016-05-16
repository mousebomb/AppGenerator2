package game.model
{
	import game.model.vo.DailyResultVO;

	import org.mousebomb.GameConf;
	import org.mousebomb.utils.btrace;
	import org.robotlegs.mvcs.Actor;

	import flash.net.SharedObject;
	import flash.utils.Dictionary;

	/**
	 * @author Mousebomb
	 */
	public class DailyResultModel extends Actor
	{
		/**
		 * 最近30天每天的日数据,跟so同步
		 */
		public var calendar : Dictionary;
		// 每天的毫秒数
		private var secPerDay : Number = 1000 * 60 * 60 * 24;
		private var before29Days : Number ;
		private static var so : SharedObject;

		public function DailyResultModel()
		{
			listMyEachDay();
		}

		/**
		 * 最近30天列表
		 */
		public function getRecent30DaysList() : Vector.<DailyResultVO>
		{
			var end : Vector.<DailyResultVO> = new Vector.<DailyResultVO>();
			var now : Number = new Date().time;
			before29Days = now - 29 * secPerDay;
			for (var i : Number = before29Days; i <= now; i += secPerDay)
			{
				end.push(getDayResult(new Date(i)));
			}
			return end;
		}

		// 从cookie读取
		private function listMyEachDay() : void
		{
			so = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			calendar = new Dictionary();
			if (so.data['calendar'] == null)
			{
				so.data['calendar'] = {};
			}
			else
			{
				var tmp : Object = so.data['calendar'];
				// 如果超出30天，则清掉30天前的
				var now : Number = new Date().time;
				before29Days = now - 29 * secPerDay;
				for (var k:String in tmp)
				{
					var vo : DailyResultVO  = DailyResultVO.decode(tmp[k]);
					if (vo.date.time >= before29Days)
						calendar[generateKey(vo.date)] = vo;
					else
					{
						// 老的 cls掉
						delete so.data['calendar'][k];
					}
				}
			}
		}

		/**
		 * 保存今日数据
		 */
		private function saveTodayResult(vo : DailyResultVO) : void
		{
			var k:String = generateKey(vo.date); 
			calendar[k] = vo;
			so.data['calendar'][k] = vo;
			so.flush();
		}

		/**
		 * 今日数据追加
		 * @param addCorrectAnswer 追加正确答案数量
		 * @param addTotalAnswer 追加答题数量
		 */
		public function addToToday(date : Date, addTotalAnswer : int, addCorrectAnswer : int) : void
		{
			var dailyResultVO : DailyResultVO = getDayResult(date);
			dailyResultVO.correctAnswer += addCorrectAnswer;
			dailyResultVO.totalAnswer += addTotalAnswer;
			dailyResultVO.isPlayed = true;
			calcImproveThanBefore(dailyResultVO);
			saveTodayResult(dailyResultVO);
			btrace("今日数据变化", dailyResultVO);
		}

		/**
		 * 计算得 比上次提升了多少 百分比  0.0-9999.0
		 */
		private function calcImproveThanBefore(vo : DailyResultVO) : void
		{
			vo.improved = vo.correctPer;
			// 找出之前的
			for (var i : Number = vo.date.time - secPerDay; i >= before29Days; i -= secPerDay)
			{
				var lastTime : DailyResultVO = getDayResult(new Date(i));
				if (lastTime.isPlayed)
				{
					vo.improved = vo.correctPer - lastTime.correctPer;
					return;
				}
			}
		}

		/**
		 * 创建的key保证每天一个
		 */
		private function generateKey(date : Date) : String
		{
			return date.fullYear + "-" + date.month + "-" + date.date;
		}

		/**
		 * 获得今日数据 (无则创建)
		 * @param date 今日的任何一秒钟
		 */
		public function getDayResult(date : Date) : DailyResultVO
		{
			// btrace("DailyResultModel/getDayResult", date);
			var key : String = generateKey(date);
			if (null == calendar[key])
			{
				calendar[key] = new DailyResultVO(date);
				if(CONFIG::DEBUG)
				{
					var vo : DailyResultVO = calendar[key];
					vo.isPlayed=true;
					calendar[key] = vo;
				}
			}
			return calendar[key];
		}
	}
}
