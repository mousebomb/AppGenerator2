package td.battlefield.view
{
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.AssetManager;

	import td.NotifyConst;

	import org.mousebomb.SoundMan;
	import org.mousebomb.framework.GlobalFacade;

	/**
	 * 暂停时float的ui
	 * @author rhett
	 */
	public class PausedUI extends Sprite
	{
		private var bg:Image;
		public function PausedUI()
		{
			var a:AssetManager = TDGame.assetsMan;
			bg = new Image( a.getTexture( "pauseUI" ) );
			bg.alignPivot();
			addChild( bg );

			var goOnBtn:Button = new Button( a.getTexture( "WarUI_WarResultGoOn" ));
			goOnBtn.alignPivot();
			goOnBtn.y = -100;
			addChild( goOnBtn );
			
			var restartBtn:Button = new Button( a.getTexture( "WarUI_WarResultRestart" ) );
			restartBtn.alignPivot();
			addChild( restartBtn );

			var selectBtn:Button = new Button( a.getTexture( "WarUI_WarResultSelectmap" ) );
			selectBtn.alignPivot();
			selectBtn.y = 100;
			addChild( selectBtn );
			//
			goOnBtn.addEventListener(Event.TRIGGERED, onGoOnClick);
			restartBtn.addEventListener(Event.TRIGGERED, onRestartClick);
			selectBtn.addEventListener(Event.TRIGGERED, onLevelClick);
		}

		private function onGoOnClick(event : Event) : void
		{
			GlobalFacade.sendNotify( NotifyConst.UI_BATTLE_GOON, this );
			SoundMan.playSfx(SoundMan.BTN);
			removeFromParent(true);
		}

		private function onLevelClick( event:Event ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			GlobalFacade.sendNotify( NotifyConst.UI_GOTO_SELECTLEVEL, this );
			removeFromParent(true);
		}

		private function onRestartClick( event:Event ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			GlobalFacade.sendNotify( NotifyConst.UI_RESTART, this );
			removeFromParent(true);
		}
	}
}
