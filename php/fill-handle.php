<?php
/**
 * 处理创建,合并入种子信息 _vars.inf
 * 处理编辑，合并入种子信息
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/21
 * Time: 10:39
 */

require_once dirname(__FILE__) . "/inc.php";

$appID = input('appID');
$zhName = input('zhName');

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

    header("location:./upload.php?id=".$appID);
    die();
?>