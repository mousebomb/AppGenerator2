/**
 * Created by rhett on 14/12/28.
 */
package td.battlefield.view
{
	import flash.geom.Point;

	import org.mousebomb.GameConf;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;
	import org.mousebomb.ui.Shelf;

	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	import td.NotifyConst;
	import td.battlefield.model.BattleFieldModel;
	import td.battlefield.model.BattleFieldModel;
	import td.battlefield.model.vo.TowerCsvVO;
	import td.battlefield.model.vo.TowerVO;
	import td.util.StaticDataModel;

	public class BuildTowerUI extends Sprite
	{
		private var left : Number;
		private var right : Number;
		private var top : Number;
		private var bottom : Number;

		public function BuildTowerUI()
		{
			var bg : Texture = TDGame.assetsMan.getTexture("WarUI_BottomBorder");
			if (bg.frame)
			{
				marginX = bg.frame.width;
				marginY = bg.frame.height;
			}
			else
			{
				marginX = bg.width;
				marginY = bg.height;
			}
			GlobalFacade.regListener(NotifyConst.UI_TOWER_BUILD, onTriggered);

			left = GameConf.SIZE_W_IPAD - GameConf.DESIGN_SIZE_W;
			right = GameConf.DESIGN_SIZE_W ;
			top = 0;
			bottom = GameConf.VISIBLE_SIZE_H_MINUS_AD;
		}

		private function onTriggered(n : Notify) : void
		{
			removeFromParent();
		}

		/**
		 * 更新显示
		 * @param towerVO 选择的塔基座
		 */
		public function updateBuild(towerVO_ : TowerVO) : void
		{
			towerVO = towerVO_;
			this.setList(StaticDataModel.getInstance().towerLv1CsvList);
		}

		// 操作面向的塔
		public static var towerVO : TowerVO;
		//
		/**
		 * 修正浮动UI可能出屏幕的坐标
		 * @param DisplayObject
		 */
		// private function fixOverflow( fUI:DisplayObject ):void
		// {
		// var minX:Number = GameConf.SIZE_W_IPAD - GameConf.DESIGN_SIZE_W;
		// var maxX:Number = GameConf.DESIGN_SIZE_W - fUI.width;
		// if( fUI.x < minX ) fUI.x = minX; else if( fUI.x > maxX )    fUI.x = maxX;
		// var minY:Number = 0;
		// var maxY:Number = GameConf.VISIBLE_SIZE_H_MINUS_AD;
		// if( fUI.y < minY ) fUI.y = minY; else if( fUI.y > maxY ) fUI.y = maxY;
		// }
		// shelf
		// 数据 arrayOrVector
		private var _voArray : Vector.<TowerCsvVO>;
		public var marginX : Number = 20.0;
		public var marginY : Number = 20.0;

		/**
		 * 设置内容
		 *  设置完成后尝试设置页码
		 */
		public function setList(arrayOrVector : Vector.<TowerCsvVO>) : void
		{
			// build matrix
			_voArray = arrayOrVector.concat();
			//
			cls();
			for (var i : int = 0; i < _voArray.length; i++)
			{
				var vo : TowerCsvVO = _voArray[i];
				var li : BuildTowerLi = new BuildTowerLi();
				var pt : Point = getNextPos(i);
				li.x = pt.x;
				li.y = pt.y;
				li.init(vo.towerId, vo.money);
				addChild(li);
			}
		}
//外围级别
public var curSlot:int = 0;

		// 围绕点击位置来显示
		private function getNextPos(i : int) : Point
		{
			var end :Point = AroundSlots.getSlotPos(curSlot++);
			end.x = end.x * marginX;
			end.y = end.y*marginY;
//			trace(left,right,top,bottom);
//			trace("Pick:",curSlot,end);
			while(end.x+x >= right ||  end.x+x <= left || end.y+y >=bottom || end.y+y <=top)
			{
				end = AroundSlots.getSlotPos(curSlot++);
				end.x *= marginX;end.y*=marginY;
//				trace("Pick:",curSlot,end);
			}
			return end;
		}
		

		public function cls() : void
		{
			for (var i : int = numChildren - 1; i >= 0; --i)
			{
				removeChildAt(i);
			}
			curSlot = 0;
		}
	}
}
