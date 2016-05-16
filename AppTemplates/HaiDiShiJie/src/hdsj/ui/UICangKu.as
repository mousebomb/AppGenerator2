/**
 * Created by rhett on 16/2/16.
 */
package hdsj.ui
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;

	import hdsj.OwnFishVO;
	import hdsj.YuChangModel;

	import org.mousebomb.GameConf;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import ui.CangKu;
	import ui.CangKuLi;

	public class UICangKu extends Sprite implements IDispose
	{
		private var _ui:CangKu;
		private var shelf:Shelf;

		public function UICangKu()
		{
			super();
			_ui = new CangKu();
			shelf = new Shelf();
			var pageCount : int = (GameConf.VISIBLE_SIZE_H_MINUS_AD-100-100)/90;
			shelf.config( 0, 90, pageCount, 1, CangKuLi, liVoGlue );
			shelf.y = 100;
			shelf.x = 20;
			_ui.addChild( shelf );
			addChild( _ui );
			_ui.prevBtn.y = _ui.nextBtn.y = GameConf.VISIBLE_SIZE_H_MINUS_AD-50;
			_ui.closeBtn.addEventListener( MouseEvent.CLICK, onCloseClick );
			_ui.prevBtn.addEventListener( MouseEvent.CLICK, onPreClick );
			_ui.nextBtn.addEventListener( MouseEvent.CLICK, onNextClick );
			//
			GlobalFacade.regListener( NotifyConst.CASH_CHANGED, onNCashChanged );

			_ui.yuETf.text = YuChangModel.getInstance().cash.toString();
			//
			shelf.setList( YuChangModel.getInstance().canBuyFishList() );
		}

		private function onPreClick( event:MouseEvent ):void
		{
			shelf.prevPage();
		}

		private function onNextClick( event:MouseEvent ):void
		{
			shelf.nextPage();
		}

		private function liVoGlue( li:CangKuLi, vo:OwnFishVO ):void
		{
			var clazz:Class = getDefinitionByName( "Fish" + vo.type + "_" + vo.id ) as Class;
			var _fishMc:MovieClip = new clazz();
			_fishMc.stop();
			_fishMc.x = li.fishCircle.x+li.fishCircle.width/2;
			_fishMc.y = li.fishCircle.y+li.fishCircle.height/2;
			var sx:Number=li.fishCircle.width/_fishMc.width ;
			var sy:Number =li.fishCircle.height/_fishMc.height;
			var s = sx<sy?sx:sy;
			_fishMc.scaleX=_fishMc.scaleY = s;
			li.addChild( _fishMc );
			li.numTf.text = vo.num.toString();
			li.priceTf.text = YuChangModel.getInstance().calcFishPrice(vo.type,vo.id).toString();
			if( YuChangModel.getInstance().canBuyFish( vo.type,vo.id) )
				li.gotoAndStop(1);
			else
				li.gotoAndStop(2);
			li.name = vo.type+"_"+vo.id;
			li.addEventListener(MouseEvent.CLICK, onLiClick);
		}

		private function onLiClick( event:MouseEvent ):void
		{
			//买
			var li :CangKuLi = event.currentTarget as CangKuLi;
			var liName :String = event.currentTarget.name;
			var dataArr:Array = liName.split("_");
			var type :int = dataArr[0];
			var id :int = dataArr[1];
			var prompt:String = YuChangModel.getInstance().buyFish(type,id);
			if(prompt)
				Game.warning(prompt);
			else
			{
				if(li.numTf.text == "0")
				{
					//刚买了新的，解锁下一个
					var newList :Array = YuChangModel.getInstance().canBuyFishList();
					if(newList.length > shelf.numChildren)
					{
						shelf.setList(newList);
					}
				}else{
					li.numTf.text = (parseInt(li.numTf.text) + 1).toString();
				}
			}
		}

		private function onNCashChanged( n:Notify ):void
		{
			_ui.yuETf.text = YuChangModel.getInstance().cash.toString();
			// 更新列表项
			shelf.setList( YuChangModel.getInstance().canBuyFishList() );
		}

		private function onCloseClick( event:MouseEvent ):void
		{
			GlobalFacade.sendNotify( NotifyConst.CLOSE_POPUP_UI, this );
		}

		public function dispose():void
		{
			GlobalFacade.removeListener( NotifyConst.CASH_CHANGED, onNCashChanged );

		}
	}
}
