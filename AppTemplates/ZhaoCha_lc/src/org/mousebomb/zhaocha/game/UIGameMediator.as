/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.zhaocha.game {
	import gs.TweenLite;

	import org.mousebomb.SoundMan;
	import org.mousebomb.GameConf;
	import org.mousebomb.zhaocha.common.SceneEvent;
	import org.robotlegs.mvcs.Mediator;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;

public class UIGameMediator extends Mediator
{

    [Inject]
    public var model:GameDataModel;
    // 图片
    private var picA:Loader;
    private var picB:Loader;
//    点选的答案
    private var resultA:Result;
    private var resultB:Result;


    public function UIGameMediator()
    {
    }


    override public function onRegister():void
    {
        var ui:UIGame = (viewComponent as UIGame);
		
		// 不同分辨率
		ui.maskB.y += (GameConf.VISIBLE_SIZE_H - 960) /2;

		picA = new Loader();
		picB = new Loader();
        picA.mask = ui.maskA;
        picA.x = ui.maskA.x;
        picA.y = ui.maskA.y;
        picB.mask = ui.maskB;
        picB.x = ui.maskB.x;
        picB.y = ui.maskB.y;
		ui.addChild(picA);
		ui.addChild(picB);

        resultA = new Result();
        resultA.x = ui.maskA.x;
        resultA.y = ui.maskA.y;
//        ui.addChild(resultA);
        resultB = new Result();
        resultB.x = ui.maskB.x;
        resultB.y = ui.maskB.y;
        ui.addChild(resultB);

        ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);

        addContextListener(GameEvent.GAME_GOTO_LEVEL, onGotoLevel);
        addContextListener(GameEvent.GAME_WIN, onGameWin);
        addContextListener(GameEvent.GAME_DIFFCOUNT_CHANGE,onDiffChange);
		//
	}
	
		override public function onRemove() : void 
		{
			try{
				picA.close();
				picB.close();
			}catch(e:*){}
		}
	
//	//创建Pic 以前的PicA, PicB分到多个类
//	private function instPic(i:int ,masker :Sprite,aOrB:String ):DisplayObject
//	{
//        var ui:UIGame = (viewComponent as UIGame);
//		var clazz :Class = getDefinitionByName(aOrB + i) as Class;
//		var inst : * = new clazz();
//		var pic : DisplayObject;
//		if(inst is BitmapData)
//		{
//			pic = new Bitmap(inst); 
//		}else{
//			pic = inst;
//		}
//        pic.mask = masker;
//        pic.x = masker.x;
//        pic.y = masker.y;
//        ui.addChildAt(pic,picABFromIndex);
//		return pic;
//	}
		
		// 需要加载的
		private var needLoad : int = 2;
		
	    private function onGotoLevel(e:GameEvent):void
	    {
	        var l:int = e.level;
	        var ui:UIGame = (viewComponent as UIGame);
			// 异步加载开始 创建Pic 以前的PicA, PicB分到多外部图
			ui.loading.visible = true;
			needLoad = 2;
			//加载图片
			loadPic(l, "A",picA);
			loadPic(l, "B",picB);
			// 答案设置到关卡
	        resultA.gotoAndStop(l);
	        resultB.gotoAndStop(l);
			resultA.visible=resultB.visible=false;
		        // 隐藏所有答案 并监听
		        resetResult(resultA);
		        resetResult(resultB);
		        // 根据视图刷新 model 这关多少个不同
		        model.differencesToFind(resultA.numChildren);
	    }
	
		/**
		 * 加载图
		 */
		private function loadPic( i : int , aOrB :String,loader :Loader):void
		{
			var iStr :String = i.toString();
			if(i <10){ iStr = "0"+i; }
			var file : File = File.applicationDirectory.resolvePath("pics/"+aOrB+ iStr + ".png");
			if (!file.exists) file = File.applicationDirectory.resolvePath("pics/"+aOrB+ iStr + ".jpg");
			if (!file.exists) file = File.applicationDirectory.resolvePath("pics/"+aOrB.toLowerCase()+ iStr + ".png");
			if (!file.exists) file = File.applicationDirectory.resolvePath("pics/"+aOrB.toLowerCase()+ iStr + ".jpg");
			loader.visible= false;
			loader.load(new URLRequest(file.url));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadPicComp);
		}

		private function onLoadPicComp(event : Event) : void
		{
			if(--needLoad ==0)
			{
				// 2副图 加载完成
	        	var ui:UIGame = (viewComponent as UIGame);
				// 允许点击
				
				//
				resultA.visible=resultB.visible=true;
				ui.loading.visible = false;
				// 划入
				picA.visible = picB.visible = true;
					var oldXA : Number = picA.x;
					picA.x += picA.width;
					TweenLite.to(picA, 0.5, {x:oldXA});
					var oldXB : Number = picB.x;
					picB.x -= picB.width;
					TweenLite.to(picB, 0.5, {x:oldXB});
				//
				SoundMan.playSfx(SoundMan.GO);
                //
				AoaoBridge.banner(contextView);
			}
		}

    private function onBackClick(event:MouseEvent):void
    {
        SoundMan.playSfx(SoundMan.BTN);
        dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIWelcome));
    }

// 过关
    private function onGameWin(e:GameEvent):void
    {
		// 锁定操作
    }

    private function onDiffChange(e:GameEvent):void
    {
        var ui:UIGame = (viewComponent as UIGame);
        ui.diffcountTf.text = e.foundCount + "/" + e.differenceCount;
//trace(e.foundCount,"/",e.differenceCount);
    }


    private function resetResult(result:Result):void
    {
        for (var i:int = 0; i < result.numChildren; i++)
        {
            var choice:MovieClip = result.getChildAt(i) as MovieClip;
            choice.gotoAndStop(2);
            if (!choice.hasEventListener(MouseEvent.CLICK))
                choice.addEventListener(MouseEvent.CLICK, onChoiceClick);
        }
    }

    private function onChoiceClick(event:MouseEvent):void
    {
        var child:MovieClip = (event.currentTarget as MovieClip);
        if (child.currentFrame == 1)
        {
            // 无效点击
            return;
        }
        // 之前是没画圈，现在发现了

        var childIndex:int = child.parent.getChildIndex(child);
        var thisResult:Result = child.parent as Result;

        var theOtherResult:Result = resultA;
        if (thisResult == resultA) theOtherResult = resultB;

        (theOtherResult.getChildAt(childIndex) as MovieClip).gotoAndStop(1);
        child.gotoAndStop(1);

		SoundMan.playSfx(SoundMan.RIGHT);

        // 告知model
        model.foundOne();
    }
}
}
