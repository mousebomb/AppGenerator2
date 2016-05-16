package game.view
{
	import flash.geom.ColorTransform;

	import game.model.GameDataModel;
	import game.model.LevelModel;
	import game.model.vo.LevelVO;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.mousebomb.ui.Shelf;
	import org.robotlegs.mvcs.Mediator;

	import flash.events.MouseEvent;

	/**
	 * @author Mousebomb
	 */
	public class UILevelMediator extends Mediator
	{
		private var shelf : Shelf;

		public function UILevelMediator()
		{
		}

		[Inject]
		public var gameDataModel : GameDataModel;
		[Inject]
		public var levelModel : LevelModel;

		override public function onRegister() : void
		{
			var ui : UILevel = viewComponent as UILevel;
			ui.x = GameConf.VISIBLE_SIZE_W / 2;

			shelf = new Shelf();
			shelf.x = -250;
			shelf.y = 182;
			shelf.config((250 * 2 / 4), 268 - 117, 15, 5, LevelLi, onAddLi);
			ui.addChild(shelf);
			//
			levelModel.initAllLevels();
			shelf.setList(levelModel.levels);
			//
			ui.prevBtn.addEventListener(MouseEvent.CLICK, onPrevBtn);
			ui.nextBtn.addEventListener(MouseEvent.CLICK, onNextBtn);
			//

			ui.backBtn.x = -GameConf.VISIBLE_SIZE_W / 2 + ui.backBtn.width / 2;
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
		}

		private function onBackClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIWelcome));
		}

		private function onNextBtn(event : MouseEvent) : void
		{
			shelf.nextPage();
		}

		private function onPrevBtn(event : MouseEvent) : void
		{
			shelf.prevPage();
		}

		private function onAddLi(li : LevelLi, vo : LevelVO) : void
		{
			li.levelTf.text = vo.level.toString();
			li.levelTf.mouseEnabled = false;
			var colorTransform : ColorTransform = new ColorTransform();
			colorTransform.color = 0xaaaaaa;
			if (vo.star < 3)
			{
				li.star3.transform.colorTransform = colorTransform;
				if (vo.star < 2)
				{
					li.star2.transform.colorTransform = colorTransform;
					if (vo.star < 1)
					{
						li.star1.transform.colorTransform = colorTransform;
					}
				}
			}
			// li.star1.alpha = vo.star>0 ? 1.0 : 0.5;
			// li.star2.alpha = vo.star>1 ? 1.0 : 0.5;
			// li.star3.alpha = vo.star>2 ? 1.0 : 0.5;
			if (vo.canPlay)
			{
				li.addEventListener(MouseEvent.MOUSE_UP, onLiUp);
			}
			else
			{
				li.alpha = 0.5;
			}
			li.vo = vo;
		}

		private function onLiUp(event : MouseEvent) : void
		{
			var li : LevelLi = event.currentTarget as LevelLi;
			gameDataModel.curLevel = (li.vo as LevelVO).level;
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIGameScene));
		}
	}
}
