/**
 * Created by rhett on 16/2/17.
 */
package hdsj.ui
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MediaEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.CameraRoll;
	import flash.net.URLRequest;

	import hdsj.BiZhiModel;

	import org.mousebomb.GameConf;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import ui.Bg1;

	import ui.Bg2;
	import ui.BiZhi;
	import ui.BiZhiLi;

	public class UIBiZhi extends Sprite implements IDispose
	{
		private var _ui:BiZhi;
		private var shelf:Shelf;

		public function UIBiZhi()
		{
			super();
			_ui = new BiZhi();
			shelf = new Shelf();
			var pageCount:int = (GameConf.VISIBLE_SIZE_H_MINUS_AD - 100 - 100) / 120 * 4;
			shelf.config( 153.3 - 20, 230 - 110, pageCount, 4, BiZhiLi, liVoGlue );
			shelf.y = 100;
			shelf.x = 20;
			_ui.addChild( shelf );
			addChild( _ui );
			_ui.prevBtn.y = _ui.nextBtn.y = GameConf.VISIBLE_SIZE_H_MINUS_AD - 50;
			_ui.closeBtn.addEventListener( MouseEvent.CLICK, onCloseClick );
			_ui.prevBtn.addEventListener( MouseEvent.CLICK, onPreClick );
			_ui.nextBtn.addEventListener( MouseEvent.CLICK, onNextClick );
			//
			validateShelf();
			//

			if( CameraRoll.supportsBrowseForImage )
			{
				_ui.tianjiaBtn.addEventListener( MouseEvent.CLICK, onTianJiaClick );
				_ui.trashBtn.addEventListener( MouseEvent.CLICK, onTrashClick );
				cr = new CameraRoll();
				cr.addEventListener( MediaEvent.SELECT, onImgSelected );
			} else
			{
				_ui.tianjiaBtn.visible = false;
				_ui.trashBtn.visible = false;
			}
		}

		private var isTrashMode:Boolean = false;

		private function onTrashClick( event:MouseEvent ):void
		{
			isTrashMode = !isTrashMode;
			var i:int;
			var li:BiZhiLi;
			if( isTrashMode )
			{
				for( i = shelf.numChildren - 1; i >= 5; i-- )
				{
					li = shelf.getChildAt( i ) as BiZhiLi;
					li.gotoAndStop( 3 );

				}
			} else
			{
				for( i = shelf.numChildren - 1; i >= 0; i-- )
				{
					li = shelf.getChildAt( i ) as BiZhiLi;
					if( li.vo == BiZhiModel.getInstance().curBg )
						li.gotoAndStop( 1 ); else
						li.gotoAndStop( 2 );
				}
			}
		}


		private var imgLoader:Loader;

		private function onImgSelected( event:MediaEvent ):void
		{
			imgLoader = new Loader();
			imgLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onImgLoadComplete );
			imgLoader.loadFilePromise( event.data );
		}

		private function onImgLoadComplete( event:Event ):void
		{
			imgLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onImgLoadComplete );
			//保存到app存储目录
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
			var uniqFilename:String = (new Date()).valueOf().toString( 16 );
			var file:File = BiZhiModel.getInstance().calcImgFile( uniqFilename );
			var opt:JPEGEncoderOptions = new JPEGEncoderOptions( 80 );
			var fs:FileStream = new FileStream();
			fs.open( file, FileMode.WRITE );
			if(bmd2){
				fs.writeBytes( bmd2.encode( bmd2.rect, opt ) );
			}else{
				fs.writeBytes( bmd.encode( savRect, opt ) );
			}
			fs.close();
			BiZhiModel.getInstance().addExImg( uniqFilename );
			validateShelf();
		}


		private function validateShelf():void
		{
			shelf.setList( BiZhiModel.getInstance().mergeImgList );
			_ui.nextBtn.visible=_ui.prevBtn.visible = (shelf.totalPage>1);
		}

		private var cr:CameraRoll;

		private function onTianJiaClick( event:MouseEvent ):void
		{
			cr.browseForImage();
		}

		private function onCloseClick( event:MouseEvent ):void
		{
			GlobalFacade.sendNotify( NotifyConst.CLOSE_POPUP_UI, this );
		}

		public function dispose():void
		{
			if( imgLoader )imgLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onImgLoadComplete );
			if( cr )cr.removeEventListener( MediaEvent.SELECT, onImgSelected );

		}


		private function onPreClick( event:MouseEvent ):void
		{
			shelf.prevPage();
		}

		private function onNextClick( event:MouseEvent ):void
		{
			shelf.nextPage();
		}


		private function liVoGlue( li:BiZhiLi, vo:* ):void
		{
			li.vo = vo;
			if( vo is String )
			{
				if(isTrashMode)
				{
					li.gotoAndStop(3);
				}else{
					if( li.vo == BiZhiModel.getInstance().curBg )
						li.gotoAndStop( 1 ); else
						li.gotoAndStop( 2 );
				}
				var file:File = BiZhiModel.getInstance().calcImgFile( vo );
				var loader:Loader = new Loader();
				loader.load( new URLRequest( file.url ) );
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaderComplete );
				loader.x = 5;
				loader.y = 5;
				li.addChildAt( loader, 1 );
			} else if(vo is Class)
			{
				var bg:Bitmap = new Bitmap(new vo());
				bg.x = 5;
				bg.y = 5;
				bg.width = 90;
				bg.height = 90;
				li.addChildAt( bg, 1 );
				if( vo == BiZhiModel.getInstance().curBg )
					li.gotoAndStop( 1 ); else
					li.gotoAndStop( 2 );
			}
			li.addEventListener( MouseEvent.CLICK, onLiClick );
		}

		private function onLoaderComplete( event:Event ):void
		{
			var l:Loader = (event.currentTarget as LoaderInfo).loader;
			l.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoaderComplete );
			l.width = 90;
			l.height = 90;
		}

		private function onLiClick( event:MouseEvent ):void
		{
			var li:BiZhiLi = event.currentTarget as BiZhiLi;
			var bzModel:BiZhiModel = BiZhiModel.getInstance();
			if( isTrashMode )
			{
				if(li.vo)
				{
					bzModel.delExImg( li.vo );
					validateShelf();
				}
			} else
			{
				bzModel.curBg=li.vo;
//				if( li.vo )
//				{
//					var file:File = bzModel.calcImgFile( li.vo );
//					GlobalFacade.sendNotify( NotifyConst.BG_CHANGED, this, file.url );
//				} else
//				{
//					GlobalFacade.sendNotify( NotifyConst.BG_CHANGED, this );
//				}
				li.gotoAndStop( 1 );
				for( var i:int = shelf.numChildren - 1; i >= 0; i-- )
				{
					(shelf.getChildAt( i ) as MovieClip).gotoAndStop( 2 );
				}
			}
		}

	}
}
