package td.battlefield.view
{
	import org.mousebomb.SoundMan;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.AssetManager;

	import td.NotifyConst;

	import org.mousebomb.framework.GlobalFacade;

	/**
	 * @author rhett
	 */
	public class EnemyIntroUI extends Sprite
	{
		private var bg : Image ;
		private var tween : Tween;
		public function EnemyIntroUI( enemyId : int )
		{
			var a :AssetManager = TDGame.assetsMan;
			bg = new Image ( a.getTexture("Intro"));
			bg.alignPivot();
			addChild(bg);
			var img : Image = new Image(a.getTexture("MI"+enemyId));
			img.alignPivot();
			addChild(img);
			this.addEventListener(TouchEvent.TOUCH, onTouch);

this.scaleX=.1;
this.scaleY=.1;
			tween = new Tween( this, 0.8, Transitions.EASE_OUT_BOUNCE );
			tween.animate( "scaleX", 1 );
			tween.animate( "scaleY", 1 );
			//			tween.fadeTo( .5 );
			Starling.juggler.add( tween );
		}

		private function onTouch(event : TouchEvent) : void
		{
			if(event.getTouch(this,TouchPhase.ENDED))
			{
				removeFromParent(true);
				GlobalFacade.sendNotify(NotifyConst.UI_ENEMY_INTRO_HIDE, this);
				SoundMan.playSfx(SoundMan.BTN);
			}
		}
	}
}
