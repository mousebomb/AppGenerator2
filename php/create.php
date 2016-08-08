<?php
/**
 * 创建app的表单
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/19
 * Time: 23:47
 */

require_once dirname(__FILE__) . "/inc.php";

?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>创建App种子</title>
    <link rel="stylesheet" href="css/style.css"/>
    <script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>

</head>
<body>

<h1>创建App种子</h1>
<form action="create-handle.php" method="post">

    <table>
        <tr>
            <td>aoaoAppID</td>
            <td><input type="text" name="appID" placeholder="100" value="" class="short" />
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
                        ?>
                        <option value="<?php echo $templateName; ?>"><?php echo $templateName; ?></option>
                        <?php
                    }

                    ?>
                </select>

            </td>
        </tr>
        <tr>
            <td>使用运行壳环境</td>
            <td>
                <select name="runtime" id="runtimeSel" onchange="validateRuntimeDesc();">
                    <?php
                    $filesInRuntimes = scandir(RUNTIMES_ROOT);
                    foreach ($filesInRuntimes as $eachRuntimeFile)
                    {
                        if($eachRuntimeFile == "." || $eachRuntimeFile=="..") continue;
                        if(!is_dir(RUNTIMES_ROOT."/".$eachRuntimeFile)) continue;
                        $runtimeName = $eachRuntimeFile;
                        ?>
                        <option value="<?php echo $runtimeName; ?>"><?php echo $runtimeName; ?></option>
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
                            || P12_ROOT."/".$eachP12 == KEYSTORE_IOS_RHETT
                        ) continue;
                        $isSelected = ($eachP12 == DEFAULT_P12APK_567);
                        ?>
                        <option value="<?php echo $eachP12; ?>" <?php  if($isSelected) echo "selected"; ?>><?php echo $eachP12; ?></option>
                    <?php
                    }

                    ?>
                </select>

            </td>
        </tr>
        <tr>
            <td>签名（苹果）</td>
            <td>
                <label>使用Rhett的
                    <input type="radio" name="p12ios" id="" value="1" <?php  if($autoFillData['p12ios']==1){ echo 'checked';} ?> /></label>
                <label>使用嗷嗷
                    <input type="radio" name="p12ios" id="" value="0" <?php  if($autoFillData['p12ios']!=1){ echo 'checked';} ?>/></label>
            </td>
        </tr>

    </table>

    <input type="submit" value="提交"/>



</form>
<div id="descDiv"></div>
<div id="runtimeDescDiv"></div>


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
    function validateRuntimeDesc()
    {
        var $runtimeSel = document.getElementById("runtimeSel");
        var $descDiv = $("#runtimeDescDiv");
        $descDiv.html("");
        $.get("../AppRuntimes/" + $runtimeSel.value+"/index.html",{},copyRuntimeDesc);
    }
    function copyRuntimeDesc(data ,status)
    {
        var $descDiv = $("#runtimeDescDiv");
        $descDiv.html(data);
    }

    validateDesc();
    validateRuntimeDesc();
</script>

</body>
</html>