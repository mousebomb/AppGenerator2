/**
 * Created by rhett on 16/2/17.
 */
package hdsj
{

	import hdsj.ui.UIMain;
	import org.mousebomb.GameConf;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	/** 升级强化 */
	public class ShengJiModel
	{

		private static var _instance:ShengJiModel;

		public static function getInstance():ShengJiModel
		{
			if( _instance == null )
				_instance = new ShengJiModel();
			return _instance;
		}

		public function ShengJiModel()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
			load();
			//
			GlobalFacade.regListener(NotifyConst.SAVE_TICK,onNSave);
		}

		public var ownShengjiList:Array;

		public function load():void
		{
			var sav:String = SaveFile.getInstance().readFile("shengji");
			if(sav==null)
			{
			}else{
				var savObj:Object = JSON.parse(sav);
				foodLevel=savObj.foodLevel;
				foodNumLevel=savObj.foodNumLevel;
				poolLevel=savObj.poolLevel;
				growUpLevel=savObj.growUpLevel;
				hungryLevel=savObj.hungryLevel;
				wisdomLevel=savObj.wisdomLevel;
			}
			ownShengjiList = [];
			var vo:OwnShengJiVO;
			vo = new OwnShengJiVO();
			vo.name = "食物强化";
			vo.intro = "增大单块食物的含量";
			vo.level = foodLevel;
			vo.percent = foodLevel;
			ownShengjiList[INDEX_FOOD] = vo;
			vo = new OwnShengJiVO();
			vo.name = "食物数量";
			vo.intro = "食物最多放几个";
			vo.level = foodNumLevel;
			vo.percent = foodNumLevel;
			ownShengjiList[INDEX_FOODNUM] = vo;
			vo = new OwnShengJiVO();
			vo.name = "扩大"+GameConf.YUCHANG_LABEL;
			vo.intro = "扩大"+GameConf.YUCHANG_LABEL+"的面积养更多的"+GameConf.FISH_LABEL;
			vo.level = poolLevel;
			vo.percent = poolLevel;
			vo.maxLevel=100;
			ownShengjiList[INDEX_POOLLEVEL] = vo;
			vo = new OwnShengJiVO();
			vo.name = "育成速度";
			vo.intro = "加快"+GameConf.FISH_LABEL+"的成长速度";
			vo.level = growUpLevel;
			vo.percent = growUpPercent;
			ownShengjiList[INDEX_GROWUP] = vo;
			vo = new OwnShengJiVO();
			vo.name = "消化速度";
			vo.intro = "加快"+GameConf.FISH_LABEL+"的饥饿速度";
			vo.level = hungryLevel;
			vo.percent = hungryLevel;
			ownShengjiList[INDEX_HUNGRY] = vo;
			vo = new OwnShengJiVO();
			vo.name = "知识殿堂";
			vo.intro = "增加答题连胜对金币的加成";
			vo.level = wisdomLevel;
			vo.percent = wisdomPercent;
			ownShengjiList[INDEX_WISDOM] = vo;
		}

		public var needSaveFlag:Boolean;
		private function onNSave(n:Notify):void
		{
			if(needSaveFlag) save();
		}

		/** 保存 */
		private function save():void
		{
			var content:String = JSON.stringify({foodLevel:foodLevel,foodNumLevel:foodNumLevel,poolLevel:poolLevel,growUpLevel:growUpLevel,hungryLevel:hungryLevel,wisdomLevel:wisdomLevel});
			SaveFile.getInstance().writeFile("shengji",content);
			needSaveFlag=false;
		}

		/** 升级强化 */
		public function calcShengJiPrice( level:int ):int
		{
			return level * level * 50;
		}


		/** 当前食物等级（一次食物几点） */
		public static const INDEX_FOOD:uint = 0;

		public function get foodPerFood():int {return foodLevel + 2;}

		/** 当前食物等级 */
		public var foodLevel:int = 1;
		/** 食物数量--食物最多放几个 */
		public static const INDEX_FOODNUM:uint = 1;

		public function get foodNum():int {return (foodNumLevel-1)*10+5;}

		public var foodNumLevel:int = 1;
		/** 扩大渔场--扩大渔场的面积养更多的鱼 */
		public static const INDEX_POOLLEVEL:uint = 2;

		public var fishMaxPerPool:int = 15;
		public var poolLevel:int = 1;
		/** 育成速度--加快鱼儿的成长速度（减少升级所需吃的量）*/
		public static const INDEX_GROWUP:uint = 3;
		public var growUpLevel:int = 1;
		public function get growUpPercent():int {return growUpLevel;}
		/** 消化速度--加快鱼儿的饥饿速度 */
		public static const INDEX_HUNGRY:uint = 4;
		public var hungryLevel:int = 1;

		/** 每秒产金币数量，用来计算一定时间内产多少金币(挂机多次产或单次产） */
		public function calcCashPerSec(fishLevel:int):Number
		{
			return (fishLevel * 0.0192 + 0.0808)/6;
		}
		/** 多久产一次金币（秒） */
		public function calcHowLongOutCash( fishLevel:int ):Number
		{
			// 30～60
			return  0.303* fishLevel +29.697;
		}

		/** 饥饿cd （秒） */
		public function calcHungryCD(fishLevel:int):Number
		{
			var realLevel:Number = fishLevel - hungryLevel/5;
			//if(realLevel< -50) realLevel= - 50;
			//此公式越小越饿得慢 [1~100] > [60~0]  强化不够的时候，是负的，则时间长
			var end:Number = 5*realLevel + 5;
			if(end >420.0)
			{
				// 保护不超过1小时
				end = 420.0;
			}else if( end <10.0)
			{
				end = 10.0;
			}
			return end;
		}

		/** 知识殿堂--增加答题连胜对金币的加成 */
		public static const INDEX_WISDOM:uint = 5;
		public var wisdomLevel:int = 1;

		public function get wisdomPercent():int
		{
			return wisdomLevel*2;
		}

		/** 连胜金币奖励 */
		public function calcLianShengJinbiReward( lianSheng:int ):int
		{
			var liansheng :int = lianSheng;//( Math.round(lianSheng/5) ) ;
			return liansheng * (wisdomPercent/100 + 1);
		}
		public function calcJinbiReward(  ):int
		{
			return 5;
		}

		/** 升级 */
		public function upgrade( index:int ):void
		{
			var ownVO:OwnShengJiVO = ownShengjiList[index];
			var curLevel:int = ownVO.level;
			var price:int = calcShengJiPrice( curLevel );
			if( YuChangModel.getInstance().cash < price )
			{
				Game.warning( "金币不够" );
				return;
			}
			if(ownVO.maxLevel <= curLevel)
			{
				Game.warning( "已达最高等级啦" );
				return;
			}
			//
			YuChangModel.getInstance().cash -= price;
			switch( index )
			{
				case INDEX_FOOD:
					foodLevel++;
					break;
				case INDEX_FOODNUM:
					foodNumLevel++;
					break;
				case INDEX_POOLLEVEL:
					poolLevel++;
					YuChangModel.getInstance().buyPool();
					break;
				case INDEX_GROWUP:
					growUpLevel++;
					break;
				case INDEX_HUNGRY:
					hungryLevel++;
					break;
				case INDEX_WISDOM:
					wisdomLevel++;
					break;
			}
			ownVO.level++;
			ownVO.percent = ownVO.level;
			needSaveFlag=true;
			GlobalFacade.sendNotify( NotifyConst.CASH_CHANGED, this, YuChangModel.getInstance().cash );
		}

	}
}
