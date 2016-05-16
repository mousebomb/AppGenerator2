/**
 * Created by rhett on 16/2/14.
 */
package
{

	public class NotifyConst
	{

		/**  玩家放食物 */
		public static const PUT_FOOD:String = "PUT_FOOD";
		/** 食物 被吃了 @data 改动后的食物VO */
		public static const EAT_FOOD:String = "EAT_FOOD";

		/** ui刷新金钱 @data = 是否立即闪烁|否就是1秒后闪烁 */
		public static const CASH_CHANGED:String = "CASH_CHANGED";
		/** 池子变化 */
		public static const POOL_CHANGED:String = "POOL_CHANGED";
		/** 池子总数变化 */
		public static const POOL_COUNT_CHANGED:String = "POOL_COUNT_CHANGED";
		/** 买了新的鱼(当前池子) */
		public static const FISH_ADDED_CURPOOL:String = "FISH_ADDED_CURPOOL";


		/** 关闭当前UI */
		public static const CLOSE_POPUP_UI:String = "CLOSE_POPUP_UI";
		/** 题目变更 */
		public static const QUESTION_CHANGED:String = "QUESTION_CHANGED";


		/** 定是保存 */
		public static const SAVE_TICK:String = "SAVE_TICK";
		/** 壁纸换  URL:String 或 Class */
		public static const BG_CHANGED:String = "BG_CHANGED";

		public function NotifyConst()
		{
		}
	}
}
