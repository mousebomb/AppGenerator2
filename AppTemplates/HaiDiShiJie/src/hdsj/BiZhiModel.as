/**
 * Created by rhett on 16/2/20.
 */
package hdsj
{

	import flash.filesystem.File;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import ui.Bg1;

	import ui.Bg2;

	import ui.Bg3;

	import ui.Bg4;

	import ui.Bg5;

	public class BiZhiModel
	{

		private static var _instance:BiZhiModel;

		public static function getInstance():BiZhiModel
		{
			if( _instance == null )
				_instance = new BiZhiModel();
			return _instance;
		}

		public function BiZhiModel()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
			load();
			GlobalFacade.regListener( NotifyConst.SAVE_TICK, onNSave );

		}
		private function onNSave( n:Notify ):void
		{
			if( needSaveFlag ) save();
		}

		public var mergeImgList:Array =[];
		private var imgList:Array = [ Bg1,Bg2,Bg3,Bg4,Bg5 ];
		private var exImgList:Array = [];
		//当前的 uniqname  || Class
		private var _curBg:* = Bg1;

		public function save():void
		{
			var serilizeBg: String = curBg;
			if(curBg == Bg1) serilizeBg="Class::Bg1";
			if(curBg == Bg2) serilizeBg="Class::Bg2";
			if(curBg == Bg3) serilizeBg="Class::Bg3";
			if(curBg == Bg4) serilizeBg="Class::Bg4";
			if(curBg == Bg5) serilizeBg="Class::Bg5";
			var sav:Object = {list:exImgList, curBg:serilizeBg};
			SaveFile.getInstance().writeFile( "bizhi", JSON.stringify( sav ) );
		}

		public function load():void
		{
			var savStr:String = SaveFile.getInstance().readFile( "bizhi" );
			if( savStr == null )
			{
				exImgList = [];
				GlobalFacade.sendNotify( NotifyConst.BG_CHANGED, this,null );
			} else
			{
				var sav:Object = JSON.parse( savStr );
				exImgList = sav.list;
				var serilizeBg :String = sav.curBg;
				switch(serilizeBg)
				{
					case "Class::Bg1":
						_curBg = Bg1;
						break;
					case "Class::Bg2":
						_curBg = Bg2;
						break;
					case "Class::Bg3":
						_curBg = Bg3;
						break;
					case "Class::Bg4":
						_curBg = Bg4;
						break;
					case "Class::Bg5":
						_curBg = Bg5;
						break;
					default:
						_curBg = serilizeBg;
				}
			}
			mergeImgList = this.imgList.concat( exImgList );

		}

		/** Class || uniqname:String */
		public function get curBg():*
		{
			return _curBg;
		}
		public function set curBg(v:*):void
		{
			_curBg = v;
			if(v is String)
				GlobalFacade.sendNotify( NotifyConst.BG_CHANGED, this, calcImgFile(_curBg).url );
			else
				GlobalFacade.sendNotify( NotifyConst.BG_CHANGED, this, _curBg );
			needSaveFlag=true;
		}
		public var needSaveFlag:Boolean;

		public function addExImg( uniqname:String ):void
		{
			exImgList.push(uniqname);
			mergeImgList = this.imgList.concat( exImgList );
			curBg = uniqname;
			needSaveFlag = true;
		}
		public function calcImgFile( uniqFilename:String ):File
		{
			if(uniqFilename=="")
				return null;
			else
				return File.applicationStorageDirectory.resolvePath( "bizhi/" + uniqFilename + ".jpg" );
		}

		public function delExImg( uniqname:String ):void
		{
			var file :File = calcImgFile(uniqname);
			if(file.exists)
			{
				file.deleteFile();
			}
			var index:int = exImgList.indexOf(uniqname);
			if(index != -1)
			{
				exImgList.splice(index , 1);
			}
			mergeImgList = this.imgList.concat( exImgList );
			needSaveFlag = true;
		}
	}
}
