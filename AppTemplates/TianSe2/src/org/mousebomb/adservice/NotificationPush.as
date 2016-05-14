/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice
{
    import org.mousebomb.Localize;
    import org.mousebomb.DebugHelper;
    import org.mousebomb.GameConf;
    import org.mousebomb.DebugHelper;
    import com.juankpro.ane.localnotif.Notification;
    import com.juankpro.ane.localnotif.NotificationManager;

	import flash.utils.setTimeout;

	public class NotificationPush
	{

        private static const NOTIFICATION_CODE : String = "NOTIFICATION_CODE_001";
        private static var notificationManager : NotificationManager;

        public function NotificationPush()
		{
		}
        public static function notifyTomorrow():void
        {

            CONFIG::ANDROID
            {
                 //
                if (NotificationManager.isSupported)
                {
                    notificationManager = new NotificationManager();
                    var notification : Notification = new Notification();
                    // 滑动来xx
                    notification.actionLabel = Localize.notificationAction;
                    // 通知内容
                    notification.body = Localize.notificationIntro;
                    notification.title = Localize.notificationTitle;
                    notification.fireDate = new Date((new Date()).time + (1000 * 60 * 60 * 24));
    //                    notification.fireDate = new Date((new Date()).time + (10000));
                    notification.numberAnnotation = 1;
                    notificationManager.cancel(NOTIFICATION_CODE);
                    notificationManager.notifyUser(NOTIFICATION_CODE, notification);
                }

            }
        }
	}
}
