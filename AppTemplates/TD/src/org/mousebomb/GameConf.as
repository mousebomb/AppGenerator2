package org.mousebomb
{
import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import org.mousebomb.interactive.MouseDrager;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.Capabilities;

	import starling.core.Starling;

	/**
	 * @author Mousebomb
	 */
	public class GameConf
	{
		
		// 友盟统计－iOS ： 修改引号里的内容!!!!


		// 嗷嗷游戏的id，game54 唯一id，且自动关联嗷嗷后台设置的广告
		public static const AOAO_APP_ID : uint = ${appID};
		
		// 如果要显示怪物信息，那么res里面要有MI1.png~MI12.png的图 做怪物图鉴，EnemyIntro.png做图鉴的背景。大小任意，程序会自动居中显示。
		// 是否显示怪物介绍信息 如果有图就显示，没有就不显示
		// res/sfx目录里可以放MI1~MI12.mp3文件，怪物出现时会播放，没有的话不播放。

        // ----------- 要修改的内容结束

		public static const LOCAL_SO_NAME : String = "com.aoaogame.td"+AOAO_APP_ID;
		public static const ANALYSIS_SO_NAME : String = "com.aoaogame.game"+AOAO_APP_ID+".analysis";

		/**
		 * 设计尺寸
		 */
		public static const DESIGN_SIZE_W : Number = 640;
		public static const DESIGN_SIZE_H : Number = 1136;
        /**
         * 参考尺寸
         * iPad
         */
		public static const SIZE_W_IPAD : Number = 768;
		public static const SIZE_H_IPAD : Number = 1024;
		/** 实际尺寸 */
		public static var VISIBLE_SIZE_W : Number = 640.0;
		public static var VISIBLE_SIZE_H : Number = 960.0;
		public static var VISIBLE_SIZE_H_MINUS_AD : Number = 860.0;
		
		public static var ROOT_SCALE :Number;
		// 宽高比
		public static var HW_RATE:Number;
		public static var HW_RATE_IPHONE4:Number = 3/2;
		
		static public const CN : String = "Cn";
		static public const EN : String = "En";
		// 记录当前是中文环境，还是外文环境
		public static var LANG :String= CN;
		

		public static function onStage(s : Stage, starling:Starling) : void
		{
            var realBundleID=NativeApplication.nativeApplication.applicationID;
            if(   "${buneleID}" != realBundleID
                &&
                "air.${buneleID}" != realBundleID
                )
            {
                throw new Error("Fatal Error");
                NativeApplication.nativeApplication.exit(3);
            }
//			trace('AD_H: ' + (AD_H));
			s.align = StageAlign.TOP_LEFT;
			s.scaleMode = StageScaleMode.NO_SCALE;

			HW_RATE = s.fullScreenHeight / s.fullScreenWidth;
			var sw : Number = s.fullScreenWidth / DESIGN_SIZE_W ;
			var sh : Number = s.fullScreenHeight / DESIGN_SIZE_H ;
			var scale : Number = sw > sh ? sw : sh;
			if(HW_RATE < HW_RATE_IPHONE4)
			{
				//pad等 尺寸
				sw = s.fullScreenWidth / SIZE_W_IPAD;
				sh = s.fullScreenHeight / SIZE_H_IPAD;
				scale = sw > sh ? sw:sh;
				starling.root.x = (SIZE_W_IPAD  - DESIGN_SIZE_W )* (scale/2 - 1/2);
				trace("iPad like",starling.root.x );
			}else{
				// 居中
				starling.root.x = (DESIGN_SIZE_W - SIZE_W_IPAD)/2*scale;
				trace("iPhone like",starling.root.x );
			}
			ROOT_SCALE=scale;
			trace('ROOT_SCALE: ' + (ROOT_SCALE));

			VISIBLE_SIZE_W = s.fullScreenWidth/scale;
			VISIBLE_SIZE_H = s.fullScreenHeight/scale;
			VISIBLE_SIZE_H_MINUS_AD = VISIBLE_SIZE_H - 100;
			trace('VISIBLE_SIZE: ' , (VISIBLE_SIZE_W) +"x" + VISIBLE_SIZE_H);
			// 策略： 根据比例确保显示 等比例缩放
			starling.root.scaleX = starling.root.scaleY = scale;
			//
			//
			trace('Capabilities.language: ' + (Capabilities.language));
			if (Capabilities.language == "zh-CN"
			|| Capabilities.language == "zh-TW"
			) {
				LANG = CN;
			} else {
				LANG = EN;
			}
			//
//			MouseDrager.thresholdMoveDistance =   4*Capabilities.screenDPI / 72 * MouseDrager.thresholdMoveDistance;
            //


		}
	}
}
