<?php
/**
 * 编辑App的数据／配置信息
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/20
 * Time: 8:57
 */
require_once dirname(__FILE__) . "/inc.php";

$appID=input('id');

$autoFillData=readSeedByAppID($appID);


?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>上传素材文件</title>
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


<h1>3.绑定素材文件</h1>
<form action="upload-handle.php" method="post">

    <input name="appID" type="hidden" value="<?php echo $appID; ?>"/>
    <table>
        <?php
        // 列出所有需要的
        $uploadList = getTemplateUploadList($autoFillData['template']);
        // 列出所有已经录入的 在 $autoFillData  key=uploadLi  val=实际文件路径
        foreach ($uploadList as $uploadLi)
        {
            $slashIndex = strrpos($uploadLi , "/");
            if(false === $slashIndex)
            {
                $filename = $uploadLi;
            }
            else $filename = substr($uploadLi,$slashIndex+1);
            $uploadFileKey = str_replace(".","_",$uploadLi);
            ?>
            <tr>
                <td><?php echo $filename; ?></td>
                <td><input type="text" name="<?php echo $uploadFileKey; ?>" id="" style="width:50em;"
                           value="<?php echo $autoFillData[$uploadFileKey]; ?>"/></td>
            </tr>

        <?php
        }
        //额外的 icon
        ?>
        <tr>
            <td>1024.png</td>
            <td><input type="text" name="ico1024" id="" style="width:50em;" value="<?php echo $autoFillData['ico1024']; ?>"/></td>
        </tr>

    </table>

    <input type="submit" value="保存并下一步"/>

</form>
</body>
</html>