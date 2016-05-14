package org.mousebomb
{
	import flash.net.SharedObject;

	/**
	 * @author Mousebomb
	 */
	public class PaintedModel
	{
		private static var _instance : PaintedModel;

		public static function getInstance() : PaintedModel
		{
			if (_instance == null)
			{
				_instance = new PaintedModel(new SingletonEnforcer());
			}
			return _instance;
		}

		public function PaintedModel(s : SingletonEnforcer)
		{
		}

		private var _data : Object = {};
		public static var so : SharedObject;
		
		/**
		 * 最近一次read出来后是否有改动 (做是否要保存的判定)
		 */
		private var _modified :Boolean  = false;

		public function putColor(color : uint, index : int) : void
		{
			_data[index] = color;
			_modified=true;
		}

		public function getColor(index : int) : uint
		{
			if (_data[index])
			{
				return _data[index];
			}
			else
			{
				return 0xffffff;
			}
		}

		public function save(picId : int) : void
		{
			so = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			var savKey : String = "pic" + picId;
			so.data[savKey] = _data;
			so.flush();
			so.close();
		}

/**
 * 返回有没有玩过
 */
		public function read(picId : int) : Boolean
		{
			var end :Boolean = false;
			so = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			var savKey : String = "pic" + picId;
			if (null == so.data[savKey])
			{
				_data = {};
			}
			else
			{
				_data = so.data[savKey];
				end = true;
			}
			so.close();
			_modified = false;
			return end;
		}

/**
 * 最近一次read出来后是否有改动 (做是否要保存的判定)
 */
		public function get modified() : Boolean
		{
			return _modified;
		}

/**
 * 清空所有玩的记录
 */
		public function reset() : void
		{
			so = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			for each(var picId :int in GameConf.LIST_IDS)
			{var savKey : String = "pic" + picId;
				so.data[savKey]=null;
				
			}
			so.flush();
			so.close();
		}
	}
}
class SingletonEnforcer
{
}