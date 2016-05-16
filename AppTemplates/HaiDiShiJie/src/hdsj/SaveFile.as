/**
 * Created by rhett on 16/2/18.
 */
package hdsj
{

	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Timer;

	import org.mousebomb.framework.GlobalFacade;

	public class SaveFile
	{

		private static var _instance:SaveFile;

		public static function getInstance():SaveFile
		{
			if( _instance == null )
				_instance = new SaveFile();
			return _instance;
		}

		public function SaveFile()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
			scheduleSave();
		}
		private var savTimer :Timer = new Timer(5000);

		private function scheduleSave():void
		{
			savTimer.addEventListener(TimerEvent.TIMER, onSaveTimer);
			savTimer.start();
		}

		private function onSaveTimer( event:TimerEvent ):void
		{
			GlobalFacade.sendNotify( NotifyConst.SAVE_TICK, this );
		}

		private function filePath( name:String ):File
		{
			return File.applicationStorageDirectory.resolvePath( "save/" + name + ".sav" );
		}

		public function writeFile( name:String, content:String ):void
		{
//			trace("SaveFile/writeFile()",name,content);
			var fs:FileStream = new FileStream();
			var file:File = filePath( name );
			fs.open( file, FileMode.WRITE );
			fs.writeUTF(content);
			fs.close();
		}

		public function readFile( name:String ):String
		{
			var fs:FileStream = new FileStream();
			var file:File = filePath( name );
			trace("SaveFile/readFile()",file.nativePath);
			if(file.exists){
				fs.open( file, FileMode.READ );
				var content :String = fs.readUTF();
				fs.close();
				return content;
			}else{
				return null;
			}
		}
	}
}
