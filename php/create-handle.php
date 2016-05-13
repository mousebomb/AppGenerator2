<?php
/**
 * 处理创建,写入种子信息 _vars.inf
 * 处理编辑，覆盖种子信息
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/19
 * Time: 23:47
 */

require_once dirname(__FILE__) . "/inc.php";

$appID = input('appID');
$zhName = input('zhName');
$enName = input('enName');

$iosBuneleID = input('iosBuneleID');
$iosAdmobBanner = input('iosAdmobBanner');
$iosAdmobInterstitial = input('iosAdmobInterstitial');
$iosUMeng = input('iosUMeng');

$androidBuneleID = input('androidBuneleID');
$androidUMeng = input('androidUMeng');
$iosBaiduAd=input('iosBaiduAd');
$androidBaiduAd=input('androidBaiduAd');

#计算得出
## org/mousebomb/gameXX
$androidBundleNamespace = str_replace(".", '/', $androidBuneleID);
## gameXX
//$tmp = explode(".", $androidBuneleID);
//$projectName = $tmp[count($tmp) - 1];
$projectName = 'app'.$appID;
if($appID == "")
{
    die("AppID，路径不可以为空");
}
## 输出路径
$projectOutFolder = GENERATOED_ROOT . '/' . $projectName;
@mkdir($projectOutFolder);


# 名称
    // 如果已经有名称，则删除
$filesInOpFolder = scandir($projectOutFolder);
$seedFilePattern = '(_(.*)_)';
foreach($filesInOpFolder as $file)
{
    if( preg_match($seedFilePattern,$file) > 0)
    {
        unlink($projectOutFolder.'/'.$file);
        break;
    }
}
    // 写入
touch($projectOutFolder."/_".$zhName."_");

#写入种子
writeSeed($_POST,$projectOutFolder . "/_vars.inf");

    header("location:./fill.php?id=".$appID);
    die();
?>