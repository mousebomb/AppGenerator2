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
		public var colors : Array = [
            0xBB1100,0xF61900,0xF650AB,0xF9ABCE,
            0xFFFFFF,0xD5D5D5,0x736057,0x010101,
            0xFEEFC8,0xFEE600,0xFF6600,0xF0A300,
            0xCF6C00,0x793400,0xBB6AF1,0xad27f8,
            0xdfc00,0x55A92D,0x356732,0x7CDEB9,
            0x7CD1FF,0x498AFD,0x2E4ED6,0x3c36bc];

		private var _shelf : Shelf;

		public function BrushSet()
		{
			
			_shelf = new Shelf();
			var colorBtnSize : Number = 71.0;
			var cols : int = 8;//Math.floor(screen.width / colorBtnSize);
			var rows : int = Math.ceil(colors.length / cols);
//			// 绘制一个底
//			graphics.beginFill(0xdddddd, 1.0);
//			// 100像素是广告
//			graphics.drawRect(0, 0, screen.width, rows * colorBtnSize + 100);
//			graphics.endFill();
			_shelf.config(colorBtnSize, colorBtnSize, colors.length, cols, ColorSample, onAddLi);
			_shelf.x = colorBtnSize / 2;
			_shelf.y = colorBtnSize / 2;
			addChild(_shelf);
			_shelf.setList(colors);
			//
			this.x = (GameConf.VISIBLE_SIZE_W - cols * colorBtnSize) /2 ;
			this.y = GameConf.VISIBLE_SIZE_H - rows* _shelf.marginY;//GameConf.VISIBLE_SIZE_H
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
