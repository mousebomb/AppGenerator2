<?php
/**
 * 将已有的apk重制为各种渠道包
 * Created by PhpStorm.
 * User: rhett
 * Date: 16/7/27
 * Time: 16:55
 */

require_once dirname(__FILE__) . "/inc.php";

$appID=input('id');


$autoFillData=readSeedByAppID($appID);
$template=$autoFillData['template'];
$bundleID = $autoFillData['bundleID'];

# 根据配置读入keystore
$p12Apk= getUserP12OrDefaultP12($autoFillData['p12Apk'],$appID);
$KEYSTORE = P12_ROOT."/".$p12Apk;

// 寻找apk
$srcApk = PUBLISH_PATH."/".$template.".apk";
// 转码url
if ("" != SERVER_CHARSET) {
    $srcApk = iconv("UTF-8", SERVER_CHARSET, $srcApk);
}
?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>转化为各个渠道包</title>
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
if(!file_exists($srcApk))
{
    echo "没有APK:" . $srcApk;
}else{
    echo "处理".$srcApk . "\n";
    $tmpDir = PUBLISH_PATH."/".$template."-apk-channels";
    $dDir = $tmpDir."/d";
    if(file_exists($tmpDir))
    {
        delDirAndFile($tmpDir);
    }
    mkdir($tmpDir);

    // 逆向出apk内容
    execCmd(sprintf("%s/apktool d %s -o %s",UTIL_ROOT,$srcApk,$dDir),"apktool逆向");

    $channels = array('GooglePlay','Appland','SlideMe','Mobango','GetJar','Aptoide');
    foreach($channels as $eachChannel)
    {
        buildChannel($srcApk,$tmpDir."/".$template.'_'.$eachChannel.".apk",$template,$eachChannel,$tmpDir,$dDir);
    }
}
function buildChannel($srcApk,$dstApk,$template,$channel,$tmpDir,$dDir)
{
    # 修改友盟信息
    $inputManifest=file_get_contents($dDir."/AndroidManifest.xml");
    $pattern = '/<meta-data android:name="UMENG_CHANNEL" android:value="([^\"]*)"\/>/';
    $replace = '<meta-data android:name="UMENG_CHANNEL" android:value="'.$channel.'"/>';
    $repCount = 0;
    $opManifest = preg_replace($pattern,$replace,$inputManifest,-1,$repCount);
    if (0==$repCount) {
        die ("XML替换失败\n<br/>");
    }
    file_put_contents($dDir."/AndroidManifest2.xml",$opManifest);

//    return;

    # 打包新apk
    execCmd(sprintf("%s/apktool b %s -o %s",UTIL_ROOT,$dDir,$dstApk),'apktool打包');

    echo("打包完毕，下面开始签名\n<br/>");


# sign
    $signedAPKPath = $dstApk.".signed";
    $cmd = sprintf("jarsigner -verbose  -storetype pkcs12 -keystore %s -STOREPASS %s -signedjar %s %s %s -keypass %s -sigalg SHA1withRSA -digestalg SHA1 "
        ,KEYSTORE
        ,STOREPASS
        ,$signedAPKPath
        ,$dstApk
        ,"1"
        ,STOREPASS
    );
    execCmd($cmd,'jarsigner');

    echo "签名完毕，下面开始对apk进行优化\n<br/>";
    unlink($dstApk);
    execCmd(UTIL_ROOT."/zipalign -v 4 $signedAPKPath $dstApk","zipalign");
    echo "apk  优化完成\n";
    unlink($signedAPKPath);
    echo "Done.结果保存在     ".$dstApk."\n<br/>";
}

?>

</body>
</html>