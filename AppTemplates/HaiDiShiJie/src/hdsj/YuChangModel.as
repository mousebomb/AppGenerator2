/**
 * Created by rhett on 16/2/12.
 */
package hdsj
{

	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.system.ApplicationDomain;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	import hdsj.FoodVO;
	import hdsj.OwnFishVO;
	import hdsj.ShengJiModel;

	import org.mousebomb.Math.MousebombMath;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;
	import org.mousebomb.structure.HashMap;
	import org.mousebomb.utils.MappingObject;

	public class YuChangModel
	{

		private static var _instance:YuChangModel;

		public static function getInstance():YuChangModel
		{
			if( _instance == null )
				_instance = new YuChangModel();
			return _instance;
		}

		public function YuChangModel()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
			initAllFishList();
			load();
			//
			GlobalFacade.regListener( NotifyConst.SAVE_TICK, onNSave );
		}
		private var autoPlayTick:Timer;

		public var needSaveFlag:Boolean;

		private function onNSave( n:Notify ):void
		{
			if( needSaveFlag ) save();
		}

		/** 当前所有池堂总容纳数 */
		public function get fishPoolOpenCapacity():int
		{
			return ShengJiModel.getInstance().fishMaxPerPool * fishPoolOpenCount;
		}

		/** 已购买的鱼塘 */
		public function get fishPoolOpenCount():int
		{return fishInPool.length;}

		/** 各个鱼塘里的鱼   [鱼塘索引][鱼们FishVO] */
		public var fishInPool:Array = [];

		/** 各个鱼塘里的食物 [鱼塘索引][食物FoodVO] */
		public var foodsInPool:Array = [];

		public function getFishInCurPool():Array
		{
			return fishInPool[_curPoolIndex];
		}

		public function getFoodInCurPool():Array
		{
			return foodsInPool[_curPoolIndex];
		}

		private function save():void
		{
			var sav:Object = {fish:fishInPool, food:foodsInPool, cash:_cash};
			var savStr:String = (JSON.stringify( sav ));
			SaveFile.getInstance().writeFile( "yuchang", savStr );
			needSaveFlag = false;
		}

		public function load():void
		{
			var yuchangSav:String = SaveFile.getInstance().readFile( "yuchang" );
			if( yuchangSav == null )
			{
				initSavData();
			} else
			{
				var sav:Object = JSON.parse( yuchangSav );
				fishInPool = [];
				for( var i:int = 0; i < sav.fish.length; i++ )
				{
					var fishInEachPoolSav:Array = sav.fish[i];
					var fishInEachPool:Array = [];
					for( var j:int = 0; j < fishInEachPoolSav.length; j++ )
					{
						var fishVO:FishVO = MappingObject.doRequest( FishVO, fishInEachPoolSav[j] );
						fishInEachPool.push( fishVO );
					}
					fishInPool.push( fishInEachPool );
				}
				foodsInPool = [];
				for( i = 0; i < sav.food.length; i++ )
				{
					var foodInEachPoolSav:Array = sav.food[i];
					var foodInEachPool:Array = [];
					if(foodInEachPoolSav)
					{
						for( j = 0; j < foodInEachPoolSav.length; j++ )
						{
							var foodVO:FoodVO = MappingObject.doRequest( FoodVO, foodInEachPoolSav[j] );
							foodInEachPool.push( foodVO );
						}
					}
					foodsInPool.push( foodInEachPool );
				}
				_cash = sav.cash;
				//
				for(i=0;i<fishPoolOpenCount;i++)
				{
					autoPlay( i );
				}
				setTimeout(delayInit,100);
			}
			GlobalFacade.sendNotify( NotifyConst.CASH_CHANGED, this );
			//
			calcOwnFishList();
			//
			// 定时跑其他池子
			autoPlayTick = new Timer(10000);
			autoPlayTick.addEventListener(TimerEvent.TIMER, onAutoTickOtherPools);
			autoPlayTick.start();
		}

		private function delayInit():void
		{
			var addCash:int =YuChangModel.getInstance().fishOutCashOffline();
			if(addCash>0) Game.warning("离线期间您获得收益："+addCash+"金币");
		}

		/** 定时跑其他池子 */
		private function onAutoTickOtherPools( e:TimerEvent ):void
		{
			for(var i:int=0;i<fishPoolOpenCount;i++)
			{
				if(i != _curPoolIndex)
					autoPlay( i );
			}
		}

		private function initSavData():void
		{
			fishInPool = [];
			var fishInPool1:Array = [];
			now = new Date();
			var nowTimestamp:Number = now.valueOf();
			for( var i:int = 0; i < 1; i++ )
			{
				var vo:FishVO = new FishVO();
				vo.lastOutCashTime =  nowTimestamp;
				vo.type = 1;
				vo.id = i + 1;
				vo.eatCount = 1;
				vo.poolIndex = 0;
				fishInPool1.push( vo );
			}

			fishInPool.push( fishInPool1 );

			//////

			foodsInPool = [];
			//
			_curPoolIndex = 0;
			//
			_cash = 1000;
//			CONFIG::DEBUG
//			{_cash = 999999999;}
		}

		/**
		 * 找食物，最近的食物，找不到就返回null
		 * @param fishPos
		 * @param poolIndex
		 * @return
		 */
		public function findFood( fishPos:Point, poolIndex:int ):FoodVO
		{
			var foodsInOnePool:Array = foodsInPool[poolIndex];
			if( foodsInOnePool == null )return null;
			var nearest:FoodVO;
			var minDistance:Number = Number.MAX_VALUE;
			for( var i:int = foodsInOnePool.length - 1; i >= 0; i-- )
			{
				var eachFood:FoodVO = foodsInOnePool[i];
				if( eachFood.num <= 0 )
				{
					foodsInOnePool.splice( i, 1 );
					continue;
				}
				var d:Number = MousebombMath.distanceOf2Point( fishPos, eachFood.pos );
				if( d < minDistance )
				{
					minDistance = d;
					nearest = eachFood;
				}
			}
			return nearest;
		}

		public function giveFood( pos:Point ):void
		{
			var foodsInOnePool:Array = foodsInPool[_curPoolIndex];
			if( foodsInOnePool == null )
			{
				foodsInPool[_curPoolIndex] = foodsInOnePool = [];
			}
			var foodPerFood:int = ShengJiModel.getInstance().foodPerFood;
//			var price : int = foodPerFood;
//			if(_cash<price)
//			{
//				Game.warning("金币不足");
//				return;
//			}
			if(getFoodCountInAllPool()>= ShengJiModel.getInstance().foodNum)
			{
				Game.warning("已达到喂食上限，请强化食物数量");
				return;
			}
//			_cash -= price;
			var foodVO:FoodVO = new FoodVO();
			foodVO.num = foodVO.numTotal = foodPerFood;
			foodVO.pos = pos;
			foodsInOnePool.push( foodVO );
			//
			GlobalFacade.sendNotify( NotifyConst.PUT_FOOD, this, foodVO );
//			GlobalFacade.sendNotify( NotifyConst.CASH_CHANGED, this );
			needSaveFlag = true;
		}

		/** 计算所有池子里放的食物总数 */
		public function getFoodCountInAllPool():int
		{
			var end :int = 0;
			for( var i:int = 0; i < foodsInPool.length; i++ )
			{
				var array:Array = foodsInPool[i];
				if(array==null)
				{
				}else{
					end+=array.length;
				}
			}
			return end;
		}

		/** 被吃（要吃的分量） 返回实际吃了的分量 */
		public function eatFood( foodVO:FoodVO, tryEatNum:int ):int
		{
			var eatNum:int;
			if( tryEatNum > foodVO.num ) eatNum = foodVO.num; else eatNum = tryEatNum;
			foodVO.num -= eatNum;
			//			trace("YuChangModel/eatFood() 被吃",eatNum,"剩下",foodVO.num);
			GlobalFacade.sendNotify( NotifyConst.EAT_FOOD, this, foodVO );
			needSaveFlag = true;
			return eatNum;
		}

		/** 拥有货币 */
		private var _cash:int = 0;

		public function get cash():int
		{
			return _cash;
		}

		public function set cash( value:int ):void
		{
			_cash = value;
			needSaveFlag = true;
//			if(_cash >100000)
//				trace("YuChangModel/cash()",_cash);
		}

		/** 前往池子 */
		public function gotoPool( x:int, y:int ):Boolean
		{
			var tryIndex:int = x * 10 + y;
			if( tryIndex < fishPoolOpenCount && tryIndex >= 0 )
			{
				//当前pool改为自动运行，跳转
				autoPlay( _curPoolIndex );
				//新池子
				_curPoolIndex = tryIndex;
				autoPlay( _curPoolIndex );
				GlobalFacade.sendNotify( NotifyConst.POOL_CHANGED, this, _curPoolIndex );
				return true;
			}
			return false;
		}

		/** 后台自动执行  池子里的食物
		 * 离开一个池子时候调
		 * 回到一个池子时候调
		 * 定时调
		 * */
		private function autoPlay( poolIndex:int ):void
		{
//			trace( "YuChangModel/autoPlay()",poolIndex );
			//计算食物是否要被大家吃了
			var fishInOnePool:Array = fishInPool[poolIndex];
			var quickFishPos:Point = new Point( 0, 0 );
			for( var i:int = 0; i < fishInOnePool.length; i++ )
			{
				var fishVO:FishVO = fishInOnePool[i];
				if( fishVO.isHungry() )
				{
					var foodVO:FoodVO = findFood( quickFishPos, poolIndex );
					if( foodVO )
					{
						fishVO.eat( eatFood( foodVO, fishVO.calcPerEatNum() ) );
					}
				}
			}
		}

		public function get curPoolX():int {return int( _curPoolIndex / 10 );}

		public function get curPoolY():int {return int( _curPoolIndex % 10 );}

		/** 当前池子id 从0 开始 */
		private var _curPoolIndex:int;

		private static const POOL_X:String = "ABCDEFGHIJ";
		private static const POOL_Y:String = "0123456789";

		public function getCurPoolName():String
		{
			var y = _curPoolIndex % 10;
			var x = int( _curPoolIndex / 10 );
			return POOL_X.charAt( x ) + POOL_Y.charAt( y );//_curPoolIndex/9;
		}

		public function getCurPoolIndex():int
		{
			return _curPoolIndex;
		}

		/** 初次读入数据后计算我拥有的所有鱼数量列表 */
		private function calcOwnFishList():void
		{
			for( var i:int = 0; i < fishInPool.length; i++ )
			{
				var fishInOnePool:Array = fishInPool[i];
				for( var j:int = 0; j < fishInOnePool.length; j++ )
				{
					var fishVO:FishVO = fishInOnePool[j];
					var key:String = fishVO.type + "_" + fishVO.id;
					var ownFishVO:OwnFishVO;
					ownFishVO = ownFishList.getValue( key );
					ownFishVO.num++;
					ownFishTotalNum++;
				}
			}
		}

		//我拥有的所有鱼数量列表
		public var ownFishList:HashMap;
		public var ownFishTotalNum:int = 0;

		public function canBuyFishList():Array
		{
			var end:Array = [];
			for( var i:int = 0; i < allFishList.length; i++ )
			{
				var key:String = allFishList[i];
				var ownFishVO:OwnFishVO = ownFishList.getValue( key );
				end.push( ownFishVO );
				if( ownFishVO.num < 1 )
				{
					break;
				}
			}
			return end;
		}

		private var allFishList:Array;

		private function initAllFishList():void
		{
			allFishList = [];
			ownFishList = new HashMap();
			ownFishTotalNum = 0;

			for( var i:int = 1; i <= 4; i++ )
			{
				for( var j:int = 1; j <= 99; j++ )
				{
					if( !ApplicationDomain.currentDomain.hasDefinition( "Fish" + i + "_" + j ) )
					{
						break;
					} else
					{
						var key:String = i + "_" + j;
						allFishList.push( key );
						//
						var ownFishVO:OwnFishVO;
						ownFishVO = new OwnFishVO();
						ownFishVO.type = i;
						ownFishVO.id = j;
						ownFishVO.num = 0;
						ownFishList.put( key, ownFishVO );
					}
				}
			}
		}

		public static var now:Date;

		/** 买鱼 */
		public function buyFish( tipe:int, id:int ):String
		{

			var price:int = calcFishPrice( tipe, id );
			if( _cash < price )
				return "金币不够";
			//
			var maxPerPool:int = ShengJiModel.getInstance().fishMaxPerPool;
			for( var i:int = 0; i < fishInPool.length; i++ )
			{
				var eachPool:Array = fishInPool[i];
				if( eachPool.length >= maxPerPool )
				{
				} else
				{
					// 扣款
					_cash -= price;
					//放入此池子
					addFish( tipe, id, i );
					//
					GlobalFacade.sendNotify( NotifyConst.CASH_CHANGED, this );
					return "";
				}
			}
			return "鱼儿数量已到上限，请升级渔场养更多的鱼";
		}

		/** 鱼池是否足够加鱼&&是否有钱买鱼 */
		public function canBuyFish( tipe:int, id:int ):Boolean
		{
			var price:int = calcFishPrice( tipe, id );
			if( _cash < price )
				return false;
			//
			var maxPerPool:int = ShengJiModel.getInstance().fishMaxPerPool;
			for( var i:int = 0; i < fishInPool.length; i++ )
			{
				var eachPool:Array = fishInPool[i];
				if( !eachPool ) return false;
				if( eachPool.length >= maxPerPool )
				{
				} else
				{
					return true;
				}
			}
			return false;
		}

		private function addFish( tipe:int, id:int, poolIndex:int ):void
		{
			now = new Date();
			var vo:FishVO = new FishVO();
			vo.type = tipe;
			vo.id = id;
			vo.eatCount = 1;
			vo.lastOutCashTime = now.valueOf();
			vo.poolIndex = poolIndex;
			fishInPool[poolIndex].push( vo );
			var key:String = vo.type + "_" + vo.id;
			ownFishList.getValue( key ).num++;
			ownFishTotalNum++;
			needSaveFlag = true;
			if( poolIndex == _curPoolIndex )
				GlobalFacade.sendNotify( NotifyConst.FISH_ADDED_CURPOOL, this, vo );
		}

		public function calcFishPrice( tipe:int, id:int ):int
		{
			switch(tipe )
			{
				case 1:return 100+ id * 10;
				case 2 : return 1000+id*100;
				case 3:return 10000+id  * 1000;
				case 4:return 100000+id  * 10000;
			}
			return Math.pow(100 ,(tipe)) + id;
		}


		/** 买池子 */
		public function buyPool():void
		{
			var poolIndex:int = fishInPool.length;
			fishInPool[poolIndex] = [];
			foodsInPool[poolIndex] = [];
			GlobalFacade.sendNotify( NotifyConst.POOL_COUNT_CHANGED, this );
			needSaveFlag = true;
		}

		/** 挂机产的金币 */
		public function fishOutCashOffline():int
		{
			var addCash:int = 0;
			YuChangModel.now = new Date();
			var now :Number = YuChangModel.now.valueOf();
			for( var i:int = 0; i < fishInPool.length; i++ )
			{
				var fishInOnePool:Array = fishInPool[i];
				for( var j:int = 0; j < fishInOnePool.length; j++ )
				{
					var fishVO:FishVO = fishInOnePool[j];
					/** 离线减半 */
					addCash += int(fishVO.calcOutCash()/2);
					fishVO.lastOutCashTime = now;
				}
			}
			cash += addCash;
			if(addCash>0) GlobalFacade.sendNotify( NotifyConst.CASH_CHANGED, this ,true );
			return addCash;
		}
	}
}
