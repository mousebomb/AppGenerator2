<?php
/**
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/20
 * Time: 22:20
 */
require_once dirname(__FILE__) . "/inc.php";

$appID=input('id');

$autoFillData=readSeedByAppID($appID);


?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>填入模板配置</title>
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


<h1>2.填入模板配置</h1>
<form action="fill-handle.php" method="post">

    <input name="appID" type="hidden" value="<?php echo $appID; ?>"/>
    <table>
        <?php
        $fillvarsList = getTemplateFillvarsList($autoFillData['template']);

        foreach ($fillvarsList as $eachKey => $eachVO)
        {
            $eachLabel = $eachVO['label'];
            $eachPlaceholder    =$eachVO['placeholder'];
?>
            <tr>
                <td><?php echo $eachLabel; ?></td>
                <td><input type="text" name="<?php echo $eachKey; ?>" placeholder="如：<?php echo $eachPlaceholder; ?>"
                           id="" value="<?php echo $autoFillData[$eachKey]; ?>" /></td>
            </tr>

        <?php
        }


        ?>
        <tr>
            <td></td>
            <td><a href="forpic.php" target="_blank">Pic生成器</a></td>
        </tr>
    </table>


    <input type="submit" value="保存并下一步"/>

</form>
</body>
</html>