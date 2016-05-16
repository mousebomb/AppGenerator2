/**
 * Created by rhett on 14/12/31.
 */
package td.battlefield.view
{
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.AssetManager;

	import td.NotifyConst;

	import org.mousebomb.SoundMan;
	import org.mousebomb.framework.GlobalFacade;

	public class LostUI extends Sprite
	{
		private var tween : Tween;
		public function LostUI()
		{
			var a:AssetManager = TDGame.assetsMan;
			var bg:Image = new Image( a.getTexture( "pauseUI" ) );
			bg.alignPivot();
			addChild( bg );
			
			var title :Image = new Image(a.getTexture("WarUI_WarResultLose"));
			title.alignPivot();
			title.y = -115;
			addChild(title);

			var restartBtn:Button = new Button( a.getTexture( "WarUI_WarResultRestart" ));
			restartBtn.alignPivot();
			addChild( restartBtn );

			var selectBtn:Button = new Button( a.getTexture( "WarUI_WarResultSelectmap" ) );
			selectBtn.alignPivot();
			selectBtn.y = 100;
			addChild( selectBtn );
			
			//
			restartBtn.addEventListener(Event.TRIGGERED, onClick);
			selectBtn.addEventListener(Event.TRIGGERED, onLevelClick);
			// flyin
			this.scaleX=.1;
			this.scaleY=.1;
			tween = new Tween( this, 0.8, Transitions.EASE_OUT_BOUNCE );
			tween.animate( "scaleX", 1 );
			tween.animate( "scaleY", 1 );
			//			tween.fadeTo( .5 );
			Starling.juggler.add( tween );
		}

		private function onLevelClick( event:Event ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			GlobalFacade.sendNotify( NotifyConst.UI_GOTO_SELECTLEVEL, this );
			removeFromParent(true);

		}

		private function onClick( event:Event ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			GlobalFacade.sendNotify( NotifyConst.UI_RESTART, this );
			removeFromParent(true);
		}
	}
}
