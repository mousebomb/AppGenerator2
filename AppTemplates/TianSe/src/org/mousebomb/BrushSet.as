package org.mousebomb
{
	import org.mousebomb.ui.Shelf;

	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	/**
	 * @author Mousebomb
	 */
	public class BrushSet extends Sprite
	{
		public var colors : Array = [0xFFFFFF,0xFF9999,0x79E3E1,0x9AC43A,
0xFFCC00,0xFF99CC,0x0AB6E9,0x6CA233,
0xFF9900,0xFF6699,0x0075BB,0x356732,
0xFF6600,0xFF3333,0x3C36BC,0x027639,
0xAF713E,0x990000,0x220F43,0x71BF45,
0x884D2F,0x660000,0x262627,0xC4C0CD,
0x63351D,0x330066,0x660099,0x9A3CF2];
		private var _shelf : Shelf;

		public function BrushSet()
		{
			
			_shelf = new Shelf();
			var colorBtnSize : Number = 70.0;
			var cols : int = 4;//Math.floor(screen.width / colorBtnSize);
			var rows : int = Math.ceil(colors.length / cols);
//			// 绘制一个底
//			graphics.beginFill(0xdddddd, 1.0);
//			// 100像素是广告
//			graphics.drawRect(0, 0, screen.width, rows * colorBtnSize + 100);
//			graphics.endFill();
			_shelf.config(colorBtnSize, colorBtnSize+5.0, colors.length, cols, ColorSample, onAddLi);
			_shelf.x = colorBtnSize / 2;
			_shelf.y = colorBtnSize / 2;
			addChild(_shelf);
			_shelf.setList(colors);
			//
			this.x = GameConf.VISIBLE_SIZE_W - cols * colorBtnSize;
			this.y = GameConf.AD_H;//GameConf.VISIBLE_SIZE_H
		}

		private var selectedBrush : ColorSample;

		private function onAddLi(li : ColorSample, vo : uint) : void
		{
			li.vo = vo;
			var ct : ColorTransform = new ColorTransform();
			ct.color = vo;
			li['c'].transform.colorTransform = ct;
			li.addEventListener(MouseEvent.CLICK, onClickLi);
			li.stop();
		}

		private function onClickLi(event : MouseEvent) : void
		{
			if (selectedBrush)
			{
				selectedBrush.gotoAndStop(1);
			}

			var li : ColorSample = event.currentTarget as ColorSample;
			li.gotoAndStop(2);
			var color : uint=			li.vo;
			var cIndex :int = colors.indexOf(color);
            Sfx.color.gotoAndStop(1);
            Sfx.color.gotoAndStop(cIndex+10);
//			var ct : ColorTransform = new ColorTransform();
//			ct.color = li.vo;
//			li.getChildByName("c2").transform.colorTransform = ct;
			// li.scaleX=li.scaleY=1.5;
			selectedBrush = li;
			Painting.lastInstance.brushColor = color;
		}
	}
}
