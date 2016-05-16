/**
 * Created by rhett on 16/2/13.
 */
package hdsj
{

	import flash.utils.getTimer;

	import hdsj.ShengJiModel;

	import hdsj.ShengJiModel;

	public class FishVO
	{

		//类型 1~4
		public var type:int;
		//id 1开始
		public var id:int;
		// 吃过的食物数
		public var eatCount:int;
		// 所属池子 0开始
		public var poolIndex: int ;




		// 饥饿时间cd起始  （秒 UNIX时间戳）
		public var lastFedTime:Number = 0;
		/** 最近产出金币的时刻 */
		public var lastOutCashTime:Number = 0;

		public function FishVO()
		{
		}


		public function calcScale():Number
		{
			var baseScale:Number = type * 0.25;
			var fixLevel : int = calcLevel();
			if(fixLevel>100) fixLevel=100;
			return baseScale * (1+fixLevel/10/type);
		}

		public function calcLevel():int
		{
			// 奔来升级
			if(eatCount<2)
			{
				return 1;
			}else if(eatCount<6) return 2;
			return 0.0833*eatCount/type+2.5;
		}

		/** 一口吃几个 */
		public function calcPerEatNum():int
		{
			//本来一口吃等级个
			var eatNum:int = type*calcLevel();
			if(eatNum<1)eatNum=1;
			return eatNum;
		}

		/** 饿了没 */
		public function isHungry():Boolean
		{
			var hcd :Number = ShengJiModel.getInstance().calcHungryCD(calcLevel())*1000;
			YuChangModel.now = new Date();
//			trace("FishVO/isHungry() type",type,"hcd:",hcd);
			return hcd + lastFedTime < YuChangModel.now.valueOf();
		}

		/** 吃了num量的食物 */
		public function eat( num:int ):void
		{
			YuChangModel.now = new Date();
			lastFedTime = YuChangModel.now.valueOf();
//			trace("FishVO/eat()",num,lastFedTime);
			// 加成
			num = num *(1+ShengJiModel.getInstance().growUpPercent/100);
			this.eatCount+=num;
			//
		}

		/** 计算在线产出金币数量 */
		public function calcOutCash():int
		{
			var sjModel :ShengJiModel= ShengJiModel.getInstance();
			YuChangModel.now = new Date();
			var prdMs:Number = YuChangModel.now.valueOf() - lastOutCashTime;
			var prdSec:Number = prdMs/1000;
			if(prdSec < sjModel.calcHowLongOutCash(calcLevel())){
				//时间没到
				return 0;
			}
			//离线挂机最多8小时，在线更是不在话下
			if(prdSec>3600*8)
			{
				prdSec = 3600*8;
			}
			var cashPerSec:Number = ShengJiModel.getInstance().calcCashPerSec( calcLevel() );
			return cashPerSec * prdSec;
		}

		/** 取出在线产出金币 */
		public function pickOutCash():int
		{
			var cash :int = calcOutCash();
			if(cash < 1)
			{
				// 时间没到产出 ，或产出太少不足1，则等
				return 0;
			}
			lastOutCashTime = YuChangModel.now.valueOf();
			return cash;
		}
	}
}
