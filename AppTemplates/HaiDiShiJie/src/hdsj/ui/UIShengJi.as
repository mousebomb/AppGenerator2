/**
 * Created by rhett on 16/2/16.
 */
package hdsj.ui
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import hdsj.OwnShengJiVO;
	import hdsj.ShengJiModel;

	import hdsj.YuChangModel;

	import org.mousebomb.GameConf;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import ui.ShengJi;
	import ui.ShengJiLi;

	public class UIShengJi extends Sprite implements IDispose
	{
		private var _ui:ShengJi;
		private var shelf:Shelf;

		public function UIShengJi()
		{
			super();
			_ui = new ShengJi();
			shelf = new Shelf();
			var pageCount:int = (GameConf.VISIBLE_SIZE_H_MINUS_AD - 100 - 100) / 115;
			shelf.config( 0, 115, pageCount, 1, ShengJiLi, liVoGlue );
			shelf.y = 100;
			shelf.x = 20;
			_ui.addChild( shelf );
			addChild( _ui );
			_ui.prevBtn.y = _ui.nextBtn.y = GameConf.VISIBLE_SIZE_H_MINUS_AD - 50;
			_ui.closeBtn.addEventListener( MouseEvent.CLICK, onCloseClick );
			_ui.prevBtn.addEventListener( MouseEvent.CLICK, onPreClick );
			_ui.nextBtn.addEventListener( MouseEvent.CLICK, onNextClick );
			//
			GlobalFacade.regListener( NotifyConst.CASH_CHANGED, onNCashChanged );

			_ui.yuETf.text = YuChangModel.getInstance().cash.toString();
			//
			shelf.setList( ShengJiModel.getInstance().ownShengjiList );
			if( pageCount >= ShengJiModel.getInstance().ownShengjiList.length )
			{
				_ui.prevBtn.visible = _ui.nextBtn.visible = false;
			}
			_ui.closeBtn.addEventListener( MouseEvent.CLICK, onCloseClick );

		}

		private function onPreClick( event:MouseEvent ):void
		{
			shelf.prevPage();
		}

		private function onNextClick( event:MouseEvent ):void
		{
			shelf.nextPage();
		}

		private function liVoGlue( li:ShengJiLi, vo:OwnShengJiVO ):void
		{
			var price :int = ShengJiModel.getInstance().calcShengJiPrice( vo.level );
			var cash:int = YuChangModel.getInstance().cash;
			if( cash>=price && vo.maxLevel>vo.level)
				li.gotoAndStop( 1 );
			else
				li.gotoAndStop(2);
			li.nameTf.text = vo.name;
			li.introTf.text = vo.intro;
			li.levelTf.text = vo.level.toString();
			li.percentTf.text = vo.percent.toString();
			li.dangqianTf.text = "当前" + vo.name;
			li.priceTf.text = price.toString();
			li.addEventListener( MouseEvent.CLICK, onLiClick );
		}

		private function onLiClick( event:MouseEvent ):void
		{
			var index:int = shelf.getChildIndex( event.currentTarget as DisplayObject );
			ShengJiModel.getInstance().upgrade( index );
			var vo:OwnShengJiVO = ShengJiModel.getInstance().ownShengjiList[index];
			var li:ShengJiLi = event.currentTarget as ShengJiLi;
			li.levelTf.text = vo.level.toString();
			li.percentTf.text = vo.percent.toString();
			li.priceTf.text = ShengJiModel.getInstance().calcShengJiPrice( vo.level ).toString();
		}

		private function onNCashChanged( n:Notify ):void
		{
			_ui.yuETf.text = YuChangModel.getInstance().cash.toString();
			// 更新列表项
			shelf.setList(ShengJiModel.getInstance().ownShengjiList);
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
