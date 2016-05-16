package pintie
{
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.display.Bitmap;

	import com.greensock.TweenLite;

	import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.Math.MousebombMath;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
import flash.utils.setTimeout;

import com.greensock.TweenLite;
import com.greensock.easing.Back;

	/**
	 * @author rhett
	 */
	public class PTGame extends Sprite implements IDispose,IFlyIn
	{
		private var ui : UIGame;
		private var levelModel : LevelModel;
		private var bg : Sprite;
		private var holeShelf : Sprite = new Sprite();
		private var choiceContainer : Sprite = new Sprite();
		private static var SELECTION_X : Array = [0, 180, 360];
		// hole 的 Rect 用来判断是否正确的唯一依据
		private var holesMaskerRect : Array = [];
		//
		// 选项槽位里的当前空位
		private var emptyChoicesIndex : Array = [0, 1, 2];

		public function PTGame()
		{
			//
			ui = new UIGame();
			ui.bottom.y = GameConf.VISIBLE_SIZE_H;
			ui.win.visible = false;
			ui.bottom.nextBtn.visible = false;
			ui.bottom.nextBtn.addEventListener(MouseEvent.CLICK, onNextBtnClick);
            //
            ui.win.addEventListener(MouseEvent.CLICK,onWinClick);
			//
			levelModel = LevelModel.getInstance();
			nextI = levelModel.level * LevelModel.BIRDSCOUNT_INLEVEL;
			//
			makeScene();
			makeAnimalHoles();
			//
			_shine = new Shine();
			addChild(_shine);
			//
			addChild(ui);
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			// 监听拖拽完成 判定
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			makeAnimalDragSources();
			//

			changeLevel(levelModel.level);
		}
        private function onWinClick(e:MouseEvent):void
        {
            ui.win.visible = false;
        }

		private function onNextBtnClick(event : MouseEvent) : void
		{
			if ( (levelModel.levelCount > levelModel.level ) )
			{
				levelModel.level += 1;
				changeLevel(levelModel.level);
			}
		}

		// 当前关卡bitmap
		private var _curLevelBitmap : Bitmap;

		private function loadLevel(level : int) : void
		{
			var file : File = File.applicationDirectory.resolvePath(GameConf.PICSFOLDER + level + ".png");
			if (!file.exists)
			{
				file = File.applicationDirectory.resolvePath(GameConf.PICSFOLDER + level + ".jpg");
			}
			var loader : Loader = new Loader();
			loader.load(new URLRequest(file.url));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadLevelComp);
		}

		private function onLoadLevelComp(event : Event) : void
		{
			var loader : Loader = (event.currentTarget as LoaderInfo).loader;
			_curLevelBitmap = loader.content as Bitmap;
			_curLevelBitmap.y = holeShelf.y;
			_curLevelBitmap.x = holeShelf.x;
			var bitmapH : Number = (GameConf.VISIBLE_SIZE_H_MINUS_AD - BOTTOM_HEIGHT - MENUPANEL_TOP);
			var bitmapW : Number = GameConf.VISIBLE_SIZE_W;
			var sx : Number = bitmapW / _curLevelBitmap.width;
			var sy : Number = bitmapH / _curLevelBitmap.height;
			var scale : Number = sx > sy ? sx : sy;
			_curLevelBitmap.scaleX = _curLevelBitmap.scaleY = scale;
			//
			_shine.visible = false;
			_shine.stop();
			// ui
			ui.win.visible = false;
			ui.bottom.nextBtn.visible = false;
			//
			levelModel = LevelModel.getInstance();
			nextI = levelModel.level * LevelModel.NEWBIRDSCOUNT_INLEVEL;

			bg.removeChildren();
			bg.addChild(_curLevelBitmap);

			// 创建缺损的内容，随机
			// shelf holes
			holesMaskerRect = [];
			if (levelModel.level <= 2)
			{
				makePuzzle(2, 2, bitmapW, bitmapH);
			}
			else if (levelModel.level <= 4)
			{
				makePuzzle(3, 2, bitmapW, bitmapH);
			}
			else if (levelModel.level <= 8)
			{
				makePuzzle(3, 3, bitmapW, bitmapH);
			}
			else
			{
				makePuzzle(4, 3, bitmapW, bitmapH);
			}
			

			targetsLeft = holeShelf.numChildren;
			holesMaskerRect.sort(randomSort);
			// 创建 choices
			for (var i : int = 0; i < 3; i++)
			{
				animalSelectionFlyIn();
			}
			AoaoBridge.banner(this);
		}

		private function makePuzzle(cols : int, rows : int, w : Number, h : Number) : void
		{
			// cols , rows 分布在w x h区域内
			var xSlice : Number = w / cols;
			var ySlice : Number = h / rows;
			var minOfSlice : Number = xSlice < ySlice ? xSlice : ySlice;
			for (var i : int = 0; i < cols; i++)
			{
				for (var j : int = 0; j < rows; j++)
				{
					var size : Number ;
					if(cols <3 ) size=MousebombMath.randomFromRange(minOfSlice * 0.5, minOfSlice*.7 );
					else if(cols <4 ) size=MousebombMath.randomFromRange(minOfSlice * 0.7, minOfSlice*.85 );
					else size=MousebombMath.randomFromRange(minOfSlice * 0.7, minOfSlice );
					
					var positionOffsetX:Number =  MousebombMath.randomFromRange(0, xSlice - size);
					var positionOffsetY:Number =  MousebombMath.randomFromRange(0, ySlice - size);
//					var biggerOffset:Number = positionOffsetY>positionOffsetX ? positionOffsetY: positionOffsetX;
					var maskerRect : Rectangle = new Rectangle
					(
					  xSlice * i + positionOffsetX
					, ySlice * j + positionOffsetY
					, size
					, size);
					var li : HoleLi ;
					if(levelModel.level<=13)
					{
						li = newHoleLiFromPicI(maskerRect, HoleLi.DRAG_TARGET, levelModel.level);
					}else{
						li = newHoleLiFromPicI(maskerRect, HoleLi.DRAG_TARGET, nextI++);
					}
					li.x = maskerRect.x + maskerRect.width/2;
					li.y = maskerRect.y + maskerRect.height / 2;
					holeShelf.addChild(li);
				}
			}
		}

		public function changeLevel(level : int) : void
		{
			loadLevel(level);
		}

		// 判定是否拖拽到合适地点
		private function onMouseUp(event : MouseEvent) : void
		{
			var dragHoleLi : HoleLi = event.target as HoleLi;
			if (dragHoleLi == null ) return ;
			if (dragHoleLi.type == HoleLi.DRAG_TARGET) return ;
			var numShelfChildren : int = holeShelf.numChildren;
			for (var i : int = 0; i < numShelfChildren; i++)
			{
				var shelfLi : HoleLi = holeShelf.getChildAt(i) as HoleLi;
				if (dragHoleLi.rect == shelfLi.rect)
				{
					var shelfLiPos : Point = shelfLi.localToGlobal(new Point());
					var dragLiPos : Point = dragHoleLi.localToGlobal(new Point());
					var dist : Number = MousebombMath.distanceOf2Point(shelfLiPos, dragLiPos);
					if (dist < 80)
					{
						userCorrect(dragHoleLi, shelfLi);
					}
				}
			}
		}

		private var _shine : MovieClip;

		/**
		 * 玩家拖拽正确啦
		 */
		private function userCorrect(dragHoleLi : HoleLi, shelfHoleLi : HoleLi) : void
		{
			dragHoleLi.playCorrect();
			shelfHoleLi.playCorrect();
			// shanshan
			_shine.x = holeShelf.x + shelfHoleLi.x + shelfHoleLi.bitmapOriginW / 2;
			_shine.y = holeShelf.y + shelfHoleLi.y + shelfHoleLi.bitmapOriginH / 2;
			_shine.play();
			_shine.visible = true;
			// 空位记录
			emptyChoicesIndex.push(dragHoleLi.choiceIndex);
			// 得分增加
			if (--targetsLeft < 1)
			{
				//
				trace("胜利");
				levelModel.saveLevel(levelModel.level, 1);
				// 根据是否还有下一关 出不出下一关按钮
                playWinEffect(levelModel.levelCount > levelModel.level);
				SoundMan.playSfx(SoundMan.PRIZE);
				AoaoBridge.interstitial(this);
			}
			else
			{
				SoundMan.playSfx(SoundMan.RIGHT);
				// 没胜利 ，继续出
				animalSelectionFlyIn();
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

		private function makeAnimalDragSources() : void
		{
			choiceContainer.y = GameConf.VISIBLE_SIZE_H_MINUS_AD - SELECTPANEL_HEIGHT + HoleLi.HOLE_H_SMALL /2;
			addChild(choiceContainer);
		}

		// 飞入一个选项补上
		private function animalSelectionFlyIn() : void
		{
			// 获取一个要的
			// 随机的洞（target）里的index （pic的取值范围 1～24）
			if (holesMaskerRect.length < 1) return;
			var pickHoleVO : HoleVO = holesMaskerRect.pop();
			var pickMaskerRect : Rectangle = pickHoleVO.rect;

			// 第几个选项 0～3
			var pickChoiceIndex : int = emptyChoicesIndex.shift();
			var li : HoleLi = newHoleLiFromPicI(pickMaskerRect, HoleLi.DRAG_SOURCE, pickHoleVO.shapeId);
			li.choiceIndex = pickChoiceIndex;
			li.x = SELECTION_X[pickChoiceIndex];
			li.alpha = 0;
			TweenLite.to(li, 0.6, {alpha:1});
			choiceContainer.addChild(li);
		}

		/**
		 * 创建／装饰 HoleLi  i是 传入li的vo ，也就是1,2,3,4其中一个，在changeLevel中会传入
		 * type 决定是被拖拽的source  还是 被防止的target
		 */
		private function newHoleLiFromPicI(maskerRect : Rectangle, type : String, shapeId : uint) : HoleLi
		{
			var holeVO : HoleVO = new HoleVO();
			holeVO.rect = maskerRect;
			holeVO.shapeId = shapeId;
			var li : HoleLi = new HoleLi();
			
			if (type == HoleLi.DRAG_TARGET)
			{
				holesMaskerRect.push(holeVO);
			}
			li.setContent(_curLevelBitmap, maskerRect, shapeId,type);
			return li;
		}

		private function onBackClick(event : MouseEvent) : void
		{
			AoaoBridge.interstitial(this);
			PinTie.instance.replaceScene(new TZLevel());
		}

		private static var nextI : int = 1;
		// shelf 180 ===  SHELFH 445  ===  BOTTOM
		// 上面ui尺寸
		private static const MENUPANEL_TOP : Number = 130;
		// private static const HOLE_SHELF_TOP : Number = 180;
		// 下面ui尺寸 广告以外的
		private static const BOTTOM_HEIGHT : Number = 200;
		// 下方选项占用的高度 广告以外
		private static const SELECTPANEL_HEIGHT : Number = 162.5;
		// private static const HOLE_W : Number = HoleLi.HOLE_W;
		// private static const HOLE_H : Number = HoleLi.HOLE_H;
		// 本关还剩余目标数
		private var  targetsLeft : int = 4;

		// init 的一部分，只执行一次
		private function makeAnimalHoles() : void
		{
			//
			addChild(holeShelf);

			holeShelf.x = (GameConf.DESIGN_SIZE_W - GameConf.VISIBLE_SIZE_W) * .5;
			holeShelf.y = MENUPANEL_TOP;

			// SELECTION_X 计算 跟这里统一
			for (var i : int = 0; i < 3; i++)
			{
				SELECTION_X[i] = HoleLi.HOLE_W_SMALL*3/4 +  GameConf.DESIGN_SIZE_W / 3 * i ;
			}
			//
		}

		private function randomSort(elementA : Object, elementB : Object) : int
		{
			return int(Math.random() * 3) - 1;
		}

		private function makeScene() : void
		{
			bg = new Sprite();
			addChildAt(bg, 0);
			//
		}

		public function dispose() : void
		{
		}

		public function flyIn() : void
		{
		}
	}
}
