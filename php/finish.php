<?php
/**
 * 填写数据完毕
 * 替换内容，检测上传的内容是否完整，编译swf 让玩家开始打包
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/21
 * Time: 12:08
 */
require_once dirname(__FILE__) . "/inc.php";

$appID=input('id');

$autoFillData=readSeedByAppID($appID);

$template=$autoFillData['template'];

#gen Folder
$aslib = APP_ROOT."/aslib";
$templ = TEMPLATES_ROOT."/".$template;
$gen = GENERATOED_ROOT."/app".$appID;
$icon = $gen."/icon";
@mkdir($icon);
//assets目录 目前定死会自动添加,应该是检测uploadlist
$assets = $gen."/assets";
$lib = $gen."/lib";
$src = $gen."/src";
$src2 = $gen."/src_adsaoao";
@mkdir($assets);
// 如果有lib 先删除
if(file_exists($lib) && is_dir($lib))
{
    delDirAndFile($lib);
}
// 如果有代码，先删除
if(file_exists($src) && is_dir($src))
{
    delDirAndFile($src);
}
if(file_exists($src2) && is_dir($src2))
{
    delDirAndFile($src2);
}

new CopyFile($templ,$gen);
new CopyFile($aslib,$lib);

//  替换内容 replacelist.txt ，检测上传的内容 uploadlist.txt 是否完整

# 替换replacelist.txt 要求的内容
    $replaceList = getTemplateReplaceList($template);
    foreach ($replaceList as $eachReplaceFile)
    {
        $output = file_get_contents($templ."/".$eachReplaceFile);
        // 遍历 从填入的配置 替换到文件
        foreach ($autoFillData as $autoFillKey => $autoFillVal)
        {
            $search = sprintf('${%s}',$autoFillKey);
            $output = str_replace($search,$autoFillVal,$output);
        }
        // 替换好的文本，存入gen下的路径
        file_put_contents($gen."/".$eachReplaceFile,$output);
    }

# 检测上传的内容
    $uploadList = getTemplateUploadList($template);
    // 列出所有已经录入的 在 $autoFillData  key=uploadLi  val=实际文件路径
    foreach ($uploadList as $uploadLi)
    {
        $uploadFileKey = str_replace(".","_",$uploadLi);
        $fromFile = $autoFillData[$uploadFileKey];
        if(strpos($uploadLi,'..') !== false  || $gen == '')
        {
            die("上传地址有误");
        }
        $toFile = $gen."/".$uploadLi;
        // 如果没有录入要传的文件，则跳过 即不覆盖模板的
        if($fromFile=="") continue;
        if(file_exists($toFile))
        {
            // 模板里已存在的
            if(is_dir($toFile))
            {
                // 文件夹覆盖
                delDirAndFile($toFile);
            }else{
                unlink($toFile);
            }
        }
        if(is_dir($fromFile))
        {
            new CopyFile($fromFile,$toFile);
        }else{
            copy($fromFile, $toFile);
        }
    }
# Icon 1024生成各种
    $input1024Png = $autoFillData['ico1024'];

    $saveFolderPath = $srcFolderPath;
    @mkdir($saveFolderPath);

    // 生成各个平台尺寸 App Icon
    $iconSet = array(
        29, 40, 50, 57, 58, 60, 72, 76, 80, 100, 114, 120, 144, 152 ,512,1024
        //android
        ,36, 48, 72, 96,144, 512
        // 小米
        ,90, 136, 168, 192
        // 腾讯
        ,16
        // 联想
        ,256
    );

    if(!empty($input1024Png))
    {
        foreach ($iconSet as $iconSize) {
            $eachImagePath = $icon . "/".$iconSize . ".png";
            smart_resize_image($input1024Png, $iconSize, $iconSize, false, $eachImagePath);
        }
    }

?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>编译与发布</title>
    <link rel="stylesheet" href="css/style.css"/>
    <link rel="stylesheet" href="css/general.css"/>
    <link rel="stylesheet" href="css/extra.css"/>

</head>
<body>
<div id="project-menu">
    <?php echo $autoFillData['zhName']. "(".$autoFillData['template'].")"; ?>
    <a href="./create.php">创建新App</a>
    <a href="./list.php">App列表</a>
</div>
<div id="main-menu">
    <a href="edit.php?id=<?php echo $appID; ?>">1.基本信息</a>
    <a href="fill.php?id=<?php echo $appID; ?>">2.填入模板配置</a>
    <a href="upload.php?id=<?php echo $appID; ?>">3.绑定素材文件</a>
    <a href="finish.php?id=<?php echo $appID; ?>">4.编译与发布</a>
</div>


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
<h2>手机版</h2>
<ul>
<?php
    if(!empty($input1024Png)){
?>
    <li><a href="build.php?id=<?php echo $appID; ?>&type=ipa">发布ipa</a></li>
    <li><a href="build.php?id=<?php echo $appID; ?>&type=ipa&install=1">发布ipa并安装</a></li>
    <li><a href="build.php?id=<?php echo $appID; ?>&type=apk">发布apk</a></li>
    <li><a href="build.php?id=<?php echo $appID; ?>&type=apk&install=1">发布apk并安装</a></li>
<?php }else{
    ?>
    <li><a href="upload.php?id=<?php echo $appID; ?>">需要先提交Icon</a></li>
<?php
} ?>
</ul>

<p>提示：如果绑定的素材文件有改动，请先刷新本页面(重新加载素材)再测试或发布</p>


</body>
</html>