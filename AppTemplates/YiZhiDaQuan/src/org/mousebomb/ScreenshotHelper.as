package org.mousebomb
{

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.JPEGEncoderOptions;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;

	import org.mousebomb.GameConf;

	/**
	 * @author Administrator
	 */
	public class ScreenshotHelper
	{
		private static var game:DisplayObject;

		private static var nextI:int = 1;

		private static function onKeyDown( event:KeyboardEvent ):void
		{
			if( event.keyCode == Keyboard.SPACE )
			{
				SoundMan.playSfx( SoundMan.BTN );
				var sc:BitmapData = new BitmapData( game.stage.fullScreenWidth, game.stage.fullScreenHeight );
				sc.draw( game );
				var file:File = File.desktopDirectory.resolvePath( "Game" + GameConf.AOAO_APP_ID + "-" + sc.width + "x" + sc.height + "-" + nextI + ".jpg" );
				nextI++;
				var opt:JPEGEncoderOptions = new JPEGEncoderOptions( 80 );
				var jpgData:ByteArray = sc.encode( sc.rect, opt );
				var fs:FileStream = new FileStream();
				fs.open( file, FileMode.WRITE );
				fs.writeBytes( jpgData );
				fs.close();
			}
		}

		public static function init( game:DisplayObject ):void
		{
			ScreenshotHelper.game = game;
			game.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
	}
}
