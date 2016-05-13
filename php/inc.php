<?php
/**
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/19
 * Time: 20:32
 */

date_default_timezone_set("PRC");
mb_internal_encoding("UTF-8");
error_reporting(E_ALL ^ E_NOTICE);

# 需要配置 系统 android SDK,JAVA

#如果亂碼 改這裡
define("SERVER_CHARSET","");


// 是否windows，以后做windows兼容性时候用
if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN')
    define("IS_WIN",true);
else
    define("IS_WIN",false);

# 项目路径
define("APP_ROOT",dirname(dirname(__FILE__)));
define("PHP_ROOT",dirname(__FILE__));
define("GENERATOED_ROOT",APP_ROOT."/Generated");
define("TEMPLATES_ROOT",APP_ROOT."/AppTemplates");
define("P12_ROOT",APP_ROOT."/p12");

require_once(PHP_ROOT.'/inc.conf.php');
# SDK路径
define("AIR_SDK_HOME",FLEX_HOME);
define("ADL",FLEX_HOME."/bin/adl");
define("ADT_JAR",FLEX_HOME."/lib/adt.jar");
define("ADT",FLEX_HOME."/bin/adt");
define("AMXMLC",FLEX_HOME."/bin/amxmlc");
define("ADT_IOS",FLEX_HOME_IOS."/bin/adt");

# android p12
define("DEFAULT_P12APK","MousebombAndroid.p12");
define("DEFAULT_P12APK_567","a567.p12");
define("KEYSTORE",P12_ROOT."/".DEFAULT_P12APK);
define("KEYSTORE_567",P12_ROOT."/".DEFAULT_P12APK_567);
# ios p12
define("KEYSTORE_IOS",P12_ROOT."/aoaogame_release.p12");
define("KEYSTORE_IOS_DEV",P12_ROOT."/aoaogame_develop.p12");
define("DEVPROVISION",P12_ROOT."/aoaoDev.mobileprovision");
define("STOREPASS","ilikeasp");
define("STOREPASS_IOS","aoaogame");

#打包baidu apk
define("WORK_FOLDER",APP_ROOT."/packBaiduAPK");
define("KEYSTORE_PATH",WORK_FOLDER."/android.keystore");
define("KEYSTORE_ALIAS","1");
define("KEYSTORE_STOREPASS","ilikeasp");
define("KEYSTORE_KEYPASS","ilikeasp");



// 递归拷贝文件
include_once(PHP_ROOT."/CopyFile.php");
include_once(PHP_ROOT."/functions.php");

//循环删除目录和文件函数
function delDirAndFile( $dirName )
{
    if ( $handle = opendir( "$dirName" ) ) {
        while ( false !== ( $item = readdir( $handle ) ) ) {
            if ( $item != "." && $item != ".." ) {
                if ( is_dir( "$dirName/$item" ) ) {
                    delDirAndFile( "$dirName/$item" );
                } else {
                    unlink( "$dirName/$item" ) ;
                }
            }
        }
        closedir( $handle );
        rmdir( $dirName );
    }
}
/*
 * 递归创建文件夹
 */
function CreateFolder($dir, $mode = 0777){
    if (is_dir($dir) || @mkdir($dir,$mode)){
        return true;
    }
    if (!CreateFolder(dirname($dir),$mode)){
        return false;
    }
    return @mkdir($dir, $mode);
}

// 输出执行
function execCmd($cmd,$title="")
{
    $cmd = str_replace("\n",' ',$cmd);
    $cmd = str_replace("\r",' ',$cmd);
    echo( date("H:i:s")." 执行 $title <pre> $cmd </pre>");
    exec($cmd,$op);
    echo (/*date("H:i:s").*/" &nbsp;&nbsp;&nbsp;&nbsp; $title 结果: "."<pre>");
    foreach($op as $opLine)
    {
        echo $opLine."\n";
    }
    echo "</pre>";
    return $op;
}

