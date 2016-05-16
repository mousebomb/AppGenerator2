/**
 * Created by rhett on 14/12/27.
 */
package td
{

	import org.osmf.events.MediaPlayerStateChangeEvent;

	public class NotifyConst
	{
		/**
		 * data : EnemyVO
		 * Model > View
		 */
		public static const ENEMYVO_CREATED:String = "ENEMYVO_CREATED";
		/**
		 * EnemyVO > Enemy
		 */
		public static const ENEMYVO_MOVED:String = "ENEMYVO_MOVED";
		/**
		 * enemyVO自己 移除 （走完或被打死）时发起
		 * EnemyVO > Model,View
		 */
		public static const ENEMYVO_REMOVED:String = "ENEMYVO_REMOVED";
		/**
		 * EnemyVO 抵达终点 要扣血噢
		 * EnemyVO > Model
		 */
		public static const ENEMYVO_FINISHLINE:String = "ENEMYVO_FINISHLINE";
		/**
		 * EnemyVO > View
		 */
		public static const ENEMYVO_ENEMYHIT:String = "ENEMYVO_ENEMYHIT";
		/**
		 * EnemyVO > View,Model
		 */
		public static const ENEMYVO_ENEMYDOWN:String = "ENEMYVO_ENEMYDOWN";
		/**
		 * Model > View
		 */
		public static const BULLETVO_CREATED:String = "BULLETVO_CREATED";
		/**
		 * VO > Bullet
		 */
public static const BULLETVO_MOVED:String = "BULLETVO_MOVED";
		/**
		 * VO > Model,View
		 */
public static const BULLETVO_REMOVED:String = "BULLETVO_REMOVED";
		/**
		 * 击中目标
		 * BulletVO > Model
		 * @data EnemyVO
		 */
public static const BULLETVO_HITTARGET:String = "BULLETVO_HITTARGET";

		/**
		 * 塔VO产生
		 * Model > View
		 */
		public static const TOWERVO_CREATED:String = "TOWERVO_CREATED";
		/**
		 * Model > Tower
		 */
		public static const TOWERVO_UPDATED:String = "TOWERVO_UPDATED";
		/**
		 * TowerVO > Tower
		 */
		public static const TOWERVO_STATE_CHANGED:String = "TOWERVO_STATE_CHANGED";
		/**
		 * 点击塔基座
		 * Tower > HUD
		 */
		public static const TOWER_SLOT_CLICK:String = "TOWER_SLOT_CLICK";

		/**
		 * 钱变化
		 * Model > HUD
		 */
		public static const MONEY_UPDATED:String = "MONEY_UPDATED";
		/**
		 * 玩家血变化
		 * Model > HUD
		 */
		public static const LIFE_UPDATED:String = "LIFE_UPDATED";
		/**
		 * Model > HUD
		 * 波数在model里可查
		 */
		public static const WAVE_UPDATED:String = "WAVE_UPDATED";
		/**
		 * 出现了新NPC
		 * @data enemyId
		 * model > HUD
		 */
		public static const NEW_ENEMY_INTRO:String = "NEW_ENEMY_INTRO";
		/**
		 * UI通知展示／关闭 新怪物图鉴
		 * UI > Model
		 */
		public static const UI_ENEMY_INTRO_SHOW:String = "UI_ENEMY_INTRO_SHOW";
		public static const UI_ENEMY_INTRO_HIDE:String = "UI_ENEMY_INTRO_HIDE";
		
		/**
		 * UI > BattleField
		 */
		public static const UI_BATTLE_INTRO_HIDE:String = "UI_BATTLE_INTRO_HIDE";
		
		/**
		 * UI请求暂停／继续
		 * UI > Model
		 */
		public static const UI_BATTLE_GOON:String = "UI_BATTLE_GOON";
		public static const UI_BATTLE_PAUSE:String = "UI_BATTLE_PAUSE";
		/**
		 * 战斗暂停／继续
		 * Model > HUD
		 */
		public static const BATTLE_GOON:String = "BATTLE_GOON";
		public static const BATTLE_PAUSE:String = "BATTLE_PAUSE";
		public static const BATTLE_START:String = "BATTLE_START";

		/**
		 * 胜利
		 * @data = star:int
		 * Model > HUD
		 */
		public static const BATTLE_WON:String = "BATTLE_WON";
		/**
		 * 失败
		 * Model > HUD
		 */
		public static const BATTLE_LOST:String = "BATTLE_LOST";
		/**
		 * UI点击 投降
		 * UI > Model
		 */
		public static const UI_SURRENDER:String = "UI_SURRENDER";

		// UI点击 塔操作
		/**
		 * 造塔
		 * @data towerId
		 * UI > Model
		 */
		public static const UI_TOWER_BUILD:String = "UI_TOWER_BUILD";
		/**
		 * 造塔
		 * @data towerId 升级到
		 * UI > Model
		 */
		public static const UI_TOWER_UPGRADE:String = "UI_TOWER_UPGRADE";
		/**
		 * 造塔
		 * UI > Model
		 */
		public static const UI_TOWER_SELL:String = "UI_TOWER_SELL";


		/**
		 * UI 请求返回关卡选择界面
		 * UI > HUD
		 */
		public static const UI_GOTO_SELECTLEVEL:String = "UI_GOTO_SELECTLEVEL";
		/**
		 * UI 点击了li
		 * UI > Root
		 */
		public static const UI_SELECTLEVEL_LI_CLICK:String = "UI_SELECTLEVEL_LI_CLICK";
		/**
		 * UI > Root
		 */
		public static const UI_GOTO_NEXT:String = "UI_GOTO_NEXT";
		/**
		 * UI请求重新本关卡
		 * UI > BattleField?
		 */
		public static const UI_RESTART:String = "UI_RESTART";

		/**
		 * UI倒数开始结束
		 * UI > BattleField
		 */
		public static const UI_READYSTART_FINISH:String = "UI_READYSTART_FINISH";

	}
}
