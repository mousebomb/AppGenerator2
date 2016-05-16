/**
 * Created by rhett on 14/12/29.
 */
package td.battlefield.view
{
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	import td.NotifyConst;
	import td.battlefield.model.BattleFieldModel;
	import td.battlefield.model.vo.TowerCsvVO;
	import td.battlefield.model.vo.TowerVO;
	import td.util.StaticDataModel;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import flash.geom.Point;

	public class UpgradeTowerUI extends Sprite
	{
		private var sellBtn : UpgradeTowerLi;
		private var upgradeBtn : UpgradeTowerLi;

//外围级别
		public var curSlot : int = 0;
		private var marginX : Number;
		private var marginY : Number;
		private var left : Number;
		private var right : Number;
		private var top : Number;
		private var bottom : Number;
		public function UpgradeTowerUI()
		{
			left = GameConf.SIZE_W_IPAD - GameConf.DESIGN_SIZE_W;
			right = GameConf.DESIGN_SIZE_W ;
			top = 0;
			bottom = GameConf.VISIBLE_SIZE_H_MINUS_AD;
			
			var sellT : Texture = TDGame.assetsMan.getTexture("WarUI_TowerUpgradeSellBtn");
			if(sellT.frame)
			{
				marginX = sellT.frame.width;marginY = sellT.frame.height;
			}else{
				marginX = sellT.width;marginY = sellT.height;
			}
			sellBtn = new UpgradeTowerLi(sellT);
			var upgradeT : Texture = TDGame.assetsMan.getTexture("WarUI_TowerUpgradeUpgradeBtn");
			var upgradeTDisabled : Texture = TDGame.assetsMan.getTexture("WarUI_TowerUpgradeUpgradeBtnDisable");
			upgradeBtn = new UpgradeTowerLi(upgradeT, upgradeTDisabled);
			addChild(sellBtn);
			addChild(upgradeBtn);
			GlobalFacade.regListener(NotifyConst.UI_TOWER_UPGRADE, onTriggered);
			GlobalFacade.regListener(NotifyConst.UI_TOWER_SELL, onTriggered);
			sellBtn.addEventListener(Event.TRIGGERED, onSellTriggered);
			upgradeBtn.addEventListener(Event.TRIGGERED, onUpgradeTriggered);

			GlobalFacade.regListener(NotifyConst.MONEY_UPDATED, onMoneyUpdated);
		}

		/**
		 * 战场钱变化，更新可造
		 * @param n
		 */
		private function onMoneyUpdated(n : Notify) : void
		{
			validate();
		}

		private function onUpgradeTriggered(event : Event) : void
		{
			GlobalFacade.sendNotify(NotifyConst.UI_TOWER_UPGRADE, this, toTowerId);
		}

		private function onSellTriggered(event : Event) : void
		{
			GlobalFacade.sendNotify(NotifyConst.UI_TOWER_SELL, this);
		}

		private function onTriggered(n : Notify) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			removeFromParent();
		}

		/**
		 * 更新显示
		 * @param towerVO 选择的塔基座
		 */
		public function update(towerVO_ : TowerVO) : void
		{
			trace("UP",x,y);
			//position
			curSlot = 0;
			var p1 :Point = getNextPos();
			var p2:Point = getNextPos();
			upgradeBtn.x=p1.x;
			upgradeBtn.y=p1.y;
			trace("upgradeBtn:",p1);
			sellBtn.x=p2.x;sellBtn.y=p2.y;
//
			towerVO = towerVO_;
			validate();
		}

		// 围绕点击位置来显示
		private function getNextPos() : Point
		{
			var end :Point = AroundSlots.getSlotPos(curSlot++);
			end.x = end.x * marginX;
			end.y = end.y*marginY;
//			trace(left,right,top,bottom);
//			trace("Pick:",curSlot,end);
			while(end.x+x >= right ||  end.x+x <= left || end.y+y >=bottom || end.y+y <=top)
			{
				end = AroundSlots.getSlotPos(curSlot++);
				end.x *= marginX;end.y*=marginY;
//				trace("Pick:",curSlot,end);
			}
			return end;
		}
		
		private function validate():void
		{
			if(towerVO.towerId==0) return;
			//
			var towerCsvVO : TowerCsvVO = StaticDataModel.getInstance().getNextLevelTower(towerVO.towerId);
			if (towerCsvVO)
			{
				toTowerId = towerCsvVO.towerId;
				upgradeBtn.enabled = towerCsvVO.money <= BattleFieldModel.getInstance().money;
				upgradeBtn.moneyTf.text = towerCsvVO.money.toString();
				upgradeBtn.isMax(false);
			}
			else
			{
				toTowerId = 0;
				upgradeBtn.isMax(true);
				upgradeBtn.enabled = false;
			}
			//
			// 出售返还价值的一半
				var sellMoney = StaticDataModel.getInstance().getSellPrice(towerVO.towerId);
				sellBtn.moneyTf.text = sellMoney;
		}

		// 操作面向的塔
		public static var towerVO : TowerVO;
		// 升级到
		public var toTowerId : int ;
	}
}
