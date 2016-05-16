package pintie
{
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.display.Bitmap;
	import flash.display.Sprite;

	/**
	 * @author rhett
	 */
	public class PartShape extends Sprite
	{
		${Masks}
		
		private var _bitmap : Bitmap ;
		private var _masker : Sprite;
		// 蒙板的外侧描边
		private var _maskerOutline : Sprite;
		private var _maskerClazz : Class;

		public function PartShape(bitmap : Bitmap, rect : Rectangle , shapeId:uint )
		{
			// graphics.beginFill(0xff0000);
			// graphics.drawCircle(0, 0, 20);
			// graphics.endFill();
			_bitmap = new Bitmap(bitmap.bitmapData);
			_bitmap.scaleX = bitmap.scaleX;
			_bitmap.scaleY = bitmap.scaleY;
			_maskerClazz = getDefinitionByName("Mask" + (shapeId % ${MaskNum} + 1)) as Class;
			_masker = new _maskerClazz();
			// var sX:Number  = rect.width / masker.width;
			// var sY:Number = rect.height / masker.height;
			setMaskerRect(rect);
			addChild(_masker);
			_bitmap.mask = _masker;
		}

		private static var shadow : DropShadowFilter = new DropShadowFilter();

		public function initOutline() : void
		{
			//
			_maskerOutline = new _maskerClazz();
			_maskerOutline.scaleX = _masker.scaleX;
			_maskerOutline.scaleY = _masker.scaleY ;
			addChildAt(_maskerOutline, 0);
			_maskerOutline.filters = [shadow];
		}

		public function setMaskerRect(rect : Rectangle) : void
		{
			_bitmap.x = -rect.x - rect.width / 2;
			_bitmap.y = -rect.y - rect.height / 2;
			_masker.width = rect.width;
			_masker.height = rect.height;
		}

		public function black() : void
		{
			// 显示黑纹
			if (_bitmap.parent) _bitmap.parent.removeChild(_bitmap);
			_bitmap.mask = null;
		}

		public function show() : void
		{
			addChild(_bitmap);
			_bitmap.mask = _masker;
			if (_maskerOutline == null) initOutline();
		}
	}
}
