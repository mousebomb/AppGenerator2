/**
 * Created by rhett on 14/12/29.
 */
package td.battlefield.view {
	import starling.display.DisplayObject;
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	import starling.text.TextField;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	import td.NotifyConst;
	import td.battlefield.model.BattleFieldModel;

	import org.mousebomb.SoundMan;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	public class BuildTowerLi extends Sprite
	{
		public var moneyTf:TextField = new TextField( 80, 25, "0", "Price", 20, 0xffffff );
		private var btn : Button;
		private var border : DisplayObject;
		public function BuildTowerLi()
		{
			var borderT:Texture = TDGame.assetsMan.getTexture( "WarUI_BottomBorder" );
			border = new Image( borderT );
			border.alignPivot();
			border.touchable=false;
			addChild( border );
//			border.addEventListener(Event.TRIGGERED, onTriggered);
			moneyTf.alignPivot(HAlign.CENTER,VAlign.BOTTOM);
			moneyTf.hAlign = HAlign.LEFT;
			moneyTf.x = 40;
			moneyTf.y = border.height/2;
			moneyTf.touchable=false;
			addChild(moneyTf);
			
			//
			GlobalFacade.regListener(NotifyConst.MONEY_UPDATED,onMoneyUpdated);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}

		private function onRemoved( event:Event ):void
		{
			GlobalFacade.removeListener(NotifyConst.MONEY_UPDATED,onMoneyUpdated);
		}

		/**
		 * 战场钱变化，更新可造
		 * @param n
		 */
		private function onMoneyUpdated(n:Notify):void
		{
			var bfModel:BattleFieldModel = BattleFieldModel.getInstance();
			btn.enabled  = bfModel.money >= money;
		}


		// 要建造的塔原型id
		private var towerId:int;
		// 需要金钱
		private var money:int;

		public function init(towerId_ : int,money_:int ):void
		{
			if(towerId_ == towerId) return ;
			towerId = towerId_;
			var normalT:Texture =TDGame.assetsMan.getTexture("TI" + towerId);
			var disableT :Texture = TDGame.assetsMan.getTexture("TI" + towerId+"_gray");
			if(btn !=null)
			{
				btn.removeFromParent(true);
			}
			btn = new Button(normalT,"",null,null,disableT);
			btn.alignPivot();
			addChildAt(btn,0);
			money = money_;
			moneyTf.text = money.toString();
			btn.addEventListener(Event.TRIGGERED, onTriggered);
			onMoneyUpdated(null);
		}

		private function onTriggered( event:Event ):void
		{
			GlobalFacade.sendNotify( NotifyConst.UI_TOWER_BUILD, this,towerId );
			SoundMan.playSfx(SoundMan.BUILD);
		}

	}
}
