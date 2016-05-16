package game.view
{
	import game.model.DailyResultModel;
	import game.model.vo.DailyResultVO;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.mousebomb.ui.Shelf;
	import org.robotlegs.mvcs.Mediator;

	import flash.events.MouseEvent;

	/**
	 * @author Mousebomb
	 */
	public class UICalendarMediator extends Mediator
	{
		private var shelf : Shelf;
		[Inject]
		public var dailyResultModel : DailyResultModel;
		private var selectedLi : CalLi;

		public function UICalendarMediator()
		{
		}

		override public function onRegister() : void
		{
			var ui : UICalendar = viewComponent as UICalendar;
			ui.x = GameConf.VISIBLE_SIZE_W / 2;

			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);

			ui.dp.weekdayTf.text = "";
			ui.dp.dateTf.text = "";
			ui.dp.totalAnsTf.text = "";
			ui.dp.correctPerTf.text = "";
			ui.dp.improveTf.text = "";

			shelf = new Shelf();
			shelf.x = -268.4;
			shelf.y = 140.0;
			var marX : Number = (63.4 - shelf.x) / 4;
			var marY : Number = (540.7 - shelf.y) / 5;

			// iPad适配
			if (GameConf.WH_RATE < GameConf.WH_RATE_IPHONE4)
			{
				var eadgeLeft : Number = -GameConf.VISIBLE_SIZE_W / 2;
				var eadgeRight : Number = GameConf.VISIBLE_SIZE_W / 2;
				if (ui.dp.x > eadgeRight)
					ui.dp.x = eadgeRight;
				if (ui.backBtn.x < eadgeLeft + 62)
					ui.backBtn.x = eadgeLeft + 62;
				shelf.x = 124 + eadgeLeft + 38;
				marX = (eadgeRight - 344-39 - shelf.x) / 4;
			}

			shelf.config(marX, marY, 30, 5, CalLi, onAddLi);
			ui.addChild(shelf);
			var list : Vector.<DailyResultVO> = dailyResultModel.getRecent30DaysList();
			shelf.setList(list);
		}

		private function onBackClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIWelcome));
		}

		private function onAddLi(li : CalLi, vo : DailyResultVO) : void
		{
			li.vo = vo;
			li.tf.text = vo.date.date.toString();
			li.tf.mouseEnabled = false;
			if (vo.isPlayed)
			{
				li.gotoAndStop(2);
			}
			else
			{
				li.gotoAndStop(1);
			}
			li.addEventListener(MouseEvent.CLICK, onLiClick);
		}

		private function onLiClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			// 右侧
			var li : CalLi = event.target as CalLi;
			selectLi(li);
		}

		/**
		 * XUANZE选择
		 */
		public function selectLi(li : CalLi) : void
		{
			if (selectedLi)
			{
				if (selectedLi.vo.isPlayed)
					selectedLi.gotoAndStop(2);
				else
					selectedLi.gotoAndStop(1);
			}
			selectedLi = li;
			var vo : DailyResultVO = li.vo ;
			if (vo.isPlayed)
				li.gotoAndStop(3);
			else
				li.gotoAndStop(4);
			var dailyVO : DailyResultVO = li.vo as DailyResultVO;
			var ui : UICalendar = viewComponent as UICalendar;
			ui.dp.weekdayTf.text = dailyVO.weekday;
			ui.dp.dateTf.text = dailyVO.dateYmd;
			ui.dp.totalAnsTf.text = dailyVO.totalAnswer.toFixed();
			ui.dp.correctPerTf.text = dailyVO.correctPer.toFixed();
			if (dailyVO.improved > 0)
				ui.dp.improveTf.text = "+" + dailyVO.improved.toFixed();
			else
				ui.dp.improveTf.text = dailyVO.improved.toFixed();
		}
	}
}
