package td.battlefield.view
{
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.utils.AssetManager;

	import td.NotifyConst;

	import org.mousebomb.SoundMan;
	import org.mousebomb.framework.GlobalFacade;

	/**
	 * @author rhett
	 */
	public class BattleIntroUI extends Sprite
	{
		private var bg : Image ;
		private var tween : Tween;
		private var img : Image;
		private var index : int = 0;
		private var ts : Vector.<Texture>;

		public function BattleIntroUI(ts_ : Vector.<Texture>)
		{
			this.ts = ts_;
			var a : AssetManager = TDGame.assetsMan;
			bg = new Image(a.getTexture("Intro"));
			bg.alignPivot();
			addChild(bg);

			index = 0;
			img = new Image(ts[index]);
			img.alignPivot();
			addChild(img);
			this.addEventListener(TouchEvent.TOUCH, onTouch);

			this.scaleX = .1;
			this.scaleY = .1;
			tween = new Tween(this, 0.8, Transitions.EASE_OUT_BOUNCE);
			tween.animate("scaleX", 1);
			tween.animate("scaleY", 1);
			// tween.fadeTo( .5 );
			Starling.juggler.add(tween);
		}

		private function onTouch(event : TouchEvent) : void
		{
			if (event.getTouch(this, TouchPhase.ENDED))
			{
				next();
				SoundMan.playSfx(SoundMan.BTN);
			}
		}

		private function next() : void
		{
			if (ts.length > ++index)
			{
				img.texture=ts[index];
			}else{
				removeFromParent(true);
				GlobalFacade.sendNotify(NotifyConst.UI_BATTLE_INTRO_HIDE, this);
			}
		}
	}
}
