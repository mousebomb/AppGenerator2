<?php
/**
 * 发布apk / ipa / ipa-iTC
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/19
 * Time: 20:01
 */

require_once dirname(__FILE__) . "/inc.php";

$appID=input('id');
$type=input('type');
$install=input('install');

$autoFillData=readSeedByAppID($appID);
$template=$autoFillData['template'];
$bundleID = $autoFillData['bundleID'];

# 根据配置读入keystore
$p12Apk= getUserP12OrDefaultP12($autoFillData['p12Apk'],$appID);
$KEYSTORE = P12_ROOT."/".$p12Apk;

#gen Folder
$templ = TEMPLATES_ROOT."/".$template;
$gen = GENERATOED_ROOT."/app".$appID;
$icon = $gen."/icon";

$debug = 'false';
$isIpa= 'false';
$isApk= 'false';
$isDesktop= 'false';
if($type == "desktop")
{
    $debug='true';
    $isDesktop='true';
}else if($type == 'apk')
{
    $isApk='true';
}else if ($type =='ipa')
{
    $isIpa = 'true';
}

?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>发布包</title>
    <link rel="stylesheet" href="css/style.css"/>
    <link rel="stylesheet" href="css/general.css"/>
    <link rel="stylesheet" href="css/extra.css"/>

</head>
<body>
<div id="project-menu">
    <?php echo $autoFillData['zhName'] . "(".$template.")"; ?>
    <a href="./create.php">创建新App</a>
    <a href="./list.php">App列表</a>
</div>

<div id="main-menu">
    <a href="edit.php?id=<?php echo $appID; ?>">1.基本信息</a>
    <a href="fill.php?id=<?php echo $appID; ?>">2.填入模板配置</a>
    <a href="upload.php?id=<?php echo $appID; ?>">3.绑定素材文件</a>
    <a href="finish.php?id=<?php echo $appID; ?>">4.编译与发布</a>
</div>

<?php
    /*
     * 编译时会自动加入参数$type： 如 CONFIG::apk,true
     */
# 处理编译
$compileSwfCmd = file_get_contents($gen."/compile_swf.txt");
$output = $compileSwfCmd;
$output = str_replace('${gen}',$gen,$output);
$output = str_replace('${AMXMLC}',AMXMLC,$output);
$output = str_replace('${FLEX_HOME}',FLEX_HOME,$output);
$output = str_replace('${debug}',$debug,$output);
$output = str_replace('${ipa}',$isIpa,$output);
$output = str_replace('${apk}',$isApk,$output);
$output = str_replace('${desktop}',$isDesktop,$output);
$output = str_replace('${type}',$type,$output);
$compileOp = execCmd($output,"编译游戏");
$compileSucc = (count($compileOp)>1 && $compileOp[count($compileOp)-1]!="");
if($compileSucc)
{
    //if编译成功:
    # package
    switch($type)
    {
        case 'ipa':
            $genipa = PUBLISH_PATH.'/'.$template.'.ipa';
            $genipaitc = PUBLISH_PATH.'/'.$template.'-iTC.ipa';
            # 处理打包
            if(file_exists($gen."/build_ipa.txt"))
            {
                $buildIpaCmd = file_get_contents($gen."/build_ipa.txt");
                $output = $buildIpaCmd;
                $output = str_replace('${ADT}',ADT_IOS,$output);
                $output = str_replace('${gen}',$gen,$output);
                $output = str_replace('${genipa}',$genipa,$output);
                $output = str_replace('${KEYSTORE_IOS_DEV}',KEYSTORE_IOS_DEV,$output);
                $output = str_replace('${DEVPROVISION}',DEVPROVISION,$output);
                $output = str_replace('${icon}',$icon,$output);
                $output = str_replace('${debug}',$debug,$output);
                execCmd($output,"打包ipa");
                if(file_exists($genipa))
                {
                    echo "<pre>ipa保存在     ".$genipa."\n</pre>";
                    ## 发布ipa-iTC
                    $buildIpaCmd = file_get_contents($gen."/build_ipa_itc.txt");
                    $provision = $gen.'/release.mobileprovision';
                    if(file_exists($provision))
                    {
                        $output = $buildIpaCmd;
                        $output = str_replace('${ADT}',ADT_IOS,$output);
                        $output = str_replace('${gen}',$gen,$output);
                        $output = str_replace('${genipa}',$genipaitc,$output);
                        $output = str_replace('${KEYSTORE_IOS}',KEYSTORE_IOS,$output);
                        $output = str_replace('${PROVISION}',$provision,$output);
                        $output = str_replace('${icon}',$icon,$output);
                        $output = str_replace('${debug}',$debug,$output);
                        execCmd($output,"打包ipa iTC版");
                        echo "<pre>苹果官方版ipa保存在     ".$genipaitc."\n</pre>";
                    }
                    # 尝试安装到iOS设备
                    if($install==1)
                    {
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
                            $installCmd = ADT." -installApp -platform ios -device ".$deviceID." -package ".$genipa;
                            if(!empty($deviceID))
                                execCmd($installCmd);
                        }
                    }
                }else{
                    echo "<pre>ipa保存失败 \n</pre>";
                }
            }else{
                echo "<pre>本项目不支持ipa</pre>";
            }

            break;
        case 'apk':

            $genapk = PUBLISH_PATH.'/'.$template.'.apk';
            # 处理打包
            $buildApkCmd = file_get_contents($gen."/build_apk.txt");
            $output = $buildApkCmd;
            $output = str_replace('${gen}',$gen,$output);
            $output = str_replace('${genapk}',$genapk,$output);
            $output = str_replace('${KEYSTORE}',$KEYSTORE,$output);
            $output = str_replace('${ADT}',ADT,$output);
            $output = str_replace('${icon}',$icon,$output);
            $output = str_replace('${debug}',$debug,$output);
            execCmd($output,"打包apk");

            # 尝试安装到手机
            if($install==1)
                execCmd(FLEX_HOME."/lib/android/bin/adb install -r ".$genapk,"尝试安装到手机");
//            execCmd(APP_ROOT."/util/adb install -r ".$genapk,"尝试安装到手机");

            break;
    }
}else{
    ?>
    <pre>编译主程序失败!</pre>
<?php
}

?>

<h1>4.编译与发布</h1>

<h2>手机版</h2>
<ul>
    <?php
    if($type == 'apk')
    {
        ?>
        <li><a href="build.php?id=<?php echo $appID; ?>&type=ipa">发布ipa</a></li>
        <li><a href="build.php?id=<?php echo $appID; ?>&type=ipa&install=1">发布ipa并安装</a></li>
    <?php
    }
    if ($type == 'ipa')
    {
    ?>
        <li><a href="build.php?id=<?php echo $appID; ?>&type=apk">发布apk</a></li>
        <li><a href="build.php?id=<?php echo $appID; ?>&type=apk&install=1">发布apk并安装</a></li>
    <?php
    }
    ?>
</ul>

<a href="finish.php?id=<?php echo $appID; ?>">返回4.编译与发布</a>

</body>
</html>