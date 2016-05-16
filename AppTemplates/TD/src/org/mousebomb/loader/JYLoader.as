package org.mousebomb.loader
{


    /**
     *

     * 3种资源
     *	ByteArray zip包
     * Class 完成 new
     * png。。。图片 BitmapData
     *
     * 加一个group，每个group有优先级。

     * 速度统计

     * 暂停／结束*
     *
     * @author rhett
     */
    public class JYLoader
    {
        private static var _instance:JYLoader;

        public static function getInstance():JYLoader
        {
            if (_instance == null)
            {
                _instance = new JYLoader();
            }
            return _instance;
        }

        public function JYLoader()
        {
            if (_instance != null)
            {
                throw new Error('singleton');
            }

        }


        /**
         * 加载运行时共享类。如UI，动画序列帧。
         * 此类资源加载完成后可以直接new出来用。 cb(true,...args);
         */
        public static const RES_RSL:int       = 1;

        /**
         * 加载位图资源 png等等，如地图瓦片。
         * 会异步decode，完成后回调 cb(BitmapData,...args);
         */
        public static const RES_BITMAP:int    = 2;

        /**
         * 加载二进制数据，配置等。
         * 完成后会回调并带原始数据 cb(ByteArray,...args);
         */
        public static const RES_BYTEARRAY:int = 3;

        /**
         * 加载资源
         * @param type  类型常量在 BombLoader.RES_RSL ,RES_BITMAP ,RES_BYTEARRAY
         * @see BombLoader
         */
        public function reqResource(url:String,type:int,priority:int,cb:Function,progCb:Function = null,mark:* = null):void
        {
            JYLoadUnit.getResource(url,type,priority,cb,progCb,mark);
        }

        private var _topSpeed:Number          = 0.0;

        private var _loadSpeed:Number         = 0.0;

        private var _totalLoaded:Number       = 0.0;

        /**
         * 准备统计数据
         */
        public function updateStats():void
        {
            _loadSpeed = 0.0;
            _totalLoaded = 0.0;

            var allUnits:Vector.<JYLoadUnit> = JYLoadUnit.pool;

            for each (var loadUnit:JYLoadUnit in allUnits)
            {
                _loadSpeed += loadUnit.currentSpeed;
                _totalLoaded += (loadUnit.totalLoaded) / 1000;
            }

            if (_loadSpeed > _topSpeed)
            {
                _topSpeed = _loadSpeed;
            }
        }

        /**
         * 当前的加载速度
         */
        final public function get loadSpeed():Number
        {
            return _loadSpeed;
        }

        /**
         * 总下载流量
         */
        final public function get totalLoaded():Number
        {
            return _totalLoaded;
        }

        /**
         * 下载速度峰值
         */
        final public function get topSpeed():Number
        {
            return _topSpeed;
        }

        /**
         * 重置下载任务－清除并停止所有的下载
         */
        public function reset():void
        {
            JYLoadUnit.resetAllUnits();
        }

        /**
         * 某组资源全部加载完成时回调(只生效一次)
         */
        public function addAllLoadCompleteCallback(onAllLoaderComplete:Function):void
        {
            JYLoadUnit.addAllLoadCompleteCallback(onAllLoaderComplete);
        }

        /**
         * 某些情况下，下载来的东西会被外部释放（BitmapData被dispose），必须标记为缓存不在了，下次再需要的时候要重新下载。
         */
        public function markAsNocache(url:String):void
        {
            delete JYLoadUnit.imageCache[url];
        }
    }
}
