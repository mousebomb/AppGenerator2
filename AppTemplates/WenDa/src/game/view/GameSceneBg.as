package game.view
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;

	import org.mousebomb.GameConf;

	import flash.display.Bitmap;
	import flash.display.Sprite;

	/**
	 * @author Mousebomb
	 */
	public class GameSceneBg extends Sprite
	{
		private const MARGIN : Number = 90.0;
		// 一个循环完整的宽度
		private var loopW : Number;

		public function GameSceneBg()
		{
			bgInit();
		}

        //两种模式
        //y轴底部对齐 如地理问答 建筑物背景
        private static const GROUND:uint = 0;
        //y轴随机分布
        private static const SKY:uint = 1;

        public var yMode :uint = ${bgMode};

		private function bgInit() : void
		{
            //这里做成可配置
            ${addTree}
//			addTree(Tree1);
//			addTree(Tree2);
//			addTree(Tree3);
//			addTree(Tree4);
//			addTree(Tree5);
//			addTree(Tree6);
//			addTree(Tree7);
		}

		private var lastX : Number = 0.0;
		// 所有tree的0点时候x坐标
		private var resetXs : Dictionary = new Dictionary();

		private function addTree(clazz : Class) : void
		{
			var t:* = new clazz();
			var child : DisplayObject ;
			if(t is BitmapData)
			{
				child = new Bitmap(new clazz());
			}else{
				child = t;
			}
            if(yMode == SKY)
            {
                //随机分布的对象 做成元件 中心点在中心
			    child.y = (GameConf.VISIBLE_SIZE_H -200) * Math.random() + 100;
            }else{
                //底部对齐的对象，做成位图或元件 原点在顶部
                child.y = GameConf.VISIBLE_SIZE_H - child.height;
            }
			child.x = lastX;
			lastX = child.x + child.width + MARGIN;
			resetXs[child] = child.x;
			loopW = lastX;
			addChild(child);
		}

		public function move(deltaPlayerX : Number) : void
		{
			for (var i : int = numChildren - 1; i >= 0; --i)
			{
				var child : DisplayObject = getChildAt(i);
				var destX : Number = child.x - deltaPlayerX;
				while (destX < -child.width)
				{
					destX += loopW;
                    if(yMode == SKY)
                        child.y = (GameConf.VISIBLE_SIZE_H -200) * Math.random() + 100;
				}
				child.x = destX;
			}
		}

		public function reset() : void
		{
			for (var i : int = numChildren - 1; i >= 0; --i)
			{
				var child : DisplayObject = getChildAt(i);
				var destX : Number = resetXs[child] ;
				child.x = destX;
			}
		}
	}
}
