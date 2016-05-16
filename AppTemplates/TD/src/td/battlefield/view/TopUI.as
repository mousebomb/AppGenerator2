/**
 * Created by rhett on 14/12/31.
 */
package td.battlefield.view
{
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.AssetManager;

	import td.NotifyConst;
	import td.battlefield.model.BattleFieldModel;

	import org.mousebomb.SoundMan;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	public class TopUI extends Sprite
	{
		public var moneyTf:TextField = new TextField( 200, 70, "0", "TopMoney", 48, 0xffffff );
		private var waveTf:TextField = new TextField( 100, 60, "0", "TopWave1", 36, 0xffffff );
		private var waveTotalTf:TextField = new TextField( 100, 60, "0", "TopMoney", 36, 0xffffff );

		private var pauseBtn:Button;
		private var bg:Image;

		public function TopUI()
		{
			var a:AssetManager = TDGame.assetsMan;

			bg = new Image( a.getTexture( "TopUI" ) );
			addChild( bg );

			pauseBtn = new Button( a.getTexture( "WarUI_pauseBtn" ),"",null,null,a.getTexture( "WarUI_pauseBtn2" ) );
			pauseBtn.x = 640;
			pauseBtn.alignPivot(HAlign.CENTER,VAlign.TOP);
			pauseBtn.enabled=false;
			addChild( pauseBtn );

			moneyTf.x = 250;
			moneyTf.y = bg.height/2;
			moneyTf.alignPivot();
			moneyTf.hAlign=HAlign.LEFT;
			addChild( moneyTf );

			waveTf.x = 365;
			waveTf.y = bg.height/2;
			waveTf.alignPivot();
			addChild( waveTf );
			waveTotalTf.x = 451;
			waveTotalTf.y = bg.height/2;
			waveTotalTf.alignPivot();
			addChild( waveTotalTf );
			

			GlobalFacade.regListener( NotifyConst.MONEY_UPDATED, onMoneyUpdated );
			GlobalFacade.regListener( NotifyConst.WAVE_UPDATED, onWaveUpdated );
			GlobalFacade.regListener( NotifyConst.BATTLE_START, onPauseBtnEnable );
			GlobalFacade.regListener( NotifyConst.BATTLE_GOON, onPauseBtnEnable );
			GlobalFacade.regListener( NotifyConst.BATTLE_PAUSE, onPauseBtnDisable );
			GlobalFacade.regListener( NotifyConst.BATTLE_WON, onPauseBtnDisable );
			GlobalFacade.regListener( NotifyConst.BATTLE_LOST, onPauseBtnDisable );
			onMoneyUpdated( null );
			onWaveUpdated( null );
			//
			pauseBtn.addEventListener(Event.TRIGGERED, onPauseTriggered);
		}
		
		private function onPauseBtnEnable(n:Notify):void
		{
			pauseBtn.enabled = true;
		}
		private function onPauseBtnDisable(n:Notify):void
		{
			pauseBtn.enabled = false;
		}

		private function onPauseTriggered( event:Event ):void
		{
			GlobalFacade.sendNotify( NotifyConst.UI_BATTLE_PAUSE, this );
			SoundMan.playSfx(SoundMan.BTN);
			//
			AoaoBridge.interstitial(TDGame.instance);
		}

		private function onWaveUpdated( n:Notify ):void
		{
			waveTf.text = BattleFieldModel.getInstance().curWaveIndex.toString() ;
			waveTotalTf.text = BattleFieldModel.getInstance().waveList.length.toString();
		}

		private function onMoneyUpdated( n:Notify ):void
		{
			moneyTf.text = BattleFieldModel.getInstance().money.toString();
		}

	}
}
