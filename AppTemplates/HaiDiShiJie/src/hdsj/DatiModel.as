/**
 * Created by rhett on 16/2/15.
 */
package hdsj
{

	import hdsj.ShengJiModel;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	public class DatiModel
	{

		private static var _instance:DatiModel;

		public static function getInstance():DatiModel
		{
			if( _instance == null )
				_instance = new DatiModel();
			return _instance;
		}

		public function DatiModel()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
			init();
		}

		public function get zhengQueLv():String
		{
			return int(100*statZhengQueShu / statDatiShu).toString();
		}
		public var statDatiShu:int =0;
		public var statZhengQueShu:int =0;
		public var statLastPlayDate:Number=0;
		public var statTotalPlayDays:int = 0;
		public var statMaxLianSheng:int = 0;
		private function init():void
		{
//			从SO读取
			var savStr:String = SaveFile.getInstance().readFile("dati");
			if(savStr)
			{
				var savObj:Object = JSON.parse(savStr);
				statDatiShu = savObj.statDatiShu;
				statZhengQueShu = savObj.statZhengQueShu;
				statLastPlayDate = savObj.statLastPlayDate;
				statTotalPlayDays = savObj.statTotalPlayDays;
				statMaxLianSheng = savObj.statMaxLianSheng;
			}else{
				statDatiShu = 0;
			}
			GlobalFacade.regListener( NotifyConst.SAVE_TICK, onNSave );

		}
		public var needSaveFlag:Boolean;

		public function save():void
		{
			var sav:Object = {statDatiShu:statDatiShu, statZhengQueShu:statZhengQueShu, statLastPlayDate:statLastPlayDate
			,statTotalPlayDays:statTotalPlayDays,statMaxLianSheng:statMaxLianSheng};
			var savStr:String = (JSON.stringify( sav ));
			SaveFile.getInstance().writeFile( "dati", savStr );
			needSaveFlag = false;

		}
		private function onNSave( n:Notify ):void
		{
			if( needSaveFlag ) save();
		}


		//
		public var curQuestion : QuestionVO;
		//
		public var numQuestion : int = 0;
		/**
		 * 生成并返回下一题
		 */
		public function getNextQuestion():void
		{
			//			var index:int = (_questionBeginFrom + numQuestion) % timuModel.count;
			//			trace('index: ' + (index));
			//			curQuestion = timuModel.questions[ index ];
			curQuestion = Game.timuModel.next();
			if( !CONFIG::DEBUG )
				curQuestion.randomize();
			++numQuestion;
			GlobalFacade.sendNotify( NotifyConst.QUESTION_CHANGED, this );
		}


		public function startLevel():void
		{
			numQuestion=0;
			lianSheng = 0;
			jinbi =0;
			jinbi2=0;
			getNextQuestion();
			//
			var today :Date = new Date();
			var lastPlayDate :Date = new Date(statLastPlayDate);
			if(today.getDate() != lastPlayDate.getDate())
				statTotalPlayDays++;
			statLastPlayDate = (new Date()).valueOf();
		}


		/** 连胜次数 */
		public var lianSheng:int;
		/** 金币 */
		public var jinbi:int;
		/** 连胜额外金币 */
		public var jinbi2:int;
		/**
		 * 填写答案
		 */
		public function inputAns(isCorrect : Boolean) : void
		{
			statDatiShu++;
			if (isCorrect)
			{
				++lianSheng;
				jinbi+= ShengJiModel.getInstance().calcJinbiReward();
				jinbi2+= ShengJiModel.getInstance().calcLianShengJinbiReward(lianSheng);
				statZhengQueShu ++;
				if(lianSheng > statMaxLianSheng)
				{
					statMaxLianSheng = lianSheng;
				}
			}
			else
			{
				// 答错
				lianSheng=0;
			}
			needSaveFlag = true;
		}


	}
}
