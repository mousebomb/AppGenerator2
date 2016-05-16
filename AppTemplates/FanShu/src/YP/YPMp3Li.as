/**
 * Created by rhett on 15/6/13.
 */
package YP
{

	import YP.MusicModel;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLRequest;

	public class YPMp3Li extends Sprite
	{
		private var ui:Mp3Li;

		public function YPMp3Li()
		{
			super();
			ui = new Mp3Li();
			addChild( ui );
		}

		private var imgLoader:Loader;

		public function loadThumb(imgFile:File):void
		{
			imgLoader = new Loader();
			imgLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onThumbLoaded );
			imgLoader.load( new URLRequest( imgFile.url ) );
		}

		private function onThumbLoaded( event:Event ):void
		{
			imgLoader.x = ui.thumb.x;
			imgLoader.y = ui.thumb.y;
			imgLoader.width = ui.thumb.width;
			imgLoader.height = ui.thumb.height;
			ui.removeChild( ui.thumb );
			ui.addChild( imgLoader );
		}


		private var _vo:MusicInfoVO;
		public function get vo():MusicInfoVO
		{
			return _vo;
		}

		public function set vo( value:MusicInfoVO ):void
		{
			_vo = value;
			ui.nameTf.text = vo.order + "."+vo.mp3Name;
			if(vo.thumbFile!=null)loadThumb(vo.thumbFile);
		}
	}
}
