<?php
/** 纯安装
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/6/14
 * Time: 14:43
 */

require_once dirname(__FILE__) . "/inc.php";
$app=input('app');
$app = trim($app);
if(IS_WIN)
{
    $app = iconv("UTF-8", "GBK", $app);
}
?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>安装助手</title>
    <link rel="stylesheet" href="css/style.css"/>
    <link rel="stylesheet" href="css/general.css"/>
    <link rel="stylesheet" href="css/extra.css"/>

</head>
<body>
<div id="project-menu">
    <a href="./create.php">创建新App</a>
    <a href="./list.php">App列表</a>
</div>
<?php
    ?>
    <form action="" method="post">
        <table>
                <tr>
                    <td>安装的ipa或apk路径</td>
                    <td><input type="text" name="app" value="<?php echo $app; ?>" /></td>
                        <td>
                        <input type="submit" value="安装"/></td>
                </tr>

        </table>



    </form>

    <?

    if(!empty($app) && file_exists($app))
    {
        $dotIndex = strrpos($app,".apk");
        if($dotIndex) $isApk = true;
        $dotIndex = strrpos($app,".ipa");
        if($dotIndex) $isIpa = true;
        if($isIpa){
            # 安装iOS

            $chkIOSDeviceCmd = ADT."  -devices -platform iOS";

            $op = execCmd(ADT ."  -devices -platform iOS","查找iOS设备");

            if(empty($op[2]))
            {
                echo("<pre>无法发现ios设备</pre>");
            }else{
                //有iOS设备
                $deviceRawData = $op[2];
                $tabIndex = strpos($deviceRawData,"\t");
                $deviceID = substr($deviceRawData,0,$tabIndex);
                echo("<pre>已发现iOS设备".$deviceID ."</pre>");
                $installCmd = ADT." -installApp -platform ios -device ".$deviceID." -package ".$app;
                if(!empty($deviceID))
                    execCmd($installCmd);
            }

        }else{
            #安装apk
            execCmd(FLEX_HOME."/lib/android/bin/adb install -r ".$app,"尝试安装到手机");
        }

    }
?>

</body>
</html>