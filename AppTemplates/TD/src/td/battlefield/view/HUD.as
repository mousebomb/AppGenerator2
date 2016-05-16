/**
 * Created by rhett on 14/11/2.
 */
package td.battlefield.view
{
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.text.TextField;

	import td.NotifyConst;
	import td.battlefield.model.BattleFieldModel;
	import td.battlefield.model.vo.TowerVO;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import flash.geom.Point;

	public class HUD extends Sprite
	{
		private var top:TopUI = new TopUI();
		public var lifeTf:TextField;
		private var lifeBg : Image;
		private var blackBg : Image;
		private var attackRangeUI:AttackRangeUI;

		public function HUD()
		{
			if(attackRangeUI == null) attackRangeUI = new AttackRangeUI();
			
			GlobalFacade.regListener( NotifyConst.TOWER_SLOT_CLICK, onTowerClick );
			GlobalFacade.regListener( NotifyConst.BATTLE_LOST, onLost );
			GlobalFacade.regListener( NotifyConst.BATTLE_WON, onWon );
			GlobalFacade.regListener( NotifyConst.NEW_ENEMY_INTRO, onNewEnemy );
			GlobalFacade.regListener( NotifyConst.UI_BATTLE_PAUSE, onUIPause );
			GlobalFacade.regListener( NotifyConst.LIFE_UPDATED, onLifeUpdated );
			
			GlobalFacade.regListener( NotifyConst.UI_BATTLE_GOON, onBlackHide );
			GlobalFacade.regListener( NotifyConst.UI_GOTO_SELECTLEVEL, onBlackHide );
			GlobalFacade.regListener( NotifyConst.UI_RESTART, onBlackHide );
			GlobalFacade.regListener( NotifyConst.UI_ENEMY_INTRO_HIDE, onBlackHide);
			GlobalFacade.regListener( NotifyConst.UI_TOWER_UPGRADE, onRangeHide );
			GlobalFacade.regListener( NotifyConst.UI_TOWER_SELL, onRangeHide );

			addChild( top );
			//			addEventListener(Event.ADDED_TO_STAGE, onStage);
		}

/**
 * UI请求暂停
 */
		private function onUIPause(n:Notify) : void
		{
				var ui: PausedUI = new PausedUI();
				addChild( ui );
				ui.x = GameConf.SIZE_W_IPAD / 2;
				ui.y = GameConf.VISIBLE_SIZE_H_MINUS_AD / 2;
				hideTowerUI();
				//
				showBlack(true);
		}
		private function onBlackHide(n:Notify):void{showBlack(false);}
		private function onRangeHide(n:Notify):void{attackRangeUI.removeFromParent();}
		private function showBlack(value :Boolean) : void
		{
			if(blackBg==null)
			{
				blackBg = new Image(Texture.fromColor(1, 1,0x99000000));
				blackBg.setSize(GameConf.SIZE_W_IPAD, GameConf.VISIBLE_SIZE_H);
				addChildAt(blackBg, 3);
			}
			blackBg.visible=value;
		}

		/**
		 * 新一波怪物出现
		 */
		private function onNewEnemy(n:Notify) : void 
		{
			var enemyId : int = n.data;
			var t:Texture = TDGame.assetsMan.getTexture("MI"+enemyId);
			if(t)
			{
				showBlack(true);
				var ui:EnemyIntroUI = new EnemyIntroUI(enemyId);
				addChild( ui );
				ui.x = GameConf.SIZE_W_IPAD / 2;
				ui.y = GameConf.VISIBLE_SIZE_H_MINUS_AD / 2;
				hideTowerUI();
				GlobalFacade.sendNotify(NotifyConst.UI_ENEMY_INTRO_SHOW, this);
			}
			SoundMan.playSfx(SoundMan.MONSTER_INTRO_+enemyId);
		}

		//# 胜负
		private function onLost( n:Notify ):void
		{
				showBlack(true);
			var ui:DisplayObject = new LostUI();
			addChild( ui );
			ui.x = GameConf.SIZE_W_IPAD / 2;
			ui.y = GameConf.VISIBLE_SIZE_H_MINUS_AD / 2;
			//
			hideTowerUI();
			//
			SoundMan.playSfx(SoundMan.LOST);
		}

		private function onWon( n:Notify ):void
		{
				showBlack(true);
			//
			var ui:WinUI = new WinUI();
			ui.setStar( n.data );
			addChild( ui );
			ui.x = GameConf.SIZE_W_IPAD / 2;
			ui.y = GameConf.VISIBLE_SIZE_H_MINUS_AD / 2;
			//
			hideTowerUI();
			//
			SoundMan.playSfx(SoundMan.WON);
		}

		//		private function onStage( event:Event ):void
		//		{
		//			removeEventListener(Event.ADDED_TO_STAGE,onStage);
		//		}

		public function readyStart():void
		{
				showBlack(false);
			var ui:DisplayObject = new ReadyStartUI();
			addChild( ui );
			ui.x = GameConf.SIZE_W_IPAD / 2;
			ui.y = GameConf.VISIBLE_SIZE_H_MINUS_AD / 2;
		}

		// tower click
		private function onTowerClick( n:Notify ):void
		{
			switch( BattleFieldModel.getInstance().state )
			{
				case BattleFieldModel.BATTLE_LOST:
				case BattleFieldModel.BATTLE_WON:
					return;
			}
			var towerVO:TowerVO = n.data as TowerVO;

			//  显示可用选项
			if( towerVO.towerId == 0 )
			{
				//建造
				showBuildTower( towerVO );
			} else
			{
				//升级／售卖
				showUpgradeTower( towerVO );
			}
			//
			SoundMan.playSfx(SoundMan.SELECT);
		}

		private var upgradeTowerUI:UpgradeTowerUI;

		private function showUpgradeTower( towerVO:TowerVO ):void
		{
			//
			attackRangeUI.x = towerVO.x;attackRangeUI.y=towerVO.y;
			attackRangeUI.setRadius(towerVO.radius);
			addChild(attackRangeUI);
			//			trace("HUD/showUpgradeTower()");
			if( upgradeTowerUI == null )
				upgradeTowerUI = new UpgradeTowerUI();
			if( buildTowerUI ) buildTowerUI.removeFromParent();
			//
			upgradeTowerUI.x = towerVO.x;
			upgradeTowerUI.y = towerVO.y;
			upgradeTowerUI.update( towerVO );
			addChild( upgradeTowerUI );
		}

		private var buildTowerUI:BuildTowerUI;

		public function showBuildTower( towerVO:TowerVO ):void
		{
			//			trace("HUD/showBuildTower()");
			if( buildTowerUI == null )
				buildTowerUI = new BuildTowerUI();
			if( upgradeTowerUI ) upgradeTowerUI.removeFromParent();
			attackRangeUI.removeFromParent();
			//
			buildTowerUI.x = towerVO.x;
			buildTowerUI.y = towerVO.y;
			buildTowerUI.updateBuild( towerVO );
			addChild( buildTowerUI );
		}

		public function hideTowerUI():void
		{
			if( upgradeTowerUI ) upgradeTowerUI.removeFromParent();
			if( buildTowerUI ) buildTowerUI.removeFromParent();
			attackRangeUI.removeFromParent();

		}

/**
 * 显示血条位置
 */
		public function showLifeAt(lifePos : Point) : void
		{
			if(lifeBg ==null)
			{
				lifeBg = new Image(TDGame.assetsMan.getTexture("LifeBg"));
				lifeBg.alignPivot();
				lifeTf = new TextField( lifeBg.width/2, lifeBg.height, "0", "Life", 20, 0xffffff );
				lifeTf.alignPivot(HAlign.LEFT,VAlign.CENTER);
				lifeTf.hAlign=HAlign.LEFT;
			}
			lifeBg.x =lifeTf.x = lifePos.x;
			lifeBg.y =lifeTf.y = lifePos.y;
			if(lifeBg.parent==null) addChildAt(lifeBg,1);
			if(lifeTf.parent==null ) addChildAt( lifeTf,2 );
			lifeBg.visible=lifeTf.visible=true;
			onLifeUpdated( null );
		}
		public function hideLife():void
		{
			if(lifeBg)lifeBg.visible=lifeTf.visible=false;
		}
		private function onLifeUpdated( n:Notify ):void
		{
			lifeTf.text = BattleFieldModel.getInstance().life.toString();
		}

/**
 * 显示战斗剧情
 */
		public function showBattleIntro() : void
		{
			var id : int = BattleFieldModel.getInstance().battleVO.battleId;
			var ts:Vector.<Texture> = TDGame.assetsMan.getTextures("BI"+id+"_");
			if(ts.length)
			{
				showBlack(true);
				var ui:DisplayObject = new BattleIntroUI(ts);
				addChild( ui );
				ui.x = GameConf.SIZE_W_IPAD / 2;
				ui.y = GameConf.VISIBLE_SIZE_H_MINUS_AD / 2;
			}else{
				GlobalFacade.sendNotify(NotifyConst.UI_BATTLE_INTRO_HIDE, this);
			}
			SoundMan.playSfx(SoundMan.BATTLE_INTRO_ + id);
		}
		

	}
}
