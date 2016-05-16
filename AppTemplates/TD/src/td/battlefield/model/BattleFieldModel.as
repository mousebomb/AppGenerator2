/**
 * Created by rhett on 14/10/26.
 */
package td.battlefield.model
{

	import com.shortybmc.data.parser.CSV;

	import flash.geom.Point;

	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import org.mousebomb.Math.MousebombMath;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import starling.animation.IAnimatable;

	import starling.animation.Juggler;
	import starling.core.Starling;

	import td.NotifyConst;

	import td.battlefield.model.vo.BattleCsvVO;
	import td.battlefield.model.vo.BulletVO;
	import td.battlefield.model.vo.EnemyVO;
	import td.battlefield.model.vo.TowerCsvVO;
	import td.battlefield.model.vo.TowerVO;
	import td.battlefield.model.vo.WaveCsvVO;
	import td.battlefield.view.BuildTowerUI;
	import td.battlefield.view.UpgradeTowerUI;
	import td.lobby.model.PlayerRecordModel;
	import td.util.StaticDataModel;

	public class BattleFieldModel implements IAnimatable
	{

		private static var _instance:BattleFieldModel;

		public static function getInstance():BattleFieldModel
		{
			if( _instance == null )
				_instance = new BattleFieldModel();
			return _instance;
		}

		public function BattleFieldModel()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
			//
			GlobalFacade.regListener( NotifyConst.ENEMYVO_REMOVED, onNenemyRemoved );
			GlobalFacade.regListener( NotifyConst.BULLETVO_REMOVED, onRemoveBullet );
			GlobalFacade.regListener( NotifyConst.UI_TOWER_BUILD, onUITowerBuild );
			GlobalFacade.regListener( NotifyConst.UI_TOWER_UPGRADE, onUITowerUpgradeOrSell );
			GlobalFacade.regListener( NotifyConst.UI_TOWER_SELL, onUITowerUpgradeOrSell );
			GlobalFacade.regListener( NotifyConst.BULLETVO_HITTARGET, onHitTarget );
			GlobalFacade.regListener( NotifyConst.ENEMYVO_ENEMYDOWN, onEnemyDown );
			GlobalFacade.regListener( NotifyConst.ENEMYVO_FINISHLINE, onEnemyFinishLine );
			GlobalFacade.regListener( NotifyConst.UI_SURRENDER, onSurrender );
			GlobalFacade.regListener( NotifyConst.UI_BATTLE_PAUSE, onPause);
			GlobalFacade.regListener( NotifyConst.UI_BATTLE_GOON, onGoOn);
			GlobalFacade.regListener( NotifyConst.UI_ENEMY_INTRO_SHOW, onPause);
			GlobalFacade.regListener( NotifyConst.UI_ENEMY_INTRO_HIDE, onGoOn);

		}


		/*
		 #1 设置本关卡的静态数据
		 */

		/**
		 * 战场数据
		 */
		public var battleVO:BattleCsvVO;

		/**
		 * 本关的波数据
		 */
		public var waveList:Vector.<WaveCsvVO>;

		/**
		 * 进入某关卡  设置数据
		 */
		public function gotoLevel( battleVO_:BattleCsvVO, waveList_:Vector.<WaveCsvVO> ):void
		{
			// 设置静态数据
			battleVO = battleVO_;
			waveList = waveList_;
			// 根据静态数据重设关卡初始化的动态数据
			resetLevel();
		}

		/**
		 * 此关卡需要的背景图url
		 * @return
		 */
		public function getMapBgURL():String
		{
			return TDGame.assetsFolder.resolvePath( "map/" + battleVO.battleId + ".png" ).url;
		}

		public function hasNextBattle():Boolean
		{
			return null != StaticDataModel.getInstance().battleCsvDic[battleVO.battleId + 1];
		}

		/*
		 #2 关卡动态数据
		 */
		// 钱
		public var money:int;
		// 保护对象的生命
		public var life:int;

		public static const LIFE_MAX:uint = 10;

		public var wavesComplete:uint;
		public var curWaveIndex:uint;
		public var curWaveVO:WaveCsvVO;

		// 波全派发完
		private var isNoMoreWaves:Boolean;

		// 当前已经造出的塔
		public var towerList:Vector.<TowerVO>;

		//当前的怪物
		public var enemyList:Vector.<EnemyVO>;
		// 当前所有子弹
		public var bulletList:Vector.<BulletVO>;

		/**
		 * 当前状态
		 */
		public var state:uint = NONE;
		public static const NONE:uint = 98;
		public static const BATTLE_ING:uint = 99;
		public static const BATTLE_PAUSED:uint = 100;
		public static const BATTLE_WON:uint = 101;
		public static const BATTLE_LOST:uint = 102;


		/*
		 * #3 流转
		 */

		/**
		 * 根据静态数据重设关卡初始化的动态数据
		 * reset level data from CSV data , which is being set earlier
		 * gotoLevel后／重新开始关卡使用
		 */
		public function resetLevel():void
		{
			// BattleCsvVO
			money = battleVO.initMoney;
			life = LIFE_MAX;
			// WaveCsvVO
			wavesComplete = 0;
			curWaveIndex = 1;
			// 玩家产生的塔
			towerList = new <TowerVO>[];
			//
			enemyList = new <EnemyVO>[];
			//
			bulletList = new <BulletVO>[];
			//
			lastSpawnTime = 0;
			_battleTimePassed = 0;
			//
			isNoMoreWaves = false;
			//
			state = NONE;
			//
			GlobalFacade.sendNotify( NotifyConst.MONEY_UPDATED, this );
			GlobalFacade.sendNotify( NotifyConst.LIFE_UPDATED, this );
			GlobalFacade.sendNotify( NotifyConst.WAVE_UPDATED, this );
		}


		/**
		 * 开始关卡（预备）
		 */
		public function startLevelReady():void
		{
			//
			for each ( var towerSlot:Point in battleVO.towerslot )
			{
				var towerVO:TowerVO = new TowerVO( towerSlot );
				towerList.push( towerVO );
				GlobalFacade.sendNotify( NotifyConst.TOWERVO_CREATED, this, towerVO );
			}
		}

		/**
		 * 开始关卡（发波）
		 */
		public function startLevelWaves():void
		{
			Starling.juggler.add( this );
			state = BATTLE_ING;
			//
			GlobalFacade.sendNotify(NotifyConst.BATTLE_START, this);
			gotoWave( 0 );
		}

		public function gotoWave( index0:int ):void
		{
			wavesComplete = index0;
			curWaveVO = waveList[wavesComplete];
			enemyCountSpawnedInCurWave = 0;
			curWaveIndex = wavesComplete + 1;
			CONFIG::DEBUG 
			{	trace( "BattleFieldModel/gotoWave() 开始第" + curWaveIndex + "波" );}
			GlobalFacade.sendNotify( NotifyConst.WAVE_UPDATED, this );
			GlobalFacade.sendNotify( NotifyConst.NEW_ENEMY_INTRO, this ,curWaveVO.enemyId );
		}

		private function nextWave():void
		{
			if( isNoMoreWaves ) return;

			var nextWave:int = wavesComplete + 1;
			if( waveList.length > nextWave )
			{
				gotoWave( nextWave );
			} else
			{
				//没有下一波要spawn了
				isNoMoreWaves = true;
				CONFIG::DEBUG { trace( "BattleFieldModel/nextWave() 所有波全部派发完毕" );}
			}
		}

		// 上次出生怪物的时间（juggler的time）
		private var lastSpawnTime:Number;
		private var enemyCountSpawnedInCurWave:uint = 0;


		// 战斗ING状态经过了的总时间; 反映战斗当前时间轴位置
		private var _battleTimePassed:Number;

		public function advanceTime( time:Number ):void
		{
			if( state == BATTLE_ING )
			{
				_battleTimePassed += time;
				// 根据时间差 进行战斗调度
				// #enemy   spawn
				var needNextWave:Boolean = enemyCountSpawnedInCurWave >= curWaveVO.enemyCount;
				if( needNextWave )
				{
					nextWave();
				} else
				{
					var needSpawn:Boolean = (lastSpawnTime == 0) || (_battleTimePassed - lastSpawnTime >= curWaveVO.enemySpawn);
					if( needSpawn )
					{
						//first time to spawn
						var enemy:EnemyVO = new EnemyVO();
						enemy.enemyId = curWaveVO.enemyId;
						enemy.path = battleVO.path;
						enemy.moveSpeed = curWaveVO.moveSpeed;
						enemy.hp = curWaveVO.enemyHp;
						enemy.maxHp = curWaveVO.enemyHp;
						enemy.money = curWaveVO.money;
						enemyList.push( enemy );
						lastSpawnTime = _battleTimePassed;
						enemyCountSpawnedInCurWave++;
						GlobalFacade.sendNotify( NotifyConst.ENEMYVO_CREATED, this, enemy );
					}
				}

				// #enemy move
				for each ( var eachEnemy:EnemyVO in enemyList )
				{
					eachEnemy.advanceTime( time );
				}
				// #tower
				for each ( var eachTower:TowerVO in towerList )
				{
					eachTower.advanceTime( time );
				}
				// #bullet
				for each ( var eachBullet:BulletVO in bulletList )
				{
					eachBullet.advanceTime( time );
				}


			}
		}


		//# 敌人
		private function onNenemyRemoved( n:Notify ):void
		{
			var index:int = enemyList.indexOf( n.data );
			if( index != -1 )
			{
				enemyList.splice( index, 1 );
			}
			// 胜利判定
			if( isNoMoreWaves && enemyList.length <= 0 )
			{
				//胜利了
				// 评级
				var star:int = 1;
				if( LIFE_MAX - life == 0 )
				{
					star = 3;
				} else if( life > 3 )
				{
					star = 2;
				}
				//
				state = BATTLE_WON;
				PlayerRecordModel.getInstance().saveLevel(battleVO.battleId,star);
				GlobalFacade.sendNotify( NotifyConst.BATTLE_WON, this,star );
			}
		}

		//敌人被杀
		private function onEnemyDown( n:Notify ):void
		{
			//加钱
			var enemy:EnemyVO = n.target;
			money += enemy.money;
			GlobalFacade.sendNotify( NotifyConst.MONEY_UPDATED, this );

		}

		private function onEnemyFinishLine( n:Notify ):void
		{
			//扣血
			life--;
			GlobalFacade.sendNotify( NotifyConst.LIFE_UPDATED, this );
			// 失败判定
			if( life <= 0 )
			{
				CONFIG::DEBUG {trace( "BattleFieldModel/onEnemyFinishLine()   失败判定" );}
				state = BATTLE_LOST;
				GlobalFacade.sendNotify( NotifyConst.BATTLE_LOST, this );
			}
		}

		private function onSurrender( n:Notify ):void
		{
			//投降
			if(state != BATTLE_LOST && state != BATTLE_WON)
			{
				state = BATTLE_LOST;
				GlobalFacade.sendNotify( NotifyConst.BATTLE_LOST, this );
			}
		}

		/**
		 * 反映战斗当前时间轴位置
		 */
		public function get battleTimePassed():Number
		{
			return _battleTimePassed;
		}


		//# 造塔

		/**
		 * 将塔 建造／升级为towerId
		 * @param towerVO
		 * @param towerId 0 表示出售
		 */
		public function setTower( towerVO:TowerVO, towerId:int ):void
		{
			if( towerList.indexOf( towerVO ) == -1 ) return;
			if( towerId == 0 )
			{
				//出售
				// 出售返还价值的一半
				money += StaticDataModel.getInstance().getSellPrice(towerVO.towerId);
				GlobalFacade.sendNotify( NotifyConst.MONEY_UPDATED, this );
				towerVO.towerId = 0;
				towerVO.type = 0;
				GlobalFacade.sendNotify( NotifyConst.TOWERVO_UPDATED, this, towerVO );

			} else
			{
				//升级／建造
				//扣钱
				var towerCsvVO:TowerCsvVO = StaticDataModel.getInstance().towerCsvDic[towerId];
				money -= towerCsvVO.money;
				GlobalFacade.sendNotify( NotifyConst.MONEY_UPDATED, this );
				// 设置塔属性
				towerVO.towerId = towerId;
				towerVO.type = towerCsvVO.type;
				towerVO.radius = towerCsvVO.radius;
				towerVO.attack = towerCsvVO.attack;
				towerVO.attackCd = towerCsvVO.attackCd;
				towerVO.bulletSpeed = towerCsvVO.bulletSpeed;
				GlobalFacade.sendNotify( NotifyConst.TOWERVO_UPDATED, this, towerVO );
			}
		}

		private function onUITowerBuild( n:Notify ):void
		{
			var towerVO:TowerVO = BuildTowerUI.towerVO;
			setTower( towerVO, n.data );
		}

		private function onUITowerUpgradeOrSell( n:Notify ):void
		{
			var towerVO:TowerVO = UpgradeTowerUI.towerVO;
			setTower( towerVO, n.data );
		}

		//# 攻击

		/**
		 * 寻找最近的敌人
		 */
		public function nearestEnemy( x:Number, y:Number, radius:Number ):EnemyVO
		{
			var pointA:Point = new Point();
			var pointB:Point = new Point( x, y );
			var minDist:Number = Number.MAX_VALUE;
			var end:EnemyVO;
			for each ( var enemyVO:EnemyVO in enemyList )
			{
				pointA.x = enemyVO.x;
				pointA.y = enemyVO.y;
				var dist:Number = MousebombMath.distanceOf2Point( pointA, pointB );
				if( dist < minDist )
				{
					minDist = dist;
					end = enemyVO;
				}
			}
			if( minDist <= radius )
			{
				return end;
			} else
			{
				return null;
			}
		}

		public function launchBullet( tower:TowerVO, enemy:EnemyVO ):void
		{

			var bullet:BulletVO = new BulletVO();
			bullet.attack = tower.attack;
			bullet.target = enemy;
			bullet.x = tower.x;
			bullet.y = tower.y;
			bullet.moveSpeed = tower.bulletSpeed;
			bullet.bulletId = tower.type;
			bulletList.push( bullet );
			GlobalFacade.sendNotify( NotifyConst.BULLETVO_CREATED, this, bullet );

		}

		private function onRemoveBullet( n:Notify ):void
		{

			var index:int = bulletList.indexOf( n.data );
			if( index != -1 )
			{
				bulletList.splice( index, 1 );
			}
		}

		private function onHitTarget( n:Notify ):void
		{
			var enemyVO:EnemyVO = n.data;
			var bulletVO:BulletVO = n.target;
			enemyVO.onHit( bulletVO.attack );
		}

		/*
		 * # 暂停
		 */
		private function onPause(n : Notify) : void
		{
			state = BATTLE_PAUSED;
			GlobalFacade.sendNotify(NotifyConst.BATTLE_PAUSE, this);
		}

		private function onGoOn(n : Notify) : void
		{
			state = BATTLE_ING;
			GlobalFacade.sendNotify(NotifyConst.BATTLE_GOON, this);
		}
	}
}