# 根据用户填入的或留空的p12返回真正的p12  ; ONLY FILENAME , NOT the PATH
function getUserP12OrDefaultP12($p12ApkInFillData,$appID)
{
    $p12Apk = $p12ApkInFillData;
    if(empty($p12Apk))
    {
        # 不同ID段不同默认keystore
        if($appID>=567)
            return DEFAULT_P12APK_567;
        else
            return DEFAULT_P12APK;
    }else{
        # 用用户选择的keystore
        return $p12Apk;
    }
}
# 读取种子； 获得Gen目录下的inf记录的数据(Array)，已经存入的数据;
function readSeedByAppID($appID)
{
    $toFile = GENERATOED_ROOT."/app".$appID."/_vars.inf";
    return readSeed($toFile);
}
function readSeed($seedFile)
{
    $autoFillData=array();
    $orginData = file_get_contents($seedFile);
    $printrPatten = '/\[(.*)\] => (.*)\n/';
    $matchResult = array();
    preg_match_all($printrPatten,$orginData,$matchResult);

    foreach ($matchResult[1] as $index => $eachMathKey) {

        $autoFillData[$eachMathKey] = $matchResult[2][$index];
    }
    return $autoFillData;
}
#写入种子
function writeSeed($inputDataArr,$toFile)
{
    // 合并输入的字段和已有seed内的字段
    if(file_exists($toFile))
    {
        $autoFillData = readSeed($toFile);
        $out = array_merge($autoFillData,$inputDataArr);
    }else{
        $out = $inputDataArr;
    }
    $out =     print_r($out,true);
    file_put_contents( $toFile,$out);
}
function writeSeedByAppID($inputDataArr,$appID)
{
    $toFile = GENERATOED_ROOT."/app".$appID."/_vars.inf";
    writeSeed($inputDataArr,$toFile);
}

/**
 * 获得app模板 需要上传的列表
 * @param $template String 模板名
 */
function getTemplateUploadList($template)
{
    return getTemplateSetting($template,'uploadlist');
}
function getTemplateReplaceList($template)
{
    return getTemplateSetting($template,'replacelist');
}
// 数组
function getTemplateSetting($template,$settingName)
{
    $end = array();
    $templateUploadListFile = TEMPLATES_ROOT."/".$template."/$settingName.txt";
    $uploadListTxt = file_get_contents($templateUploadListFile);
    $uploadListArr = explode("\n",$uploadListTxt);
    foreach ($uploadListArr as $eachUploadLi)
    {
        if(substr($eachUploadLi,0,1) == "#") continue;
        $end[] = $eachUploadLi;
    }
    return $end;
}

/**
 * KVPair  v:placeholder
 * @param $template
 * @return array
 */
function getTemplateFillvarsList($template)
{
    $end = array();
    $templateUploadListFile = TEMPLATES_ROOT."/".$template."/fillvars.txt";
    $uploadListTxt = file_get_contents($templateUploadListFile);
    $uploadListArr = explode("\n",$uploadListTxt);
    foreach ($uploadListArr as $eachUploadLi)
    {
        if(substr($eachUploadLi,0,1) == "#") continue;
        $index1 = strpos($eachUploadLi,":");
        $index2 = strpos($eachUploadLi,"=");
        $label = substr($eachUploadLi,0,$index1);
        $key = substr($eachUploadLi,$index1+1,$index2-$index1-1);
        $placeholder = substr($eachUploadLi,$index2+1);
        if($label == "") $label = $key;
        $end[$key] = array('label'=>$label,'placeholder'=>$placeholder);
    }
    return $end;
}

/**
 * 图片resize
 * @param        $file
 * @param int    $width
 * @param int    $height
 * @param bool   $proportional
 * @param string $output
 * @param bool   $delete_original
 * @param bool   $use_linux_commands
 *
 * @return bool|resource
 */
