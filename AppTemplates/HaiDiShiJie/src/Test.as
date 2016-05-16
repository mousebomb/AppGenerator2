/**
 * Created by rhett on 16/2/20.
 */
package
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	public class Test extends Sprite
	{
		public function Test()
		{
			imgLoader = new Loader();
			imgLoader.load( new URLRequest( "file://Users/rhett/Desktop/srcbizhi.jpg"));
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComp);
		}

		private function onComp( event:Event ):void
		{
			doit();
		}
		private var imgLoader:Loader;

		public function doit():void
		{

			var bmd:BitmapData = (imgLoader.content as Bitmap).bitmapData;
			// 裁剪尺寸比例
			var savRect:Rectangle = bmd.rect.clone();
			if( bmd.width / bmd.height > 9 / 16 )
			{
				//方的 ，取16 裁剪9
				savRect.width = bmd.height / 16 * 9;
				savRect.x = (bmd.width - savRect.width)/2;
			} else
			{
				//长的 取9裁剪16
				savRect.height = bmd.width / 9 * 16;
				savRect.y = (bmd.height- savRect.height)/2;
			}
			trace("Test/doit() 裁剪为",savRect);
			//处理为小尺寸的
			var bmd2:BitmapData;
			if( savRect.width > 640 )
			{
				var scaleToW:int = 640;
				var scaleToH:int = 1136;
				bmd2 = new BitmapData( scaleToW, scaleToH );
				var mtx:Matrix = new Matrix();
				mtx.translate(-savRect.x ,-savRect.y);
				mtx.scale( scaleToW/savRect.width, scaleToH/savRect.height);
				bmd2.draw( bmd, mtx, null, null );
				trace("Test/doit() 缩小",bmd2.rect);
			}
//			var bmp :Bitmap = new Bitmap(bmd);
//			bmp.filters = [new DropShadowFilter()];
//			addChild(bmp);
//			bmp.width = 320;
//			bmp.height = 1136/2;
//			var uniqFilename:String = (new Date()).valueOf().toString( 16 );
			var file:File = File.desktopDirectory.resolvePath("bizhi.jpg");
			var opt:JPEGEncoderOptions = new JPEGEncoderOptions( 80 );
			var fs:FileStream = new FileStream();
			fs.open( file, FileMode.WRITE );
			if(bmd2){
				fs.writeBytes( bmd2.encode( bmd2.rect, opt ) );
			}else{
				fs.writeBytes( bmd.encode( savRect, opt ) );
			}
			fs.close();
		}
	}
}
