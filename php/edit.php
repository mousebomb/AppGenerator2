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

$autoFillData= readSeedByAppID($appID);


?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>编辑App数据</title>
    <script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>
    <link rel="stylesheet" href="css/style.css"/>

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

<h1>1.基本信息</h1>
<form action="create-handle.php" method="post">

    <table>
        <tr>
            <td>aoaoAppID</td>
            <td>
                <input type="text" value="<?php echo $appID; ?>" disabled="disabled" class="short" />
                <input type="hidden" name="appID"  value="<?php echo $appID; ?>"  />
                <small>嗷嗷平台上申请的唯一id，统计、带量、广告管理都用</small>
            </td>
        </tr>
        <tr>
            <td>名字</td>
            <td><input type="text" name="zhName" placeholder="水果三消大师" value="<?php echo $autoFillData['zhName']; ?>" /></td>
        </tr>
        <tr>
            <td>使用模板</td>
            <td>
                <select name="template" id="templateSel" onchange="validateDesc();">
                    <?php
                    $filesInTemplates = scandir(TEMPLATES_ROOT);
                    foreach ($filesInTemplates as $eachTemplateFolder)
                    {
                        if($eachTemplateFolder == "." || $eachTemplateFolder=="..") continue;
                        if(!is_dir(TEMPLATES_ROOT."/".$eachTemplateFolder)) continue;
                        $templateName = $eachTemplateFolder;
                        $isSelected = $eachTemplateFolder == $autoFillData['template'];
                        ?>
                        <option value="<?php echo $templateName; ?>" <?php  if($isSelected) echo "selected"; ?>><?php echo $templateName; ?></option>
                    <?php
                    }

                    ?>
                </select>

            </td>
        </tr>
        <tr>
            <td>使用签名（安卓）</td>
            <td>
                <select name="p12Apk" id="p12ApkSel" >
                    <?php
                    $p12sInFolder = scandir(P12_ROOT);
                    foreach ($p12sInFolder as $eachP12)
                    {
                        if($eachP12 == "." || $eachP12=="..") continue;
                        if(is_dir(P12_ROOT."/".$eachP12)) continue;
                        $pointIndex = strrpos($eachP12,".");
                        $basename=substr($eachP12,0,$pointIndex);
                        $extname=substr($eachP12,$pointIndex);
                        if($extname != '.p12') continue;
                        if( P12_ROOT."/".$eachP12 == KEYSTORE_IOS
                            || P12_ROOT."/".$eachP12 == KEYSTORE_IOS_DEV
                        ) continue;
                        $isSelected = ($eachP12 == getUserP12OrDefaultP12($autoFillData['p12Apk'],$appID));
                        ?>
                        <option value="<?php echo $eachP12; ?>" <?php  if($isSelected) echo "selected"; ?>><?php echo $eachP12; ?></option>
                    <?php
                    }

                    ?>
                </select>

            </td>
        </tr>

    </table>

    <input type="submit" value="保存并下一步"/>



</form>
<div id="descDiv">

</div>


<script type="text/javascript">
    function validateDesc()
    {
        var $templateSel = document.getElementById("templateSel");
        var $descDiv = $("#descDiv");
        $descDiv.html("");
        $.get("../AppTemplates/" + $templateSel.value+"/index.html",{},copyDesc);
    }
    function copyDesc(data ,status)
    {
        var $descDiv = $("#descDiv");
        $descDiv.html(data);
    }

    validateDesc();
</script>

</body>
</html>