function smart_resize_image( $file, $width = 0, $height = 0, $proportional = false, $output = 'file', $delete_original = false, $use_linux_commands = false )
{
    if ( $height <= 0 && $width <= 0 ) {
        return false;
    }
    $info = getimagesize($file);
    $image = '';

    $final_width = 0;
    $final_height = 0;
    list($width_old, $height_old) = $info;

    if ($proportional) {
        if ($width == 0) $factor = $height/$height_old;
        elseif ($height == 0) $factor = $width/$width_old;
        else $factor = min ( $width / $width_old, $height / $height_old);
        $final_width = round ($width_old * $factor);
        $final_height = round ($height_old * $factor);

    }
    else {
        $final_width = ( $width <= 0 ) ? $width_old : $width;
        $final_height = ( $height <= 0 ) ? $height_old : $height;
    }

    switch ($info[2] ) {
        case IMAGETYPE_GIF:
            $image = imagecreatefromgif($file);
            break;
        case IMAGETYPE_JPEG:
            $image = imagecreatefromjpeg($file);
            break;
        case IMAGETYPE_PNG:
            $image = imagecreatefrompng($file);
            break;
        default:
            return false;
    }

    $image_resized = imagecreatetruecolor( $final_width, $final_height );

    if ( ($info[2] == IMAGETYPE_GIF) || ($info[2] == IMAGETYPE_PNG) ) {
        $trnprt_indx = imagecolortransparent($image);
        // If we have a specific transparent color
        if ($trnprt_indx >= 0) {
            // Get the original image's transparent color's RGB values
            $trnprt_color    = imagecolorsforindex($image, $trnprt_indx);
            // Allocate the same color in the new image resource
            $trnprt_indx    = imagecolorallocate($image_resized, $trnprt_color['red'], $trnprt_color['green'], $trnprt_color['blue']);
            // Completely fill the background of the new image with allocated color.
            imagefill($image_resized, 0, 0, $trnprt_indx);
            // Set the background color for new image to transparent
            imagecolortransparent($image_resized, $trnprt_indx);
        }
        // Always make a transparent background color for PNGs that don't have one allocated already
        elseif ($info[2] == IMAGETYPE_PNG) {
            // Turn off transparency blending (temporarily)
            imagealphablending($image_resized, false);
            // Create a new transparent color for image
            $color = imagecolorallocatealpha($image_resized, 0, 0, 0, 127);

            // Completely fill the background of the new image with allocated color.
            imagefill($image_resized, 0, 0, $color);

            // Restore transparency blending
            imagesavealpha($image_resized, true);
        }
    }

    imagecopyresampled($image_resized, $image, 0, 0, 0, 0, $final_width, $final_height, $width_old, $height_old);

    if ( $delete_original ) {
        if ( $use_linux_commands )
            exec('rm '.$file);
        else
            @unlink($file);
    }

    switch ( strtolower($output) ) {
        case 'browser':
            $mime = image_type_to_mime_type($info[2]);
            header("Content-type: $mime");
            $output = NULL;
            break;
        case 'file':
            $output = $file;
            break;
        case 'return':
            return $image_resized;
            break;
        default:
            break;
    }

    switch ($info[2] ) {
        case IMAGETYPE_GIF:
            imagegif($image_resized, $output);
            break;
        case IMAGETYPE_JPEG:
            imagejpeg($image_resized, $output);
            break;
        case IMAGETYPE_PNG:
            imagepng($image_resized, $output);
            break;
        default:
            return false;
    }

    return true;
}





/**
 * 删除目录下的文件以及子目录
 * #param  string $path 路径
 * #return string 删除成功返回true 失败返回false;
 */
function dirDel($path){
    if(!is_dir($path)){
        throw new Exception($path."输入的不是有效目录");
    }
    $hand = opendir($path);
    while(($file = readdir($hand))!==false){
        if($file=="."||$file=="..")  continue;
        if(is_dir($path."/".$file)){
            dirDel($path."/".$file);
        }else{
            @unlink($path."/".$file);
        }

    }
    closedir($hand);
    @rmdir($path);
}
// 搜索apk原始文件
function findAPK($srcFolderPath)
{
    $filesInSrcPath = scandir($srcFolderPath);
    foreach ($filesInSrcPath as $srcFile) {
        $srcApkFilePath = $srcFolderPath . "/" . $srcFile;
        if ($srcFile == "." || $srcFile == '..' || is_dir($srcApkFilePath)) {
            continue;
        }
        $arr = explode(".",$srcFile);
        $basename = basename($srcFile);
        $ext = $arr[ count($arr) - 1 ];
        if(strtolower($ext) =="apk"  && substr($basename,0,1) != ".")
        {
            return $srcApkFilePath;
        }
    }
    return null;
}
function listdir($start_dir='.') {
    $files = array();
    if (is_dir($start_dir)) {
        $fh = opendir($start_dir);
        while (($file = readdir($fh)) !== false) {
            if (strcmp($file, '.')==0 || strcmp($file, '..')==0) continue;
            $filepath = $start_dir . '/' . $file;
            if ( is_dir($filepath) )
                $files = array_merge($files, listdir($filepath));
            else
                array_push($files, $filepath);
        }
        closedir($fh);
    } else {
        echo "$start_dir is not a dir\n";
        $files = false;
    }
    return $files;
}
