<?php
/**
 * Created by PhpStorm.
 * User: rhett
 * Date: 16/5/12
 * Time: 20:05
 *
 * 防破解的壳子，根据hashcode加密解密。PHP部分自动加密。
这个成功与否的关键在于安卓和iOS上是否可以读取bytearray操作后读取。

密码是一个int32。

13,
23
57
91
这几个Byte，分别与密码的4位相加。全部当作ubyte。
顺序全采用BigEndian。

解密时相减即可。

0xFF 8Bit char C 也就是ubyte

 *
 */

/**
 * @param $swfBinCursor 上次读取到的坐标
 * @param $offset 偏移坐标 要加密的起始位置，从这里开始32位为加密
 * @param $swfBin_
 * @param $encBin_
 */
function encUnit(&$swfBinCursor, $offset ,$encKeyPart , &$swfBin_, &$encBin_ )
{
    //前面的加入
    $encBin_ .= substr($swfBin_,$swfBinCursor,$offset-$swfBinCursor);
    $unpackRes = unpack("C",substr($swfBin_,$offset,1));
    $originalUByte = $unpackRes[1];
    $encUByte = $originalUByte + $encKeyPart;
    $encBin_ .= pack("C",$encUByte);
    $swfBinCursor = $offset + 1;
//    echo $encUByte . " ";
}

/**
 * 把UINT32 分解为4个UByte做密码
 * @param $encKey_
 */
function getEncPart($encKey_)
{
    $memEncKey = pack("N",$encKey_);
    $end = array();
    $tmp = unpack("C",substr($memEncKey,0,1)); $end[] = $tmp[1];
    $tmp = unpack("C",substr($memEncKey,1,1)); $end[] = $tmp[1];
    $tmp = unpack("C",substr($memEncKey,2,1)); $end[] = $tmp[1];
    $tmp = unpack("C",substr($memEncKey,3,1)); $end[] = $tmp[1];
    return $end;
}

function encryptSwf($swfFile,$encFile ,$encKey)
{
    $swfBin = file_get_contents($swfFile);
    $encBin = "";
    $swfBinCursor = 0;

    echo "Swf binary file size: " . strlen($swfBin) . "B\n";
    echo "EncKey=".$encKey."\n";
    echo "EncKeyParts=";
    $encKeyParts = getEncPart($encKey);
    print_r($encKeyParts);


// 某些偏移的位置 字节加密
    encUnit($swfBinCursor,13,$encKeyParts[0], $swfBin,$encBin);
    encUnit($swfBinCursor,23,$encKeyParts[1], $swfBin,$encBin);
    encUnit($swfBinCursor,57,$encKeyParts[2], $swfBin,$encBin);
    encUnit($swfBinCursor,91,$encKeyParts[3], $swfBin,$encBin);
// 最后一段补进去
    $encBin .= substr($swfBin,$swfBinCursor);

//写入加密后的文件
    $fileHandle = fopen($encFile, "w+");
    fwrite($fileHandle, $encBin);
    fclose($fileHandle);

    echo "Done enc. [EncFileSize " . strlen($encBin) . "B]\n";
    $sl = strlen($encBin);
    if($sl < 100)
    {
        for($i = 0 ;$i<100 && $i<$sl;$i++)
        {
            $char = substr($encBin,$i,1);
            $end  = unpack("C",$char);
            echo $end[1] ." ";
        }
        echo "\n";
    }

}
