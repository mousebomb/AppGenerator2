/**
 * Created by rhett on 15/1/1.
 */
package td.battlefield.view
{

	import org.mousebomb.SoundMan;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.AssetManager;

	import td.NotifyConst;

	public class ReadyStartUI extends Sprite
	{
		private var readyStart:Image;

		private var tween:Tween;


		public function ReadyStartUI()
		{
			var a:AssetManager = TDGame.assetsMan;
			readyStart = new Image( a.getTexture( "WarUI_ready" ) );
			readyStart.alignPivot();
			addChild( readyStart );
			onTweenComplete();
			GlobalFacade.regListener( NotifyConst.UI_SURRENDER, onSurrender );

		}

		private function onSurrender( n:Notify ):void
		{
			tween.onComplete = null;
			removeFromParent( true );
		}

		private var phase:int = 3;

		private function onTweenComplete():void
		{
			if( phase == 0 )
			{
				GlobalFacade.sendNotify( NotifyConst.UI_READYSTART_FINISH, this );
				removeFromParent( true );
				return;
			}
			switch( phase )
			{
				case 3:
					readyStart.scaleX = readyStart.scaleY = 2;
					readyStart.alpha = 1;
					phase = 2;
					break;
				case 2:
					readyStart.texture = TDGame.assetsMan.getTexture( "WarUI_ready2" );
					readyStart.scaleX = readyStart.scaleY = 2;
					readyStart.alpha = 1;
					phase = 1;
					SoundMan.playSfx(SoundMan.GO);
					break;
				case 1:
					readyStart.texture = TDGame.assetsMan.getTexture( "WarUI_start" );
					readyStart.scaleX = readyStart.scaleY = 2;
					readyStart.alpha = 1;
					phase = 0;
					break;
			}

			tween = new Tween( readyStart, 0.8, Transitions.EASE_OUT_BOUNCE );
			tween.animate( "scaleX", 1 );
			tween.animate( "scaleY", 1 );
			//			tween.fadeTo( .5 );
			tween.onComplete = onTweenComplete;
			Starling.juggler.add( tween );
		}
	}
}
