/**
 * Created by rhett on 15/6/12.
 */
package YP
{

    import com.aoaogame.sdk.adManager.MyAdManager;
    import com.greensock.TweenLite;
    import com.greensock.TweenMax;
    import com.greensock.easing.Linear;

    import flash.display.Loader;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TouchEvent;
    import flash.events.TransformGestureEvent;
    import flash.filesystem.File;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.Capabilities;
    import flash.system.LoaderContext;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;

    import org.mousebomb.GameConf;

    import org.mousebomb.GameConf;

    import org.mousebomb.GameConf;
    import org.mousebomb.SoundMan;

    import org.mousebomb.interfaces.IDispose;

    public class YPListen extends Sprite implements IDispose
    {
        private var ui:ListenUI;
        /** 当前页 0开始 */
        private var curPage:int = 0;
        private var _vo:MusicInfoVO;
        private var offsetX : Number ;

        public function YPListen( vo:MusicInfoVO ,showBackBtn:Boolean=true )
        {
            super();
            offsetX = (GameConf.DESIGN_SIZE_W - GameConf.VISIBLE_SIZE_W) /2;
            trace("offsetX",offsetX);
            _vo = vo;
            ui = new ListenUI();
            ui.x = (GameConf.VISIBLE_SIZE_W - GameConf.DESIGN_SIZE_W) / 2;
            addChild( ui );
            ui.backBtn.visible = showBackBtn;
            ui.backBtn.addEventListener( MouseEvent.CLICK, onBackClick );
            ui.restartBtn.addEventListener( MouseEvent.CLICK, onRestartClick );
            ui.prevBtn.addEventListener(MouseEvent.CLICK, onPrevClick);
            ui.nextBtn.addEventListener(MouseEvent.CLICK, onNextClick);
            ui.prevBtn.x = ui.prevBtn.width/2 + 25 + offsetX;
            ui.nextBtn.x = GameConf.VISIBLE_SIZE_W - ui.prevBtn.width/2 - 25 + offsetX;
            ui.prevBtn.visible = ui.nextBtn.visible = (_vo.pages.length>1);
            ui.restartBtn.y = GameConf.VISIBLE_SIZE_H_MINUS_AD - ui.restartBtn.height - 25;
            ui.restartBtn.x = GameConf.VISIBLE_SIZE_W - ui.restartBtn.width - 25 +offsetX;
            if(ui.titleTf) ui.titleTf.text = _vo.mp3Name;
            //			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    //			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            //
            ui.moreBtn.visible= AoaoBridge.isMoreBtnVisible;
            ui.moreBtn.addEventListener(MouseEvent.CLICK,onMoreClick);
            //
            loadPage( 0 );

            if( !CONFIG::DESKTOP )
            {
                AoaoBridge.banner(this);
            }
        }

        private function onMoreClick( event:MouseEvent ):void
        {
            AoaoBridge.gengDuo(this);
        }

        private function onNextClick( event:MouseEvent ):void
        {
            loadPage(curPage+1);
            if( !CONFIG::DESKTOP )
            {
                AoaoBridge.interstitial(this);
            }
        }

        private function onPrevClick( event:MouseEvent ):void
        {
            loadPage(curPage-1);
            if( !CONFIG::DESKTOP )
            {
                AoaoBridge.interstitial(this);
            }
        }


        private function onRestartClick( event:MouseEvent ):void
        {
            if(_isSwf)
            {
                loadPage(curPage);
            }
            else
            {
                Player.getInstance().reset();
            }

            SoundMan.playSfx( SoundMan.BTN );
        }

        private function onBackClick( event:MouseEvent ):void
        {
            if( !CONFIG::DESKTOP )
            {
                AoaoBridge.interstitial(this);
            }
            Game.instance.replaceScene( new YPSelect() );
            SoundMan.playSfx( SoundMan.BTN );
        }


        /* ------------------- # PAGE # ---------------- */

        private var imgLoader:Loader;

        public function loadPage( page:int ):void
        {
            if(_vo.pages.length <= page)
            {
                //翻页循环
                page = 0;
            }
            if(_vo.pages.length> page  && page >-1)
            {
                Player.getInstance().stop();
                ui.restartBtn.visible =false;
                if( imgLoader != null )
                {
                    // 先移除
                    flyOutCurLoader(page>curPage);
                }
                imgLoader = new Loader();
                var ctx :LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain)
    //				ctx.allowCodeImport = true;
                imgLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onImgLoaded );
                var pageInf:PageInfoVO = _vo.pages[page];
                imgLoader.load( new URLRequest( pageInf.imgFile.url ) ,ctx );
                curPage = page;

            }
        }

        private function disposeCurLoader():void
        {
            if(imgLoader)imgLoader.unloadAndStop();
        }

        private function flyOutCurLoader(isLeft :Boolean = false):void
        {
    //			imgLoader.unloadAndStop();
            loaderRemComp(imgLoader);
    //			TweenMax.to( imgLoader,.4,{x:isLeft?-768:768 ,onComplete:loaderRemComp,onCompleteParams:[imgLoader]});
            //如果flash 要关闭声音
        }
        private function loaderRemComp(l :Loader):void
        {
            l.unloadAndStop(true);
            if(l.parent) l.parent.removeChild(l);
        }

        private function onImgLoaded( event:Event ):void
        {
            ui.moreBtn.visible= AoaoBridge.isMoreBtnVisible;
            imgLoader.mouseChildren = false;
            imgLoader.mouseEnabled = false;
            if(GameConf.FIT_MODE == "0" || GameConf.FIT_MODE=="")
            {
                /** 强拉 */
                imgLoader.width = GameConf.VISIBLE_SIZE_W;
                imgLoader.height = GameConf.VISIBLE_SIZE_H_MINUS_AD - 134;
                imgLoader.y = 134;
                imgLoader.x = offsetX;
            }else
            {
                /** 等比例 */
                var maxW:Number = GameConf.VISIBLE_SIZE_W;
                var maxH :Number = GameConf.VISIBLE_SIZE_H_MINUS_AD - 134;
                var sw :Number = maxW/imgLoader.width ;
                var sh :Number = maxH/imgLoader.height ;
                var scale : Number;
                if(GameConf.FIT_MODE == "1" || GameConf.FIT_MODE == "2")
                {
                    scale = sw > sh ? sh : sw;
                }else if(GameConf.FIT_MODE == "3")
                {
                    scale = sw < sh ? sh : sw;
                }else{
                    scale = sw > sh ? sh : sw;
                }
                imgLoader.width = scale * imgLoader.width;
                imgLoader.height = scale * imgLoader.height;
                if(GameConf.FIT_MODE == "1" || GameConf.FIT_MODE == "3")
                    imgLoader.y = 134 ;
                else if (GameConf.FIT_MODE == "2")
                    imgLoader.y = 134 + (maxH - imgLoader.height)/2;
                imgLoader.x = (maxW-imgLoader.width)/2 +offsetX;
            }
            //
            var index : int = ui.getChildIndex(ui.backBtn);
            ui.addChildAt( imgLoader , index);
            var pageInf:PageInfoVO = _vo.pages[curPage];
            _isSwf=false;
            if (pageInf.imgFile.extension == 'swf')
            {
                ui.restartBtn.visible =true;
                _isSwf = true;
            }else if(pageInf.mp3File!=null)
            {
                ui.restartBtn.visible =true;
                Player.getInstance().play(pageInf.mp3File.url);
            }

        }

        //swf模式 重播是重播swf;否则重播是音乐mp3
        private var _isSwf :Boolean = false;

        public function dispose():void
        {
            disposeCurLoader();
            Player.getInstance().stop();
        }

    }
}
