package org.mousebomb {
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
		/* 填色 嗷嗷广告sdk版 */



		public static const AOAO_APP_ID : uint = ${appID};


        //
		public static const LOCAL_SO_NAME : String = "com.aoaogame.game" + AOAO_APP_ID;
		
		${PicList}

		/**
		 * 列表id
		 */
		public static const LIST_IDS :Array = [ ${PicOrder} ];
		/**
		 * 设计尺寸
		 */
		public static const DESIGN_SIZE_W : Number = 640;
		public static const DESIGN_SIZE_H : Number = 1136;
		/** 实际尺寸 */
		public static var VISIBLE_SIZE_W : Number = 640.0;
		public static var VISIBLE_SIZE_H : Number = 960.0;
        public static var VISIBLE_SIZE_H_MINUS_AD : Number = 860.0;


        public static var ROOT_SCALE :Number;
        // 宽高比
        public static var HW_RATE:Number;
        public static var HW_RATE_IPHONE4:Number = 3/2;
        public static var HW_RATE_IPHONE5:Number = 1136/640;

		public static var AD_H:Number = 100.0;
		
		static public const CN : String = "Cn";
		static public const EN : String = "En";
		// 记录当前是中文环境，还是外文环境
		public static var LANG :String= CN;
		

		public static function onStage(s : Stage,root:Sprite) : void
		{
//			trace('AD_H: ' + (AD_H));
			s.align = StageAlign.TOP_LEFT;
			s.scaleMode = StageScaleMode.NO_SCALE;

            HW_RATE = s.fullScreenHeight / s.fullScreenWidth;

            var sw : Number = s.fullScreenWidth / DESIGN_SIZE_W ;
			var sh : Number = s.fullScreenHeight / DESIGN_SIZE_H ;
			var scale : Number = sw > sh ? sw : sh;ROOT_SCALE=scale;
//			trace('ROOT_SCALE: ' + (ROOT_SCALE));
			
			VISIBLE_SIZE_W = s.fullScreenWidth/scale;
			trace('VISIBLE_SIZE_W: ' + (VISIBLE_SIZE_W));
			VISIBLE_SIZE_H = s.fullScreenHeight/scale;
			trace('VISIBLE_SIZE_H: ' + (VISIBLE_SIZE_H));
            VISIBLE_SIZE_H_MINUS_AD = VISIBLE_SIZE_H - AD_H;
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
			MouseDrager.thresholdMoveDistance =   4*Capabilities.screenDPI / 72 * MouseDrager.thresholdMoveDistance;
//			trace('MouseDrager.thresholdMoveDistance: ' + (MouseDrager.thresholdMoveDistance));

		}
	}
}
