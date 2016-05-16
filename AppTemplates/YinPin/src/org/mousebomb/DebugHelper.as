/**
 * Created by bombgao on 2015/4/27.
 */
package org.mousebomb
{

	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Rectangle;
	import flash.html.script.Package;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	public class DebugHelper
	{
		private var _stage:Stage;

		public function DebugHelper( stage:Stage )
		{
			_stage = stage;
			genCodeArea();
			_stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		}

		private var _cornerPoints:Vector.<Point>;

		private function onMouseDown( event:MouseEvent ):void
		{
			var newPoint:Point = new Point( event.stageX, event.stageY );
			if( _cornerPoints == null )
			{
				_cornerPoints = new <Point>[];
			}
			_cornerPoints.push( newPoint );
			//验证最近输入是否正确
			if( isPointInvalid( newPoint, _cornerPoints.length - 1 ) )
			{
				_cornerPoints = null;
				// 失败
				return;
			}
			if( _cornerPoints.length == CODE.length )
			{
				_cornerPoints = null;
				// 触发
				initTraceTf();
			}
		}

		private static const CODE:String = "18665899347";
		//18665899347
		private function isPointInvalid( point:Point, i:int ):Boolean
		{
			var rect:Rectangle = _codeArea[CODE.charAt( i )];
			var contains:Boolean = rect.containsPoint( point );
			return !contains;
		}

		private var _codeArea:Dictionary = new Dictionary();

		private function genCodeArea():void
		{
			var winW:Number = _stage.fullScreenWidth;
			var winH:Number = _stage.fullScreenHeight;
			// 把舞台分割成多块
			var marginW:Number = winW / 3;
			var marginH:Number = winH / 3;

			for( var i:int = 0; i < 3; i++ )
			{
				for( var j:int = 0; j < 3; j++ )
				{
					var codeBit:int = j * 3 + i + 1;
					var rect:flash.geom.Rectangle = new flash.geom.Rectangle( i * marginW, (2 - j) * marginH, marginW, marginH );
					_codeArea[codeBit.toString()] = rect;
				}
			}
		}

		/* ------------------- # 输出调试文本框 # ---------------- */
		private function initTraceTf():void
		{
			if( _traceTf == null )
			{
				_traceTf = new TextField();
                _traceTf.backgroundColor = 0xffffff;
                _traceTf.background=true;
                _traceTf.multiline=true;
                _traceTf.width = _stage.fullScreenWidth;
				_traceTf.height = _stage.fullScreenHeight;
                _traceTf.mouseEnabled=false;
				var tfm:TextFormat = new TextFormat( null, 16, 0x000000 );
				_traceTf.defaultTextFormat = tfm;
				_traceTf.text = _cachedText;
				_stage.addChild( _traceTf );
			}
		}

		private static var _traceTf:TextField;

		private static var _cachedText :String  = "";

		public static function log( str :String ):void
		{
			if( _traceTf!=null )
			{
				_traceTf.appendText(str +"\n");
				_traceTf.scrollV = _traceTf.maxScrollV;
			}else{
				_cachedText += str + "\n";
			}
		}
	}
}
