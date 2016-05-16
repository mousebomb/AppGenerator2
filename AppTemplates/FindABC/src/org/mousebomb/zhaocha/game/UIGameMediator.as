/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.zhaocha.game {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.mousebomb.SoundMan;
	import org.mousebomb.zhaocha.common.SceneEvent;
	import org.robotlegs.mvcs.Mediator;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

public class UIGameMediator extends Mediator
{

    [Inject]
    public var model:GameDataModel;
    // 图片
	private var pic : Sprite;
	
	// 计时器
	private var timer :Timer = new Timer(1000);


    public function UIGameMediator()
    {
    }


    override public function onRegister():void
    {
        var ui:UIGame = (viewComponent as UIGame);
		
        ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);

        addContextListener(GameEvent.GAME_GOTO_LEVEL, onGotoLevel);
        addContextListener(GameEvent.GAME_WIN, onGameWin);
        addContextListener(GameEvent.GAME_DIFFCOUNT_CHANGE,onDiffChange);
		//
		picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadPicComplete);
		//计时器
		timer.addEventListener(TimerEvent.TIMER, onTimer);
	}

    override public function preRemove():void
    {
        timer.removeEventListener(TimerEvent.TIMER, onTimer);
        super.preRemove();
    }

	private var passedSeconds :int = 0;
	private function onTimer(event : TimerEvent) : void 
	{
        var ui:UIGame = (viewComponent as UIGame);
		passedSeconds++;
		var min :int = passedSeconds/60;
		var sec : int = passedSeconds %60;
		ui.timeTf.text = min+":"+(sec<10?"0"+sec : sec );
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
		timer.stop();
    }

    private function onDiffChange(e:GameEvent):void
    {
//        var ui:UIGame = (viewComponent as UIGame);
//        ui.diffcountTf.text = e.foundCount + "/" + e.differenceCount;
//		trace(e.foundCount,"/",e.differenceCount);
    }

	private var picLoader :Loader = new Loader();

    private function onGotoLevel(e:GameEvent):void
    {
        var l:int = e.level;
        var ui:UIGame = (viewComponent as UIGame);
		if(picLoader.parent) picLoader.parent.removeChild(picLoader);
		if(pic && pic.parent) ui.removeChild(pic);
		
		var picClazz :Class = getDefinitionByName("Pic" + l) as Class;
		pic = new picClazz();
		pic.y = 90;
		ui.addChild(pic); 
		
		//关卡
		ui.levelTf.text = l.toString();
		////倒计时
		timer.reset();
		ui.timeTf.text = "0:00";
			
        // 隐藏所有答案 并监听
        resetResult(pic);
        // 根据视图刷新 model 这关多少个不同
        model.differencesToFind(pic.numChildren /2 );
		
		// load pics  ,add Child to 
		var iStr :String = l.toString();
//			if(l <10){ iStr = "0"+l; }
		var file : File = File.applicationDirectory.resolvePath("pics/"+ iStr + ".png");
		if (!file.exists) file = File.applicationDirectory.resolvePath("pics/"+ iStr + ".jpg");
		if (!file.exists) file = File.applicationDirectory.resolvePath("pics/"+ iStr + ".png");
		if (!file.exists) file = File.applicationDirectory.resolvePath("pics/"+ iStr + ".jpg");
		pic.visible= false;
		try{picLoader.close();
		}catch(e:*){}
		picLoader.load(new URLRequest(file.url));
		pic.addChildAt(picLoader, 0);
    }
	
	private function onLoadPicComplete(event : Event) : void 
	{
		pic.visible=true;
		picLoader.width = 640;
		picLoader.height=670;
		//开始计时
		passedSeconds=0;
		timer.start();
		//
		SoundMan.playSfx(SoundMan.GO);
        //
        if(!CONFIG::DEBUG)
            AoaoBridge.banner(contextView);
	}
	

    private function resetResult(result:Sprite):void
    {
		// 点击层
		var toFind : int = result.numChildren / 2;
        for (var i:int = 0; i < toFind; i++)
        {
            var choice:DisplayObject = result.getChildAt(i) as DisplayObject;
            if (!choice.hasEventListener(MouseEvent.CLICK))
                choice.addEventListener(MouseEvent.CLICK, onChoiceClick);
        }
		// 答案层
		answers = [];
		for(;i<result.numChildren;i++)
		{
			//冻结答案层 绑定点击对象
			var answer:DisplayObject = result.getChildAt(i) as DisplayObject;
			answers.push(answer);
		}
    }
	
	// 纪录要点亮的答案
	private var answers:Array=[];

    private function onChoiceClick(event:MouseEvent):void
    {
        var child:DisplayObject = (event.currentTarget as DisplayObject);
        // 之前是没画圈，现在发现了
		// 点击后 移除监听 并覆盖圈圈；
		child.removeEventListener(MouseEvent.CLICK, onChoiceClick);
		var bounds :Rectangle = child.getBounds(pic);
		var size :Number = bounds.width > bounds.height?bounds.width : bounds.height;
		var circle :CircleBtn = new CircleBtn();
		circle.width = size;
		circle.height = size;
		circle.rotation = child.rotation;
		circle.x = bounds.x + bounds.width/2;
		circle.y  = bounds.y + bounds.height/2;
		pic.addChild(circle);
		// 答案点亮
		var childType :XML = (flash.utils.describeType(child));
		var childTypeName :String = childType.@name;
		trace("点击",childTypeName);
		SoundMan.playAbcSfx(int(childTypeName.substr(1)));
		var toAnswer :DisplayObject;
		for each (var answer : DisplayObject in answers)
		{
			var answerType :XML = flash.utils.describeType(answer);
			var answerTypeName :String = answerType.@name;
			if(answerTypeName == childTypeName)
			{
				toAnswer = answer;
				break;	
			}
			//
		}
		if(toAnswer)
		{
			var ct : ColorTransform = new ColorTransform();
			toAnswer.transform.colorTransform = ct;
			answers.splice(answers.indexOf(answer),1);
		}else if(CONFIG::DEBUG){
			throw new Error("答案层和点击层找不到配对:答案层缺少对应的"+childTypeName);
		}

        // 告知model
        model.foundOne();
    }
}
}
