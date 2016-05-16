/**
 * Created by rhett on 16/2/16.
 */
package hdsj.ui
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import hdsj.DatiModel;

	import hdsj.YuChangModel;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.ui.Shelf;

	import ui.PoolLi;

	import ui.ZhanJi;

	public class UIZhanJi extends Sprite
	{
		private var _ui :ZhanJi;
		private var shelf:Sprite;

		public function UIZhanJi()
		{
			super();
			_ui= new ZhanJi();
			addChild(_ui);
			_ui.closeBtn.addEventListener( MouseEvent.CLICK, onCloseClick );
			//
			var ycModel :YuChangModel=YuChangModel.getInstance();
			var datiModel:DatiModel = DatiModel.getInstance();
			_ui.poolNumTf.text = ycModel.fishPoolOpenCount.toString();
			_ui.daTiShuTf.text = datiModel.statDatiShu.toString();
			_ui.dayTf .text = datiModel.statTotalPlayDays.toString();
			_ui.fishNumTf.text = ycModel.ownFishTotalNum.toString();
			_ui.zhengqueLvTf.text = datiModel.zhengQueLv;
			_ui.zuidaLianShengTf.text = datiModel.statMaxLianSheng.toString();
			_ui.fishMaxNumTf.text = ycModel.fishPoolOpenCapacity.toString();
			//
			shelf =new Sprite();
			shelf.x =158;shelf.y=186;
			_ui.addChild(shelf);
			var marginX:Number = 182.35-158;
			var marginY:Number = 210.9-186.15;
			for(var i : int = 0;i<10;i++)
			{
				for(var j:int = 0;j<10;j++)
				{
					var li :PoolLi = new PoolLi();
					li.x = marginX *i;
					li.y = marginY *j;
					shelf.addChild(li);
					var curIndex : int = i * 10 + j+1;
					if(curIndex>ycModel.fishPoolOpenCount)
					{
						li.gotoAndStop(1);
					}else{
						li.gotoAndStop(2);
					}
				}
			}
		}
		private function onCloseClick( event:MouseEvent ):void
		{
			GlobalFacade.sendNotify( NotifyConst.CLOSE_POPUP_UI, this );
		}
	}
}
