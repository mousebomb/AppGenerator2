/**
 * Created by rhett on 14/10/26.
 */
package td.battlefield.view
{

	import flash.geom.Point;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	import org.mousebomb.SoundMan;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import starling.core.Starling;

	import starling.display.DisplayObject;

	import starling.display.Image;
	import starling.display.MovieClip;

	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	import td.NotifyConst;
	import td.battlefield.model.vo.BulletVO;
	import td.battlefield.model.vo.EnemyVO;
	import td.core.Bullet;
	import td.core.Tower;

	import td.util.CsvManager;
	import td.util.StaticDataModel;

	import td.battlefield.model.BattleFieldModel;
	import td.battlefield.model.vo.BattleCsvVO;

	import td.battlefield.model.vo.EnemyVO;
	import td.battlefield.model.vo.TowerVO;
	import td.battlefield.model.vo.WaveCsvVO;
	import td.core.Enemy;
	import td.core.ReusablePool;

	/**
	 * 战场 显示层 以此为主
	 */
	public class BattleField extends Sprite
	{

		public var bfModel:BattleFieldModel;
		private var hud:HUD;

		public function BattleField()
		{
			bfModel = BattleFieldModel.getInstance();

			addEventListener( EnterFrameEvent.ENTER_FRAME, onEnterFrame );
			//

			depthLayer = new Sprite();
			addChild( depthLayer );
			bulletLayer = new Sprite();
			addChild( bulletLayer );

			hud = new HUD();
			addChild( hud );

			GlobalFacade.regListener( NotifyConst.ENEMYVO_CREATED, onAddEnemy );
			GlobalFacade.regListener( NotifyConst.ENEMYVO_REMOVED, onDelEnemy );
			GlobalFacade.regListener( NotifyConst.TOWERVO_CREATED, onAddTower );
			GlobalFacade.regListener( NotifyConst.BULLETVO_CREATED, onAddBullet );
			GlobalFacade.regListener( NotifyConst.BULLETVO_REMOVED, onDelBullet );
			GlobalFacade.regListener( NotifyConst.ENEMYVO_ENEMYDOWN, onEnemyDown );
			GlobalFacade.regListener( NotifyConst.UI_RESTART, onRestart );
			GlobalFacade.regListener( NotifyConst.UI_READYSTART_FINISH, onReadyStartFinish );
			GlobalFacade.regListener( NotifyConst.UI_BATTLE_INTRO_HIDE, goReadyStart );
			//
			this.addEventListener(TouchEvent.TOUCH, onBfTouch);
		}

		private function onRestart(n:Notify):void
		{
			bfModel.resetLevel();
			initLevel();
		}
		private function onReadyStartFinish(n:Notify):void
		{
			bfModel.startLevelWaves();
		}

		private var touchOnThisId:int;
		private function onBfTouch( event:TouchEvent ):void
		{
			if(event.getTouch(hud))
			{
				touchOnThisId=-1;
				//点击到ui层 不归我管
//				trace("BattleField/onBfTouch() HUD");
				return ;
			}
			var touch : Touch = event.getTouch(this);
			if(touch)
			{
				if(TouchPhase.BEGAN == touch.phase)
				{
					touchOnThisId = touch.id;
				}
				else if(TouchPhase.ENDED == touch.phase)
				{
					if(touchOnThisId==touch.id)
					{
						//在战场点击 处理 ，如果点击到塔则发塔事件，否则发取消选择事件
						var touchPoint:Point = touch.getLocation(depthLayer);
						var clickTower : TowerVO = getTowerUnderPoint(touchPoint.x, touchPoint.y);
						if(clickTower)
						{
							// #1 点塔
							GlobalFacade.sendNotify( NotifyConst.TOWER_SLOT_CLICK, this, clickTower );
						}else{
							// #2 取消
							SoundMan.playSfx(SoundMan.DESELECT);
							hud.hideTowerUI();
						}
					}
					touchOnThisId = -1;
				}
			}
		}
		
		private function getTowerUnderPoint(x_:Number,y_:Number):TowerVO
		{
			//在战场点击 处理 ，如果点击到塔则发塔事件，否则发取消选择事件
			var clickTower : TowerVO; 
			for each(var tower : TowerVO in bfModel.towerList)
			{
				var dx :Number = Math.abs(tower.x - x_);
				var dy :Number = Math.abs(tower.y - y_);
				if(dx <40 && dy <40)
				{
					clickTower = tower; 
					return tower;
				}
			}
			return null;
		}

		private var bgImg :Image;
		/**
		 * 资源加载完毕后初始化关卡
		 * 此前已经被外部设置好了BFModel的信息
		 */
		public function initLevel():void
		{
			var t:Texture = TDGame.assetsMan.getTexture( "mapBg" );
			if(bgImg) bgImg.texture = t;
			else {
				bgImg = new Image(t);
				addChildAt( bgImg, 0 );
			}

			enemyDic = new Dictionary();
			towerDic = new Dictionary();
			bulletDic = new Dictionary();
			depthLayer.removeChildren();
			bulletLayer.removeChildren();

			hud.showLifeAt( bfModel.battleVO.lifePos );
			// 先显示剧情 里面会导致 UI_BATTLE_INTRO_HIDE
			hud.showBattleIntro();
			//
			SoundMan.playBgm("battle.mp3");
		}
		
		//UI_BATTLE_INTRO_HIDE
		private function goReadyStart(n:Notify = null):void
		{
//			hud.showLifeAt( bfModel.battleVO.lifePos );
			hud.readyStart();
			bfModel.startLevelReady();
		}

		private function onEnterFrame( event:EnterFrameEvent ):void
		{
			setDepth();
		}

		// 排序的
		private var depthLayer:Sprite;

		public function setDepth():void
		{
			var box:Array = [];
			var i:int = 0;
			for( i = 0; i < depthLayer.numChildren; i++ )
			{
				var a:Object = {objs:depthLayer.getChildAt( i ), depth_y:depthLayer.getChildAt( i ).y};
				box.push( a );
			}
			for( i = 0; i < depthLayer.numChildren; i++ )
			{
				depthLayer.setChildIndex( box.sortOn( "depth_y", Array.NUMERIC )[i].objs, i );
			}
		}


		// #enemy
		private function onAddEnemy( n:Notify ):void
		{
			var enemy:Enemy = Enemy.create( n.data );
			depthLayer.addChild( enemy );
			enemyDic[n.data] = enemy;
		}

		private var enemyDic:Dictionary = new Dictionary();

		private function onDelEnemy( n:Notify ):void
		{
			var enemyVO:EnemyVO = n.data as EnemyVO;
			var enemy:Enemy = enemyDic[enemyVO];
			depthLayer.removeChild( enemy );
		}


		// #tower
		private var towerDic:Dictionary = new Dictionary();
		private function onAddTower( n:Notify ):void
		{
			var towerVO:TowerVO = n.data;
			var tower:Tower = Tower.create( towerVO );
			depthLayer.addChild( tower );
			towerDic[towerVO] = tower;
		}

		//# bullet
		private var bulletLayer:Sprite;

		private function onAddBullet( n:Notify ):void
		{
			var bulletVO:BulletVO = n.data;
			var bullet:Bullet = Bullet.create( bulletVO );
			bulletLayer.addChild( bullet );
			bulletDic[bulletVO] = bullet;
			//
			SoundMan.playSfx(SoundMan.BULLET_+bulletVO.bulletId);
		}

		private var bulletDic:Dictionary = new Dictionary();

		private function onDelBullet( n:Notify ):void
		{
			var bulletVO:BulletVO = n.data as BulletVO;
			var bullet:Bullet = bulletDic[bulletVO];
			bulletLayer.removeChild( bullet );
		}


		//# enemyDown
		private function onEnemyDown( n:Notify ):void
		{
			var mc:MovieClip = new MovieClip( TDGame.assetsMan.getTextures( "EnemyDown" ) );
			Starling.juggler.add( mc );
			mc.addEventListener( Event.COMPLETE, onDieComplete );
			mc.alignPivot();
			var enemyVO:EnemyVO = n.target;
			mc.x = enemyVO.x;
			mc.y = enemyVO.y;
			bulletLayer.addChild( mc );
			//
			SoundMan.playSfx(SoundMan.MONSTER_DIE+enemyVO.enemyId);
		}

		private function onDieComplete( event:Event ):void
		{
			var mc:MovieClip = (event.currentTarget as MovieClip);
			Starling.juggler.remove( mc );
			mc.removeFromParent( true );

		}

	}
}
