<?php
/*
 * 文件夹复制类，
 * 赵春 2012年6月14日17:20:30
 * 博客：www.zhaochun.net
 */
class CopyFile
{
    public $fromFile;
    public $toFile;
    /*
     * $fromFile  要复制谁
     * $toFile    复制到那
     */
    function copyFile($fromFile,$toFile){
        $this->CreateFolder($toFile);
        $folder1=opendir($fromFile);
        while($f1=readdir($folder1)){
            if($f1!="." && $f1!=".."){
                $path2="{$fromFile}/{$f1}";
                if(is_file($path2)){
                    $file = $path2;
                    $newfile = "{$toFile}/{$f1}";
                    copy($file, $newfile);
                }elseif(is_dir($path2)){
                    $toFiles = $toFile.'/'.$f1;
                    $this->copyFile($path2,$toFiles);
                }
            }
        }
    }
    /*
     * 递归创建文件夹
     */
    function CreateFolder($dir, $mode = 0777){
        if (is_dir($dir) || @mkdir($dir,$mode)){
            return true;
        }
        if (!$this->CreateFolder(dirname($dir),$mode)){
            return false;
        }
        return @mkdir($dir, $mode);
    }
}
//使用方法
//引入本类，直接new copyFile('要复制谁','复制到那');
//$file = new CopyFile('aaaa/aaaaa','bbbbb/bbbb');
?>