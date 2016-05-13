<?php
/**
 * 列出目录下 已经有种子的项目
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/19
 * Time: 22:44
 */
require_once dirname(__FILE__) . "/inc.php";

?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Aoao游戏创建工具</title>
    <link rel="stylesheet" href="css/style.css"/>
    <link rel="stylesheet" href="css/general.css"/>
    <link rel="stylesheet" href="css/extra.css"/>

</head>
<body>


<form action="" id="form2">
    <h2>App列表</h2>


    <?php
    $foldersInPublish = scandir(GENERATOED_ROOT);
    foreach ($foldersInPublish as $folder) {
        if ($folder == "." || $folder == "..") continue;
        if (is_dir(GENERATOED_ROOT . "/" . $folder)) {
            $projectOutFolder = GENERATOED_ROOT . "/" . $folder;
            $seedFile = $projectOutFolder."/_vars.inf";
            if(file_exists($seedFile))
            {
                $autoFillData = readSeed($seedFile);
                $appID = $autoFillData['appID'];
                $appName = $autoFillData['zhName'];
                echo sprintf('<a href="edit.php?id=%d">%d : %s (%s)</a><br/>', $appID, $appID,$appName,$autoFillData['template']);
            }

        }


    }

    ?>
</form>

<a href="create.php">创建新App</a>
<a href="install.php">安装App</a>

</body>
</html>