/**
 * Created by rhett on 14/12/13.
 */
package td.util
{

	import com.shortybmc.data.parser.CSV;

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class CsvManager
	{
		public function CsvManager()
		{
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoader.addEventListener( Event.COMPLETE, onUrlLoaderComplete );
		}

		private function onUrlLoaderComplete( event:Event ):void
		{
			var csvData:String = urlLoader.data;
			csvDic[curFileName] =  new CSV(csvData);
			loadNext();
		}

		private var urlLoader:URLLoader;
		private var queue:Vector.<String> = new <String>[];

		private var curFileName:String;

		private var csvDic :Dictionary = new Dictionary();
		private var _progress:Function;


		//#2 获取csv

		public function get battleCsv():CSV{ return csvDic["battle.csv"];}
		public function get towerCsv():CSV{ return csvDic["tower.csv"];}
		public function get waveCsv():CSV{ return csvDic["wave.csv"];}


		//#1 加载csv
		public function enqueue( csvPath:String ):void
		{
			queue.push( csvPath );
		}

		public function loadQueue( progress:Function ):void
		{
			_progress = progress;
			loadNext();
		}

		private function loadNext():void
		{

			if( queue.length )
			{
				var fileURL:String  = queue.pop();
				urlLoader.load( new URLRequest( fileURL ) );
				var tmp :int  = fileURL.lastIndexOf("/");
				if(tmp >-1)
				{
					curFileName = fileURL.substring(tmp+1 );
				}else{
					curFileName = fileURL;
				}
			} else
			{
				addLoadComplete();
			}
		}

		private function addLoadComplete():void
		{
			// 数据进行一些冗余字段优化
			//
			_progress( 1.0 );
		}
	}
}
