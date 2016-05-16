package org.mousebomb.zhaocha.gamewin
{
	import gs.TweenLite;
	import gs.easing.Back;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.mousebomb.zhaocha.common.SceneEvent;
	import org.robotlegs.mvcs.Mediator;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author rhett
	 */
	public class UIGameWinMediator extends Mediator
	{
		public function UIGameWinMediator()
		{
		}

		override public function onRegister() : void
		{
			(viewComponent as Sprite).addEventListener(MouseEvent.CLICK, onClick);
			var ui :Sprite = (viewComponent as Sprite);
			ui.x = GameConf.VISIBLE_SIZE_W *.5;
			ui.y = GameConf.VISIBLE_SIZE_H *.5;
			ui.scaleX = 2;
			ui.scaleY = 2;
			TweenLite.to(ui, 1.0, {scaleX:1.0,scaleY:1.0,ease:Back.easeInOut});
		}

		private function onClick(event : MouseEvent) : void
		{
			(viewComponent as Sprite).removeEventListener(MouseEvent.CLICK, onClick);
			
        	SoundMan.playSfx(SoundMan.BTN);
			// 点击奖杯 回首页
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIWelcome));
		}
	}
}
