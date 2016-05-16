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
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import td.NotifyConst;
	import td.battlefield.model.BattleFieldModel;

	import org.mousebomb.SoundMan;
	import org.mousebomb.framework.GlobalFacade;

	/**
	 * 本UI 居中对齐
	 */
	public class WinUI extends Sprite
	{
		private var bg:Image;
		private var tween : Tween;
		public function WinUI( )
		{
			var a:AssetManager = TDGame.assetsMan;
			bg = new Image( a.getTexture( "pauseUI" ) );
			bg.alignPivot();
			addChild( bg );
			
			var title :Image = new Image(a.getTexture("WarUI_WarResultWin"));
			title.alignPivot();
			title.y = -115;
			addChild(title);

			var nextBtn:Button = new Button( a.getTexture( "WarUI_WarResultGoOn" ));
			nextBtn.alignPivot();
			addChild( nextBtn );
			// 如果没有下一关，则按钮屏蔽
			nextBtn.enabled = BattleFieldModel.getInstance().hasNextBattle();

			var selectBtn:Button = new Button( a.getTexture( "WarUI_WarResultSelectmap" ) );
			selectBtn.alignPivot();
			selectBtn.y = 100;
			addChild( selectBtn );

			//
			nextBtn.addEventListener( Event.TRIGGERED, onClick );
			selectBtn.addEventListener( Event.TRIGGERED, onLevelClick );
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
			removeFromParent( true );
			GlobalFacade.sendNotify( NotifyConst.UI_GOTO_SELECTLEVEL, this );
		}

		private function onClick( event:Event ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			removeFromParent( true );
			GlobalFacade.sendNotify( NotifyConst.UI_GOTO_NEXT, this );
		}

		private var starImg:Image;
		public function setStar( star:int ):void
		{
			if( star > 0 )
			{
			var starT:Texture = TDGame.assetsMan.getTexture( "star"+star );
				starImg = new Image( starT );
				starImg.alignPivot(HAlign.CENTER,VAlign.BOTTOM);
				starImg.y = -bg.height/2;
				addChild( starImg );
				
			}
		}

	}
}
