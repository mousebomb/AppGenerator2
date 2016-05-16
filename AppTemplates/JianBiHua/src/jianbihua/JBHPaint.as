package jianbihua {
	import flash.display.BitmapData;
	import flash.media.CameraRoll;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.utils.getDefinitionByName;

	/**
	 * @author rhett
	 */
	public class JBHPaint extends Sprite {
		private var visibleSizeH : Number;
		private var visibleSizeW : Number;

		public function JBHPaint() {
			_jbh = new JianBiHuaProxy();
		}

		private var _jbh : JianBiHuaProxy ;
		private var bg : DisplayObject;
		private var playerPaintBoard : Sprite = new Sprite();

		public function startPaint(id : int) : void {
			var pictureClassName : String = "Pic" + id;
			var clazz : Class = getDefinitionByName(pictureClassName) as Class;
			bg = new clazz();
			var bgBounds :Rectangle = bg.getBounds(bg);
			var sx :Number = visibleSizeW*.9/bgBounds.width;
			var sy :Number =  visibleSizeH*.9/bgBounds.height ;
			var scale :Number = sx < sy ? sx : sy;
			bg.scaleX = bg.scaleY = scale; 
			if(bg['s'])
			{
				bg['s'].alpha = .3;
			}else
			{
				bg.alpha = 0.3;
			}
			bg.x = (visibleSizeW-bg.width)/2-bgBounds.x * scale;
			bg.y = (visibleSizeH-bg.height)/2 -bgBounds.y * scale;

			addChild(playerPaintBoard);
			addChild(bg);

			_jbh.adapt(playerPaintBoard);
		}

		public function get proxy() : JianBiHuaProxy {
			return _jbh;
		}

		/**
		 * 保存
		 */
		public function save() : void 
		{
			if(CameraRoll.supportsAddBitmapData)
			{
				var croll : CameraRoll = new CameraRoll();
				var bmd :BitmapData = new BitmapData(visibleSizeW, visibleSizeH, false , 0xffffffff);
				bmd .draw(playerPaintBoard);
				croll.addBitmapData(bmd);
			}
		}

		public function setContentSize(visibleSizeW : Number, visibleSizeH : Number) : void {
			this.visibleSizeW = visibleSizeW;
			this.visibleSizeH = visibleSizeH;
		}
	}
}
