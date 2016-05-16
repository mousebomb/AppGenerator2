/**
 * Created by rhett on 16/2/15.
 */
package hdsj.ui
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;

	import hdsj.DatiModel;
	import hdsj.QuestionVO;
	import hdsj.YuChangModel;

	import org.mousebomb.SoundMan;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;
	import org.mousebomb.interfaces.IDispose;

	import ui.Dati;

	public class UIDati extends Sprite implements IDispose
	{
		private var _ui:Dati;
		private var datiModel:DatiModel;

		public function UIDati()
		{
			super();
			datiModel = DatiModel.getInstance();
			_ui = new Dati();
			addChild( _ui );
			_ui.closeBtn.addEventListener( MouseEvent.CLICK, onCloseClick );
			_ui.a1Btn.addEventListener( MouseEvent.CLICK, onAnsClick );
			_ui.a2Btn.addEventListener( MouseEvent.CLICK, onAnsClick );

			//
			GlobalFacade.regListener( NotifyConst.QUESTION_CHANGED, onNQuestionChanged );

			datiModel.startLevel();
			_ui.lianshengTf.text = datiModel.lianSheng.toString();
			_ui.jinbiTf.text = datiModel.jinbi.toString();
			_ui.liansheng2Tf.text = datiModel.jinbi2.toString();
		}

		private function onNQuestionChanged( n:Notify ):void
		{
			var q:QuestionVO = datiModel.curQuestion;
			_ui.a1Tf.text = q.allAwnsers[0];
			_ui.a2Tf.text = q.allAwnsers[1];
			_ui.timuTf.text = q.question;
			_ui.numTf.text = datiModel.numQuestion.toString();
			_ui.a1Btn.mouseEnabled = _ui.a2Btn.mouseEnabled = _ui.a1Btn.visible = _ui.a2Btn.visible = true;
		}

		private var timeoutHandle:*;

		private function onAnsClick( event:MouseEvent ):void
		{
			var ans:String;
			switch( event.currentTarget )
			{
				case _ui.a1Btn:
					ans = _ui.a1Tf.text;
					break;
				case _ui.a2Btn:
					ans = _ui.a2Tf.text;
					break;
			}
			var isCorrect:Boolean = ans == datiModel.curQuestion.rightAns;
			datiModel.inputAns( isCorrect );
			if( isCorrect )
			{
				next();
				SoundMan.playSfx( SoundMan.RIGHT );
			} else
			{
				// 显示正确项目 1秒钟
				showRightAns( datiModel.curQuestion.rightAns );
				SoundMan.playSfx( SoundMan.WRONG );
			}
			//
			_ui.lianshengTf.text = datiModel.lianSheng.toString();
			_ui.jinbiTf.text = datiModel.jinbi.toString();
			_ui.liansheng2Tf.text = datiModel.jinbi2.toString();

		}

		private function showRightAns( rightAns:String ):void
		{
			for( var i:int = 1; i <= 2; i++ )
			{
				var ans:String = _ui['a' + i + 'Tf']['text'];
				if( rightAns == ans )
				{
					_ui['a' + i + "Btn"]['mouseEnabled'] = false;
				} else
				{
					_ui['a' + i + "Tf"]['text'] = "";
					_ui['a' + i + "Btn"]['visible'] = false;
				}
			}
			timeoutHandle = setTimeout( next, 1000 );
		}

		private function next():void
		{
			datiModel.getNextQuestion();
		}

		private function onCloseClick( event:MouseEvent ):void
		{
			GlobalFacade.sendNotify( NotifyConst.CLOSE_POPUP_UI, this );
		}


		public function dispose():void
		{
			//金币给
			YuChangModel.getInstance().cash += (datiModel.jinbi + datiModel.jinbi2);
			GlobalFacade.sendNotify( NotifyConst.CASH_CHANGED, this ,true );
			//
			GlobalFacade.removeListener( NotifyConst.QUESTION_CHANGED, onNQuestionChanged );
		}
	}
}
