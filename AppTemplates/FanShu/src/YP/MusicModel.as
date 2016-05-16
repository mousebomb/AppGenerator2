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


		/** 扫描目录，并返回；以后调用list获得缓存 */
		public function grabMusicList():Array
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
				vo.order = order;
				vo.mp3Name=name;
				vo.thumbFile = getImageFile(order);
				/** 分开处理目录内容各页 */
				vo.pages = new <PageInfoVO>[];
				var curFolder :File = File.applicationDirectory.resolvePath("res/"+order);
				if(!curFolder.exists)
				{
					throw  new Error("目录不存在:" + curFolder.nativePath);
				}
				for( var j:int = 1; j < 1000; j++ )
				{
					var imgFile :File = getImageFile(j,order);
					var mp3File :File = getMp3File(j,order);
					if(imgFile == null) break;
					var pageInfo :PageInfoVO = new PageInfoVO();
					pageInfo.imgFile = imgFile;
					pageInfo.mp3File = mp3File;
					pageInfo.order = j;
					vo.pages.push(pageInfo);
				}
				_list.push(vo);
			}
			_list.sortOn("order",Array.NUMERIC);
			return _list;

		}
		/** subFolder子目录，若0则跟目录 */
		public static function getMp3File( basename:int ,subFolder:int ):File
		{
			var filetoken :String = basename.toString();
			if(subFolder) filetoken = subFolder +"/"+basename;
			var file:File = File.applicationDirectory.resolvePath( "res/" + filetoken + ".mp3" );
			if( !file.exists )
			{
				file = File.applicationDirectory.resolvePath( "res/" + filetoken + ".wav" );
			}
			if(!file.exists) return null;
			return file;
		}
		/** subFolder子目录，若0则跟目录 */
		public static function getImageFile( basename:int,subFolder:int=0 ):File
		{
			var filetoken :String = basename.toString();
			if(subFolder) filetoken = subFolder +"/"+basename;
			var file:File = File.applicationDirectory.resolvePath( "res/" + filetoken + ".jpg" );
			if( !file.exists )
			{
				file = File.applicationDirectory.resolvePath( "res/" + filetoken + ".png" );
			}
			if( !file.exists )
			{
				file = File.applicationDirectory.resolvePath( "res/" + filetoken + ".swf" );
			}
			if(!file.exists) return null;
			return file;
		}

		private var _list:Array;
		public function get list():Array
		{
			return _list;
		}


	}
}

