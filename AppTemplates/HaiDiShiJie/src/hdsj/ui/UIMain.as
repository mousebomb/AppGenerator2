/**
 * Created by rhett on 16/2/15.
 */
package hdsj.ui
{

import com.aoaogame.sdk.adManager.MyAdManager;
import com.greensock.TimelineLite;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.Back;
import com.greensock.easing.Linear;
import com.greensock.easing.Quad;

import flash.utils.getTimer;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;

import hdsj.YuChangModel;

import org.mousebomb.GameConf;
import org.mousebomb.SoundMan;
import org.mousebomb.framework.GlobalFacade;
import org.mousebomb.framework.Notify;
import org.mousebomb.interfaces.IDispose;

import ui.MainMenu;
import ui.TopBar;

	public class UIMain extends Sprite
	{
		private var _menu:MainMenu;
		private var _top:TopBar;
		private var model:YuChangModel;

		private static var _instance:UIMain;

		public function UIMain()
		{
			_instance=this;
			_top = new TopBar();
			addChild( _top );
			_menu = new MainMenu();
			addChild( _menu );
			_menu.y = GameConf.VISIBLE_SIZE_H_MINUS_AD - 360;
			_menu.x = GameConf.DESIGN_SIZE_W - 60  +(GameConf.VISIBLE_SIZE_W -GameConf.DESIGN_SIZE_W)/2;
			//
			_menu.datiBtn.addEventListener( MouseEvent.CLICK, onDaTiClick );
			_menu.cangkuBtn.addEventListener( MouseEvent.CLICK, onCangKuClick );
			_menu.shengjiBtn.addEventListener( MouseEvent.CLICK, onShengJiClick );
			_menu.zhanjiBtn.addEventListener( MouseEvent.CLICK, onZhanJiClick );
			_menu.bizhiBtn.addEventListener( MouseEvent.CLICK, onBiZhiClick );
			_menu.moreBtn.addEventListener( MouseEvent.CLICK, onMoreClick );
			_menu.moreBtn.visible = AoaoBridge.isMoreBtnVisible;
			//
			GlobalFacade.regListener( NotifyConst.CASH_CHANGED, onNCashChanged );
			GlobalFacade.regListener( NotifyConst.POOL_CHANGED, onNPoolChanged );
			GlobalFacade.regListener( NotifyConst.CLOSE_POPUP_UI, onNCloseUI );
			//
			model = YuChangModel.getInstance();
			_top.cashTf.text = model.cash.toString();
			_top.poolTf.text = model.getCurPoolName();

		}

		private function onMoreClick( event:MouseEvent ):void
		{
			AoaoBridge.gengDuo(this);
			SoundMan.playSfx(SoundMan.BTN);
		}
        private var lastShowInterstitial: int =0;

        private function onNCloseUI( n:Notify ):void
		{
			this.close();
            var now:int  = getTimer();
            if(now - lastShowInterstitial > 30000) {
                AoaoBridge.interstitial(this);
                lastShowInterstitial = now;
            }
            _menu.moreBtn.visible = AoaoBridge.isMoreBtnVisible;
		}


		private function onNCashChanged( n:Notify ):void
		{
			var isFlashRightNow:Boolean = n.data;
			var oldCash:int = parseInt( _top.cashTf.text );
			_top.cashTf.text = model.cash.toString();
			if( model.cash < oldCash ) return;
			var hasTween:Boolean = (TweenLite.getTweensOf(_top.cashTf).length);
			TweenLite.killTweensOf(_top.cashTf);
			var tl :TimelineLite = new TimelineLite();
			if(!isFlashRightNow  && !hasTween) tl.to( _top.cashTf, 0.9, {alpha:1, ease:Linear.easeNone} );
			tl.to( _top.cashTf, 0.1, {scaleX:2, scaleY:2, ease:Linear.easeNone} );
			tl.to( _top.cashTf, 1, {scaleX:1, scaleY:1, ease:Back.easeInOut} );
			tl.play();
		}

		private function onNPoolChanged( n:Notify ):void
		{
			_top.poolTf.text = model.getCurPoolName();
		}

		private function onZhanJiClick( event:MouseEvent ):void
		{
			present( new UIZhanJi() );
		}

		private function onShengJiClick( event:MouseEvent ):void
		{
			present( new UIShengJi() );
		}

		private function onCangKuClick( event:MouseEvent ):void
		{
			present( new UICangKu() );
		}

		private function onDaTiClick( event:MouseEvent ):void
		{
			present( new UIDati() );
		}

		private function onBiZhiClick( event:MouseEvent ):void
		{
			present( new UIBiZhi() );
		}

		public static function hasPopupUI():Boolean
		{
			return popupUI != null;
		}

		private static var popupUI:DisplayObject;
		//
		public function present( ui:DisplayObject ):void
		{
			popupUI = ui;
			addChild( ui );
			var deltaX:Number = (GameConf.VISIBLE_SIZE_W - GameConf.DESIGN_SIZE_W) /2;
			if(deltaX>0)
				popupUI.x = 100 + deltaX;
			else
				popupUI.x = 100;
			//
			AoaoBridge.banner(this);
		}

		public function close():void
		{
			removeChild( popupUI );
			if( popupUI is IDispose )
			{
				(popupUI as IDispose).dispose();
			}
			popupUI = null;
		}

		/** 调用 飞金币 */
		public static function flyCash( cash:DisplayObject ):void
		{
			if(cash.parent) cash.parent.removeChild(cash);
			_instance._top.addChild(cash);
			var tl :TimelineLite = new TimelineLite();
			tl.add(	TweenMax.from(cash , 0.3, {alpha:0,ease:Quad.easeIn}));
			tl.add(	TweenMax.to(cash , 0.2, {x:cash.x+30,y: (cash.y -30)/2,ease:Quad.easeIn}));
			tl.add(	TweenMax.to(cash , 0.5, {x:40,y:30,ease:Quad.easeOut , onComplete:function(){cash.parent.removeChild(cash);}}));
//			tl.delay(1);
			tl.play();
		}
	}
}
