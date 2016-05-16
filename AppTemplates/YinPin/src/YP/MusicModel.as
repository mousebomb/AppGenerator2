/**
 * Created by rhett on 15/6/12.
 */
package YP
{

	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class MusicModel
	{

		private static var _instance:MusicModel;

		public static function getInstance():MusicModel
		{
			if( _instance == null )
				_instance = new MusicModel();
			return _instance;
		}

		public function MusicModel()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
		}


		public function grabMusicList():void
		{
			_list=[];
			//
			var mulu :File = File.applicationDirectory.resolvePath("res/mulu.txt");
			var fs :FileStream = new FileStream();
			fs.open(mulu,FileMode.READ);
			var muluContent :String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			trace(muluContent);
			var arr :Array = muluContent.split("\n");
			for( var i:int = 0; i < arr.length; i++ )
			{
				var line:String = arr[i];
				if(line == "") continue;
				var dotIndex : int = line.indexOf(".");
				if(dotIndex == -1) continue;
				var order : int = parseInt( line.substr(0,dotIndex));
				var name :String = line.substr(dotIndex+1);
				var vo :MusicInfoVO = new MusicInfoVO();
				vo.order = order;vo.mp3Name=name;
				vo.mp3File= getMp3File(order);
				vo.thumbFile = getImageFile(order);
				_list.push(vo);
			}
			_list.sortOn("order",Array.NUMERIC);

		}
		public static function getMp3File( basename:int  ):File
		{
			var file:File = File.applicationDirectory.resolvePath( "res/" + basename + ".mp3" );
			if( !file.exists )
			{
				file = File.applicationDirectory.resolvePath( "res/" + basename + ".wav" );
			}
			return file;
		}
		public static function getImageFile( basename:int ):File
		{
			var file:File = File.applicationDirectory.resolvePath( "res/" + basename + ".jpg" );
			if( !file.exists )
			{
				file = File.applicationDirectory.resolvePath( "res/" + basename + ".png" );
			}
			return file;
		}

		private var _list:Array;
		public function get list():Array
		{
			return _list;
		}

        public var curSelectedOrder : int;

	}
}

