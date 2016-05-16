/**
 * Created by rhett on 16/2/20.
 */
package hdsj
{

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLRequest;

	import hdsj.BiZhiModel;

	import org.mousebomb.GameConf;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import ui.Bg1;

	public class YuChangBG extends Sprite
	{

		private static var _instance:YuChangBG;

		public static function getInstance():YuChangBG
		{
			if( _instance == null )
				_instance = new YuChangBG();
			return _instance;
		}

		public function YuChangBG()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
			//
			this.mouseEnabled = false;
			this.mouseChildren = false;
			var bzModel :BiZhiModel=BiZhiModel.getInstance();

			GlobalFacade.regListener( NotifyConst.BG_CHANGED, onNBgChanged );
			if(bzModel.curBg is Class)
			{
				this.setBg( bzModel.curBg );
			}else{
				this.setBg(bzModel.calcImgFile(bzModel.curBg).url);
			}
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}

		private function onStage( event:Event ):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onStage);
			// 偏移rootView的起始坐标
			var offset :Point = globalToLocal(new Point(0,0));
			this.x = offset.x;
		}

		private function onNBgChanged( n:Notify ):void
		{
			setBg( n.data );
		}


		private var normalBg:Bitmap;
		private var customBg:Loader;

		public function setBg( urlOrClass:* ):void
		{
			if( urlOrClass is Class )
			{
				if( !normalBg )
				{
					normalBg = new Bitmap( new urlOrClass());
					validateBgSize(normalBg);
				}else{
					normalBg.bitmapData = new urlOrClass();
				}
				removeChildren();
				addChild( normalBg );
			} else
			{
				if( !customBg )
				{
					customBg = new Loader();
					customBg.contentLoaderInfo.addEventListener(Event.COMPLETE, onComp)
				}
				customBg.unloadAndStop();
				customBg.load( new URLRequest( urlOrClass ) );
				removeChildren();
				addChild( customBg );
			}
		}

		private function onComp( event:Event ):void
		{
			validateBgSize(customBg);
		}
		private function validateBgSize( bmp:DisplayObject):void
		{
			var sx:Number = GameConf.VISIBLE_SIZE_W / bmp.width;
			var sy:Number = GameConf.VISIBLE_SIZE_H / bmp.height;
			var s:Number = sx > sy ? sx : sy;
			bmp.scaleX = bmp.scaleY = s;
			bmp.x = (GameConf.VISIBLE_SIZE_W-bmp.width)/2;
			bmp.y = (GameConf.VISIBLE_SIZE_H-bmp.height)/2;
		}
	}
}
