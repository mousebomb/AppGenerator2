package td.battlefield.view
{
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import td.NotifyConst;
	import td.battlefield.model.BattleFieldModel;

	import org.mousebomb.SoundMan;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	/**
	 * @author rhett
	 */
	public class UpgradeTowerLi extends Sprite
	{
		public function UpgradeTowerLi(normalT : Texture, disableT : Texture=null)
		{
			//
			var borderT : Texture = TDGame.assetsMan.getTexture("WarUI_BottomBorder");
			border = new Image(borderT);
			border.alignPivot();
			border.touchable = false;
			addChild(border);
			moneyTf.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
			moneyTf.hAlign = HAlign.LEFT;
			moneyTf.x = 40;
			moneyTf.y = border.height / 2;
			moneyTf.touchable = false;
			addChild(moneyTf);
			btn = new Button(normalT, "", null, null, disableT);
			btn.alignPivot();
			addChildAt(btn, 0);
		}

		public var moneyTf : TextField = new TextField(80, 25, "0", "Price", 20, 0xffffff);
		public var btn : Button;
		private var maxImg :Image;
		private var border : DisplayObject;

		public function set enabled(newEnabled : Boolean) : void
		{
			btn.enabled = newEnabled;
		}
		
		public function isMax(b :Boolean):void
		{
			if(maxImg==null){
			//
			maxImg = new Image(TDGame.assetsMan.getTexture("WarUI_TowerUpgradeMax"));
			maxImg.alignPivot();
			addChildAt(maxImg,1);
			}
			maxImg.visible =b;
			border.visible=moneyTf.visible=btn.visible= !b;
			
		}
	}
}
