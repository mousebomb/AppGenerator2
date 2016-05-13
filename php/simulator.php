<?php
/**
 * 桌面模拟机测试
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/19
 * Time: 20:01
 */

require_once dirname(__FILE__) . "/inc.php";

$appID=input('id');
$size=input('size');
    if(empty($size))
    {
        die('size 为空');
    }
    switch($size)
    {
        case 'iphone4':
        case 'iphone4h':
            $screensize = '640x920:640x960';
            break;
        case 'iphone5':
        case 'iphone5h':
            $screensize = '640x1096:640x1136';
            break;
        case 'ipad':
        case 'ipadh':
            $screensize = '768x1004:768x1024';
            break;
    }

$autoFillData=readSeedByAppID($appID);
$template=$autoFillData['template'];
$bundleID = $autoFillData['bundleID'];

#gen Folder
$templ = TEMPLATES_ROOT."/".$template;
$gen = GENERATOED_ROOT."/app".$appID;
$icon = $gen."/icon";

$type = 'desktop';
$debug = 'true';
$isIpa= 'false';
$isApk= 'false';
$isDesktop= 'true';

?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>模拟器执行</title>
    <link rel="stylesheet" href="css/style.css"/>
    <link rel="stylesheet" href="css/general.css"/>
    <link rel="stylesheet" href="css/extra.css"/>

</head>
<body>

<div id="project-menu">
    <?php echo $autoFillData['zhName']; ?>
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
    //if编译成功
    # 执行ADL
    $runDesktopCmd = file_get_contents($gen."/simulator.txt");
    $output = $runDesktopCmd;
    $output = str_replace('${gen}',$gen,$output);
    $output = str_replace('${ADL}',ADL,$output);
    $output = str_replace('${screensize}',$screensize,$output);
    execCmd($output,"执行桌面模拟");
}else{
    ?>
<pre>编译主程序失败!</pre>
<?php
}


?>
<h1>4.编译与发布</h1>

<h2>桌面测试</h2>
<ul>
    <li><a href="simulator.php?id=<?php echo $appID; ?>&size=iphone4h"> 模拟iPhone4
            (3:2)</a>
    </li>
    <li><a href="simulator.php?id=<?php echo $appID; ?>&size=iphone5h">模拟iPhone5
            (16:9)</a>
    </li>
    <li><a href="simulator.php?id=<?php echo $appID; ?>&size=ipadh">模拟iPad/miPad
            (4:3)</a>
    </li>
</ul>

<a href="finish.php?id=<?php echo $appID; ?>">返回4.编译与发布</a>

</body>
</html>