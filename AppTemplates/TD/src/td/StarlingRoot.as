/**
 * Created by rhett on 14/10/26.
 */
package td
{

	import org.mousebomb.SoundMan;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.system.Capabilities;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import starling.display.Sprite;
	import starling.textures.Texture;

	import td.battlefield.model.BattleFieldModel;

	import td.battlefield.view.BattleField;
	import td.lobby.view.LoadingUI;
	import td.lobby.view.SelectLevelUI;
	import td.util.ImageDataModel;
	import td.util.StaticDataModel;

	public class StarlingRoot extends Sprite
	{

		private var battleField:BattleField;
		private var loadingUI:LoadingUI;
		private var selectLevelUI:SelectLevelUI;

		public function StarlingRoot()
		{
			GlobalFacade.regListener( NotifyConst.UI_GOTO_SELECTLEVEL, onGotoSelectLevel );
			GlobalFacade.regListener( NotifyConst.UI_SELECTLEVEL_LI_CLICK, onSelectLevelSel );
			GlobalFacade.regListener( NotifyConst.UI_GOTO_NEXT, onGotoNext );
			GlobalFacade.regListener( NotifyConst.BATTLE_WON, onAttachAd );
			GlobalFacade.regListener( NotifyConst.BATTLE_LOST, onAttachAd );
		}

		private function onAttachAd(n:Notify):void
		{
			AoaoBridge.interstitial(TDGame.instance);
		}

		// 选了关
		private function onSelectLevelSel(n:Notify):void
		{
			//
			prepareBattle(n.data);
		}

		private function onGotoSelectLevel( n:Notify ):void
		{
			presentLobby();
		}

		private function onGotoNext( n:Notify ):void
		{
			prepareBattle( BattleFieldModel.getInstance().battleVO.battleId + 1 );
		}

		public function presentLobby():void
		{
			trace( "StarlingRoot/presentLobby()" );
			if( selectLevelUI == null ) selectLevelUI = new SelectLevelUI();
			removeChildren();
			selectLevelUI.validate();
			addChild( selectLevelUI );
			SoundMan.playBgm("lobby.mp3");
			
			AoaoBridge.banner(TDGame.instance);
		}

		public function presentLoading():void
		{
			trace( "StarlingRoot/presentLoading()" );
			if( loadingUI == null ) loadingUI = new LoadingUI();
			removeChildren();
			addChild( loadingUI );
		}

		/**
		 * 准备战场
		 * @param battleId 关卡 对应level
		 */
		public function prepareBattle( battleId:int ):void
		{
			presentLoading();
			//# 加载所需数据和素材

			// 明确数据
			// 配置 battleCsv的行
			// 明确<wave>
			var staticData:StaticDataModel = StaticDataModel.getInstance();
			var bfModel:BattleFieldModel = BattleFieldModel.getInstance();
			bfModel.gotoLevel( staticData.battleCsvDic[battleId], staticData.waveCsvDic[battleId] );


			// 加载背景图
			var imageDataModel:ImageDataModel = ImageDataModel.getInstance();
			imageDataModel.onComplete = onImageLoaded;
			imageDataModel.loadImageToAssets( bfModel.getMapBgURL(), "mapBg" );

			AoaoBridge.banner(TDGame.instance);
		}

		private function onImageLoaded():void
		{
			presentBattle();
		}

		/**
		 * 进入战场
		 */
		public function presentBattle():void
		{
			if( battleField == null )
			{
				battleField = new BattleField();
			}
			removeChildren();
			addChild( battleField );
			battleField.initLevel();

		}
	}
}
