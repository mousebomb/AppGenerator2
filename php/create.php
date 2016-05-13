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
    <link rel="stylesheet" href="css/general.css"/>
    <link rel="stylesheet" href="css/extra.css"/>

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
                <select name="template" id="">
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
                        $isSelected = ($eachP12 == DEFAULT_P12APK_567);
                        ?>
                        <option value="<?php echo $eachP12; ?>" <?php  if($isSelected) echo "selected"; ?>><?php echo $eachP12; ?></option>
                    <?php
                    }

                    ?>
                </select>

            </td>
        </tr>

    </table>

    <input type="submit" value="提交"/>



</form>

</body>
</html>