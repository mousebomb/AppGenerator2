<?php
/**
 * 桌面测试
 * 发布apk / ipa / ipa-iTC
 * Created by PhpStorm.
 * User: rhett
 * Modified: 2016-5-13
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
    <?php echo $autoFillData['zhName'] . "(".$autoFillData['template']." + ".$autoFillData['runtime'].")"; ?>
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
     * 这里编译不是桌面调试，需要加密，做壳
     */
# 处理编译GRLib
$compileSwfCmd = file_get_contents($gen."/compile_grlib.txt");
$output = $compileSwfCmd;
$output = str_replace('${gen}',$gen,$output);
$output = str_replace('${AMXMLC}',AMXMLC,$output);
$output = str_replace('${FLEX_HOME}',FLEX_HOME,$output);
$output = str_replace('${debug}',$debug,$output);
$output = str_replace('${ipa}',$isIpa,$output);
$output = str_replace('${apk}',$isApk,$output);
$output = str_replace('${desktop}',$isDesktop,$output);
$output = str_replace('${type}',$type,$output);
$compileOp = execCmd($output,"编译运行壳环境");
$compileSucc = (count($compileOp)>1 && $compileOp[count($compileOp)-1]!="");
if(!$compileSucc)
{
    echo  '<pre>编译运行壳环境失败!</pre>';
}else {
    # 处理编译
    $compileSwfCmd = file_get_contents($gen . "/compile_swf.txt");
    $output = $compileSwfCmd;
    $output = str_replace('${gen}', $gen, $output);
    $output = str_replace('${AMXMLC}', AMXMLC, $output);
    $output = str_replace('${FLEX_HOME}', FLEX_HOME, $output);
    $output = str_replace('${debug}', $debug, $output);
    $output = str_replace('${ipa}', $isIpa, $output);
    $output = str_replace('${apk}', $isApk, $output);
    $output = str_replace('${desktop}', $isDesktop, $output);
    $output = str_replace('${type}', $type, $output);
    $output = str_replace('${main.swf}', MAIN_SWF, $output);
    $compileOp = execCmd($output, "编译游戏");
    $compileSucc = (count($compileOp) > 1 && $compileOp[count($compileOp) - 1] != "");
    if ($compileSucc) {
        //if编译成功:
        # 加密
        if($type == 'ipa')
        {
            $encKey = ENCKEY_IOS;
        }else{
            $encKey = getEncKeyForP12($p12Apk);
        }
        echo( date("H:i:s")." 执行 加密 ".MAIN_SWF."  > ".MAIN_DAT."<pre>\n");
        encryptSwf($gen."/".MAIN_SWF,$gen."/".MAIN_DAT,$encKey);
        echo "</pre>";
        echo( date("H:i:s")." 执行 加密 ".GRLIB_SWF." > ".GRLIB_DAT."<pre>\n");
        encryptSwf($gen."/".GRLIB_SWF,$gen."/".GRLIB_DAT,$encKey);
        echo "</pre>";

        # package
        $buildAddtionalCmd = file_get_contents($templ . "/build_additional.txt");
        switch ($type) {
            case 'ipa':
                $genipa = PUBLISH_PATH . '/' . $template . '.ipa';
                $genipaitc = PUBLISH_PATH . '/' . $template . '-iTC.ipa';
                if(file_exists($genipa)) unlink($genipa);
                if(file_exists($genipaitc)) unlink($genipaitc);
                # 处理打包
                if (file_exists($gen . "/build_ipa.txt")) {
                    $buildIpaCmd = file_get_contents($gen . "/build_ipa.txt");
                    $output = $buildIpaCmd ." ".$buildAddtionalCmd;
                    $output = str_replace('${ADT}', ADT_IOS, $output);
                    $output = str_replace('${gen}', $gen, $output);
                    $output = str_replace('${genipa}', $genipa, $output);
                    $output = str_replace('${KEYSTORE_IOS_DEV}', KEYSTORE_IOS_DEV, $output);
                    $output = str_replace('${p12pass}', STOREPASS_IOS_AOAO, $output);
                    $output = str_replace('${DEVPROVISION}', DEVPROVISION, $output);
                    $output = str_replace('${icon}', $icon, $output);
                    $output = str_replace('${debug}', $debug, $output);
                    execCmd($output, "打包ipa");
                    if (file_exists($genipa)) {
                        echo "<pre>ipa保存在     " . $genipa . "\n</pre>";
                        ## 发布ipa-iTC
                        if($autoFillData['p12ios']==1)
                        {
                            $keystoreIOS = KEYSTORE_IOS_RHETT;
                            $p12Pass = STOREPASS_IOS_RHETT;
                        }else{
                            $keystoreIOS = KEYSTORE_IOS;
                            $p12Pass = STOREPASS_IOS_AOAO;
                        }
                        $buildIpaCmd = file_get_contents($gen . "/build_ipa_itc.txt");
                        $provision = $gen . '/release.mobileprovision';
                        if (file_exists($provision)) {
                            $output = $buildIpaCmd." ".$buildAddtionalCmd;
                            $output = str_replace('${ADT}', ADT_IOS, $output);
                            $output = str_replace('${gen}', $gen, $output);
                            $output = str_replace('${genipa}', $genipaitc, $output);
                            $output = str_replace('${KEYSTORE_IOS}', $keystoreIOS, $output);
                            $output = str_replace('${p12pass}', $p12Pass, $output);
                            $output = str_replace('${PROVISION}', $provision, $output);
                            $output = str_replace('${icon}', $icon, $output);
                            $output = str_replace('${debug}', $debug, $output);
                            execCmd($output, "打包ipa iTC版");
                            echo "<pre>苹果官方版ipa保存在     " . $genipaitc . "\n</pre>";
                        }
                        # 尝试安装到iOS设备
                        if ($install == 1) {
                            $chkIOSDeviceCmd = ADT . "  -devices -platform iOS";

                            $op = execCmd(ADT . "  -devices -platform iOS", "查找iOS设备");

                            if (empty($op[2])) {
                                echo("<pre>无法发现ios设备</pre>");
                            } else {
                                //有iOS设备
                                $deviceRawData = $op[2];
                                $tabIndex = strpos($deviceRawData, "\t");
                                $deviceID = substr($deviceRawData, 0, $tabIndex);
                                echo("<pre>已发现iOS设备" . $deviceID . "</pre>");
                                $uninstallCmd = ADT . " -uninstallApp -platform ios -device " . $deviceID . " -appid " . $autoFillData['buneleID'];
                                $installCmd = ADT . " -installApp -platform ios -device " . $deviceID . " -package " . $genipa;
                                if (!empty($deviceID)) {
                                    exec($uninstallCmd);
                                    execCmd($installCmd,"安装到手机");
                                }
                            }
                        }
                    } else {
                        echo "<pre>ipa保存失败 \n</pre>";
                    }
                } else {
                    echo "<pre>本项目不支持ipa</pre>";
                }

                break;
            case 'apk':

                $genapk = PUBLISH_PATH . '/' . $template . '.apk';
                if(file_exists($genapk)) unlink($genapk);
                # 处理打包
                $buildApkCmd = file_get_contents($gen . "/build_apk.txt");
                $output = $buildApkCmd." ".$buildAddtionalCmd;
                $output = str_replace('${gen}', $gen, $output);
                $output = str_replace('${genapk}', $genapk, $output);
                $output = str_replace('${KEYSTORE}', $KEYSTORE, $output);
                $output = str_replace('${ADT}', ADT, $output);
                $output = str_replace('${icon}', $icon, $output);
                $output = str_replace('${debug}', $debug, $output);
                execCmd($output, "打包apk");

                # 尝试安装到手机
                if ($install == 1) {
                    exec(FLEX_HOME . "/lib/android/bin/adb uninstall "." air." . $autoFillData['buneleID']);
                    exec(FLEX_HOME . "/lib/android/bin/adb uninstall ". $autoFillData['buneleID']);
                    execCmd(FLEX_HOME . "/lib/android/bin/adb install -r " . $genapk, "尝试安装到手机");
                    //            execCmd(APP_ROOT."/util/adb install -r ".$genapk,"尝试安装到手机");
                }
                echo '<p> <a href="channels.php?id='.$appID.'">转化为各个渠道包</a> </p>';
                break;
        }
    } else {
        echo  '<pre>编译主程序失败!</pre>';
    }
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