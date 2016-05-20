package org.mousebomb.pin9gong
{

    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filesystem.File;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.utils.setTimeout;

    import gs.TweenLite;
    import gs.easing.Back;
    import gs.easing.Sine;

    import org.mousebomb.GameConf;
    import org.mousebomb.IFlyIn;
    import org.mousebomb.SoundMan;
    import org.mousebomb.interfaces.IDispose;

    import yizhidaquan.YiZhiDaQuan;

    /**
 * @author rhett
 */
public class P9Game extends Sprite implements IDispose,IFlyIn
{
    private var ui:UIP9Game;
    private var levelModel:P9LevelModel;
    private var bg:Sprite;

    /** 显示区域 */
    private var picRect:Rectangle;

    public function P9Game()
    {
        //
        ui = new UIP9Game();
        ui.bottom.y = GameConf.VISIBLE_SIZE_H_MINUS_AD;
        ui.win.visible = false;
        ui.bottom.nextBtn.visible = false;
        ui.bottom.nextBtn.addEventListener( MouseEvent.CLICK, onNextBtnClick );
        //
        ui.win.addEventListener( MouseEvent.CLICK, onWinClick );
        //
        levelModel = P9LevelModel.getInstance();
        //

        // 计算一个适合分辨率的显示区域   左右截掉或上下截掉
        var bitmapX:Number = (GameConf.DESIGN_SIZE_W - GameConf.VISIBLE_SIZE_W) * .5;
        var bitmapY:Number = MENUPANEL_TOP;
        var bitmapH:Number = (GameConf.VISIBLE_SIZE_H_MINUS_AD - BOTTOM_HEIGHT - MENUPANEL_TOP);
        var bitmapW:Number = GameConf.VISIBLE_SIZE_W;
        picRect = new Rectangle( bitmapX, bitmapY, bitmapW, bitmapH );
        trace("P9Game/P9Game() picRect=",picRect);
//
        bg = new Sprite();
        bg.x = picRect.x;
        bg.y = picRect.y;
        addChildAt( bg, 0 );
        //
        addChild( ui );
        ui.backBtn.addEventListener( MouseEvent.CLICK, onBackClick );

        ///
        thumb = new P9MaskeredBitmap(picRect.width,picRect.height);
        thumb.x = 74;
        thumb.y = -260;
        ui.addChild(thumb);
        //

        changeLevel( levelModel.level );
    }

    /** 相对于bottom的位置 */
    private const THUMB_X:int=74;
    private const THUMB_Y:int=-160;

    private function onWinClick( e:MouseEvent ):void
    {
        ui.win.visible = false;
    }

    private function onNextBtnClick( event:MouseEvent ):void
    {
        if( (levelModel.levelCount > levelModel.level ) )
        {
            levelModel.level += 1;
            changeLevel( levelModel.level );
        }
    }

    // 当前关卡bitmap
    private var _curLevelBitmap:Bitmap;

    private function loadLevel( level:int ):void
    {
        var file:File =	P9LevelModel.getLevelImageFile(level);
        var loader:Loader = new Loader();
        loader.load( new URLRequest( file.url ) );
        trace("P9Game/loadLevel()",file.url);
        loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoadLevelComp );
    }

    private function onLoadLevelComp( event:Event ):void
    {
        var loader:Loader = (event.currentTarget as LoaderInfo).loader;
        _curLevelBitmap = loader.content as Bitmap;
        var sx:Number = picRect.width / _curLevelBitmap.width;
        var sy:Number = picRect.height / _curLevelBitmap.height;
        var scale:Number = sx > sy ? sx : sy;
//			trace("Loaded image size",_curLevelBitmap.width,_curLevelBitmap.height);
        _curLevelBitmap.scaleX = _curLevelBitmap.scaleY = scale;
//			trace("image scaleto size",_curLevelBitmap.width,_curLevelBitmap.height);
        // ui
        ui.win.visible = false;
        ui.bottom.nextBtn.visible = false;
        //
        levelModel = P9LevelModel.getInstance();
        // 创建9宫
        bg.removeChildren();
        //
        _curLevelBitmap.alpha = .1;
        bg.addChild(_curLevelBitmap);
        makePuzzle();
        // 创建缩略图参考
        ui.backBtn.visible=false;
        thumb.bitmapData = _curLevelBitmap.bitmapData;
        thumb.scaleX = thumb.scaleY = 1.0;
        thumb.bScaleX = _curLevelBitmap.scaleX;
        thumb.bScaleY = _curLevelBitmap.scaleY;
        thumb.x = _curLevelBitmap.x + bg.x;
        thumb.y = _curLevelBitmap.y + bg.y;
        setTimeout(function():void{
            var toScale :Number = fixSize(thumb,200,160,true,false);
            TweenLite.to(thumb,1.0,{scaleX : toScale ,scaleY : toScale
                , x :ui.bottom.x + THUMB_X,y:ui.bottom.y + THUMB_Y
                ,ease : Sine.easeInOut
            });
            ui.backBtn.visible= true;
            SoundMan.playSfx(SoundMan.GO);
        } , 1000);
        unlock();
        AoaoBridge.banner(YiZhiDaQuan.instance);
    }
    private var thumb:P9MaskeredBitmap;

    public static function fixSize( target : DisplayObject,fitW:Number ,fitH:Number , isMax :Boolean,isSet :Boolean =true):Number
    {
        target.scaleX = target.scaleY = 1.0;
        var sx:Number = fitW / target.width;
        var sy:Number = fitH / target.height;
        var scale:Number = 1.0;
        if(isMax)
            scale = sx > sy ? sx : sy;
        else
            scale = sx < sy ? sx : sy;
        if(isSet)
            target.scaleX = target.scaleY = scale;
        return scale;
    }

    /** 当前的所有碎块 */
    private var shapeParts:Array = [];
    /** 当前空着的pos */
    private var emptySlotPos:int = 0;

    private function makePuzzle():void
    {
        shapeParts = [];
        //为了打乱顺序
        var poses:Array = [];
        for( var i:int = 0; i < 3; i++ )
        {
            for( var j:int = 0; j < 3; j++ )
            {
                if( i == 0 && j == 0 ) continue;
                poses.push( i * 10 + j );
            }
        }
        if(CONFIG::DESKTOP)
        {
            var tmp0: int  = poses[0];
            var tmp2: int  = poses[2];
            poses[0] = poses[3];
            poses[3] = tmp2;
            poses[2] = tmp0;
        }else{
            poses.sort( randomSort );
        }


        var marginX:Number = picRect.width / 3;
        var marginY:Number = picRect.height / 3;
        for( i = 0; i < 3; i++ )
        {
            for( j = 0; j < 3; j++ )
            {
                if( i == 0 && j == 0 ) continue;
                //
                var partRect:Rectangle = new Rectangle( i * marginX, j * marginY, marginX, marginY );
                var shapePart:P9PartShape = new P9PartShape( _curLevelBitmap, partRect, i * 10 + j, poses.shift() );
                shapeParts.push( shapePart );
                shapePart.x = marginX * (int(shapePart.curPos/10));
                shapePart.y = marginY * (shapePart.curPos % 10 );
                shapePart.addEventListener( MouseEvent.MOUSE_DOWN, onShapeDown );
//					shapePart.alpha = .8;
                bg.addChild( shapePart );
            }
        }
        emptySlotPos = 0;
    }

    /** 点击碎块 移动 */
    private function onShapeDown( event:MouseEvent ):void
    {
        var marginX:Number = picRect.width / 3;
        var marginY:Number = picRect.height / 3;
        var part:P9PartShape = event.target as P9PartShape;
        var oldPos:int = part.curPos;
//			trace("P9Game/onShapeDown() part.curPos=",oldPos);
        // 只有与emptySlotPos相邻才可以移动
        var minusRes :int = Math.abs(oldPos - emptySlotPos);
        if( 10 != (minusRes) && 1 != minusRes )  return;
        //
        part.curPos = emptySlotPos;
        emptySlotPos = oldPos;
        var i:int = int( part.curPos / 10 );
        var j:int = part.curPos % 10;
        lock();
        part.moveTo( i * marginX, j * marginY ,onPartMoveComplete);
    }

    private function lock():void
    {
        trace("P9Game/lock()");
        bg.mouseChildren=false;
    }

    private function onPartMoveComplete(part:P9PartShape):void
    {
        // 检查是否过关
        var passed:Boolean = true;
        for( var i:int = 0; i < shapeParts.length; i++ )
        {
            var part:P9PartShape = shapeParts[i];
            if(part.correctPos!=part.curPos)
            {
                passed = false;
                break;
            }
        }
        if(passed)
        {
            /** 玩家拖拽正确啦 */
            trace( "胜利" );
            _curLevelBitmap.alpha=1.0;

            levelModel.saveLevel( levelModel.level, 1 );
            // 根据是否还有下一关 出不出下一关按钮
            playWinEffect(levelModel.levelCount > levelModel.level );
            SoundMan.playSfx( SoundMan.PRIZE );

            AoaoBridge.interstitial(YiZhiDaQuan.instance);
        }else{
            unlock();
        }
    }
    private function playWinEffect( showNextBtn :Boolean ):void
    {
        ui.win.visible = true;
        ui.win.scaleX = ui.win.scaleY = 0.01;

        TweenLite.to(ui.win,1,{scaleX:1,scaleY:1,ease:Back.easeOut});
        if(!showNextBtn) return;
        setTimeout(function():void
        {
            ui.bottom.nextBtn.visible = true;
            var oldY:Number = ui.bottom.nextBtn.y;
            ui.bottom.nextBtn.y +=200;
            TweenLite.to(ui.bottom.nextBtn,.8,{y:oldY,ease:Back.easeOut});
        },1200 );
    }

    private function unlock():void
    {
        bg.mouseChildren=true;
    }

    public function changeLevel( level:int ):void
    {
        loadLevel( level );
    }

    private function onBackClick( event:MouseEvent ):void
    {
        AoaoBridge.interstitial(YiZhiDaQuan.instance);
        YiZhiDaQuan.instance.replaceScene( new P9Level() );
    }

    // shelf 180 ===  SHELFH 445  ===  BOTTOM
    // 上面ui尺寸
    private static const MENUPANEL_TOP:Number = 130;
    // private static const HOLE_SHELF_TOP : Number = 180;
    // 下面ui尺寸 广告以外的
    private static const BOTTOM_HEIGHT:Number = 200;
    // 下方选项占用的高度 广告以外
    private static const SELECTPANEL_HEIGHT:Number = 162.5;
    // private static const HOLE_W : Number = P9HoleLi.HOLE_W;
    // private static const HOLE_H : Number = P9HoleLi.HOLE_H;

    private function randomSort( elementA:Object, elementB:Object ):int
    {
        return int( Math.random() * 3 ) - 1;
    }


    public function dispose():void
    {
    }

    public function flyIn():void
    {
    }
}
}
