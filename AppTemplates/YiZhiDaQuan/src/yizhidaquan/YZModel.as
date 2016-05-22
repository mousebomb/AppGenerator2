/**
 * Created by rhett on 16/5/22.
 */
package yizhidaquan
{

	import flash.net.SharedObject;

	import org.mousebomb.GameConf;

	public class YZModel
	{

		private static var _instance:YZModel;

		public static function getInstance():YZModel
		{
			if( _instance == null )
				_instance = new YZModel();
			return _instance;
		}

		public function YZModel()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
		}

		public static var so:SharedObject;

		private var _playedIndex : int = -1;

		/** 获得解锁了的序号  0填色  1简笔画 ... */
		public function getPlayedIndex():int
		{
			var end:int;
			so = SharedObject.getLocal( GameConf.LOCAL_SO_NAME );
			var savKey:String = "playedIndex";
			if( null == so.data[savKey] )
			{
				so.data[savKey] = 0;
				so.flush();
				end = 0;
			} else
			{
				end = so.data[savKey];
			}
			so.close();
			_playedIndex = end;
			return end;
		}

		public function setPlayed( index:int ):void
		{
			if(_playedIndex>=index) return;
			so = SharedObject.getLocal( GameConf.LOCAL_SO_NAME );
			var savKey:String = "playedIndex";
			so.data[savKey] = index;
			_playedIndex = index;
			so.flush();
			so.close();
		}
	}
}
