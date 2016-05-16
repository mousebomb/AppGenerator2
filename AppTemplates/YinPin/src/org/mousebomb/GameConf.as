package org.mousebomb
{
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import org.mousebomb.interactive.MouseDrager;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.Capabilities;
import flash.desktop.NativeApplication;

    /**
	 * @author Mousebomb
	 */
	public class GameConf
	{

        // 友盟统计－iOS ： 修改引号里的内容!!!!


        // 嗷嗷游戏的id，game54 唯一id，且自动关联嗷嗷后台设置的广告
        public static const AOAO_APP_ID : uint = ${appID};

		public static const LOCAL_SO_NAME : String = "com.aoaogame.game"+AOAO_APP_ID;
		public static const ANALYSIS_SO_NAME : String = "com.aoaogame.game"+AOAO_APP_ID+".analysis";

		/**
		 * 设计尺寸
		 */
		public static const DESIGN_SIZE_W : Number = 768;
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
		
		

		public static function onStage(s : Stage,root:Sprite) : void
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
                // 居中
                root.x = (SIZE_W_IPAD  - DESIGN_SIZE_W )*scale /2;
				trace('root.x: ' + (root.x));
            }
            ROOT_SCALE=scale;
			trace(sw,sh,'ROOT_SCALE: ' + (ROOT_SCALE));
			
			VISIBLE_SIZE_W = s.fullScreenWidth/scale;
//			trace('VISIBLE_SIZE_W: ' + (VISIBLE_SIZE_W));
			VISIBLE_SIZE_H = s.fullScreenHeight/scale;
//			trace('VISIBLE_SIZE_H: ' + (VISIBLE_SIZE_H));
			VISIBLE_SIZE_H_MINUS_AD = VISIBLE_SIZE_H - 100;
			// 策略： 根据比例确保显示 等比例缩放
			root.scaleX = root.scaleY = scale;
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
			trace("Visible Size = ",VISIBLE_SIZE_W,VISIBLE_SIZE_H);
			trace("Design Size = " , DESIGN_SIZE_W,DESIGN_SIZE_H);



			//
//			MouseDrager.thresholdMoveDistance =   4*Capabilities.screenDPI / 72 * MouseDrager.thresholdMoveDistance;
		}
	}
}
