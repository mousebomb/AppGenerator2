<?php
/**
 * Created by JetBrains PhpStorm.
 * User: rhett mousebomb@gmail.com
 * Created: 12-6-27 11:48
 * Modified:
 */

function writeFile($filename, $content)
{
    if (!$fp = @fopen($filename, "a")) {
        die("无法打开文件" . $filename);
    }
    @fwrite($fp, $content);
    @fclose($fp);
}

$t1 = 0;
$t2 = 0;
function writeLogStart($call = "")
{
    global $t1;
    $t1 = microtime(true);
    $log = date("Y-m-d H:i:s O:\t") . "REQUEST--  " . $_SERVER['REQUEST_URI'] . "(" . $_SERVER['REMOTE_ADDR'] . ")" . $call . "  --ENDREQUEST\n" . print_r($_POST, true);
    writeFile(LOG_PATH, $log);
}

function writeLog($content)
{
    writeFile(LOG_PATH, date("Y-m-d H:i:s O:\t") . $content . "\n");
}

function writeLogErr($content)
{
    writeFile(LOG_PATH, date("Y-m-d H:i:s O:\t") . "ERROR--  " . $content . "  --ENDERROR\n");
}

function writeLogEnd($end = "")
{
    global $t2, $t1;
    $database = DatabaseHelper::getInstance();
    $t2 = microtime(true);
    writeFile(LOG_PATH, date("Y-m-d H:i:s O:\t") . "RESPONSE--  " . $_SERVER['REQUEST_URI'] . "(" . $_SERVER['REMOTE_ADDR'] . ")" . " 耗时 " . (round(1000 * ($t2 - $t1))) . " 毫秒,  " . $database->queryTime . "次查询. --ENDRESPONSE \n " . $end . "\n");
}

function err($errCode)
{
    $jsonEnd = json_encode(new ResponseVO($errCode, null));
    writeLogEnd($jsonEnd);
    die($jsonEnd);
}

function response($end)
{
    $jsonEnd = json_encode(new ResponseVO(0, $end));
    writeLogEnd($jsonEnd);
    die($jsonEnd);
}

/**
 * 把一组数据转换成in字符串
 *
 * @param  $elements 要转换的数据
 * @param  $mode     1:数值|2:字符串
 *
 * @return 字符串
 */
function transInStatement($elements, $mode = 1, $subkey = null)
{
    if (count($elements) > 0) {
        $tmpArray_s = array();

        foreach ($elements as $element) {
            if ($subkey == null) {
                array_push($tmpArray_s, $element);
            } else {
                array_push($tmpArray_s, $element[$subkey]);
            }
        }

        switch ($mode) {
            case 1:
                $returnValue = implode(",", $tmpArray_s);
                break;
            case 2:
                $returnValue = implode("','", $tmpArray_s);
                break;

        }
        return $returnValue;
    } else {
        return 'null';
    }
}

function getIP()
{
    if (!empty($_SERVER["HTTP_CLIENT_IP"])) {
        $cip = $_SERVER["HTTP_CLIENT_IP"];
    } else if (!empty($_SERVER["HTTP_X_FORWARDED_FOR"])) {
        $cip = $_SERVER["HTTP_X_FORWARDED_FOR"];
    } else if (!empty($_SERVER["REMOTE_ADDR"])) {
        $cip = $_SERVER["REMOTE_ADDR"];
    } else {
        $cip = '';
    }
    preg_match("/[\d\.]{7,15}/", $cip, $cips);
    $cip = isset($cips[0]) ? $cips[0] : 'unknown';
    unset($cips);
    return $cip;
}

/**
 * 数组转字符串
 * @param $arr    数组
 *
 * @license 不是很喜欢递归,不过递归确实很管用……
 */
function arrToString($arr)
{
    $ending = "Array(";
    foreach ($arr as $key => $value) {
        if (is_array($value)) {
            $ending .= "[$key] => " . Utils::arrToString($value) . " ; \n";
        } else {
            $ending .= "[$key] => " . $value . " ; \n";
        }
    }
    $ending .= ")";
    return $ending;
}

/**
 * 数组转sql的update的字符串 默认只过滤id
 */
function arrToUpdateStr($arr)
{

    $commitStr = "";
    foreach ($arr as $k => $v) {
        if ($k == 'id') continue;
        if (is_string($v)) {
            $commitStr .= sprintf("`%s`='%s',", $k, addslashes($v));
        } else {
            $commitStr .= sprintf("`%s`=%d,", $k, $v);
        }
    }
    $commitStr = substr($commitStr, 0, strlen($commitStr) - 1);
    return $commitStr;
}

/**
 * 数组转sql的update的字符串 -除了id外再过滤一部分
 */
function arrToUpdateStrFiltered($arr, $without)
{

    $commitStr = "";
    foreach ($arr as $k => $v) {
        if (in_array($k, $without) || $k == 'id') continue;
        if (is_string($v)) {
            $commitStr .= sprintf("`%s`='%s',", $k, $v);
        } else {
            $commitStr .= sprintf("`%s`=%d,", $k, $v);
        }
    }
    $commitStr = substr($commitStr, 0, strlen($commitStr) - 1);
    return $commitStr;
}


/**
 * Verifies that an email is valid.
 *
 * Does not grok i18n domains. Not RFC compliant.
 *
 * @since  0.71
 * @author wordpress group
 *
 * @param string  $email     Email address to verify.
 * @param boolean $check_dns Whether to check the DNS for the domain using checkdnsrr().
 *
 * @return string|bool Either false or the valid email address.
 */
function isEmail($email, $check_dns = false)
{
    // Test for the minimum length the email can be
    if (strlen($email) < 3) {
        return false;
    }

    // Test for an @ character after the first position
    if (strpos($email, '@', 1) === false) {
        return false;
    }

    // Split out the local and domain parts
    list ($local, $domain) = explode('@', $email, 2);

    // LOCAL PART
    // Test for invalid characters
    if (!preg_match('/^[a-zA-Z0-9!#$%&\'*+\/=?^_`{|}~\.-]+$/', $local)) {
        return false;
    }

    // DOMAIN PART
    // Test for sequences of periods
    if (preg_match('/\.{2,}/', $domain)) {
        return false;
    }

    // Test for leading and trailing periods and whitespace
    if (trim($domain, " \t\n\r\0\x0B.") !== $domain) {
        return false;
    }

    // Split the domain into subs
    $subs = explode('.', $domain);

    // Assume the domain will have at least two subs
    if (2 > count($subs)) {
        return false;
    }

    // Loop through each sub
    foreach ($subs as $sub) {
        // Test for leading and trailing hyphens and whitespace
        if (trim($sub, " \t\n\r\0\x0B-") !== $sub) {
            return false;
        }

        // Test for invalid characters
        if (!preg_match('/^[a-z0-9-]+$/i', $sub)) {
            return false;
        }
    }

    // DNS
    // Check the domain has a valid MX and A resource record
    if ($check_dns && function_exists('checkdnsrr') && !(checkdnsrr($domain . '.', 'MX') || checkdnsrr($domain . '.', 'A'))) {
        return false;
    }

    // Congratulations your email made it!
    return true;
}

/**
 * SQL语句中的字符串过滤
 * @return
 *
 * @param object $str
 */
function filtSqlStr($str)
{
    if (get_magic_quotes_gpc()) {
        #魔法引号若开启的，则不用addslashes
        return $str;
    } else {
        return addslashes($str);
    }
}

/**
 * 获得http输入字段
 *
 * @param $key
 */
function input($key)
{
    return $_REQUEST[$key];
}

/**
 * 输出html
 */
function makePageNavi($pageCurrent, $pageTotal, $extArgs = "?", $pageArgKey = 'p')
{
    if ($pageTotal <= 1) return "";
    $end = '<div class="pagination">';
    $end .= sprintf('<a href="%s%s=1" title="第一页">&laquo; 第一页</a>', $extArgs, $pageArgKey);
    if ($pageCurrent > 1) {
        $end .= sprintf(' <a href="%s%s=%d" title="前页">&laquo; 前页</a>', $extArgs, $pageArgKey, $pageCurrent - 1);
    }
    // 中间for
    $numPageBtnStart = $pageCurrent - 3;
    if ($numPageBtnStart < 1) {
        $numPageBtnStart = 1;
    }
    $numPageBtnEnd = $numPageBtnStart + 6;
    if ($numPageBtnEnd > $pageTotal) {
        // 引发补齐
        $numPageBtnStart -= ($numPageBtnEnd - $pageTotal);
        if ($numPageBtnStart < 1) {
            $numPageBtnStart = 1;
        }
        // 再赋值
        $numPageBtnEnd = $pageTotal;
    }
    for ($i = $numPageBtnStart; $i <= $numPageBtnEnd; $i++) {
        $isCurrent = $i == $pageCurrent ? "current" : "";
        $end .= sprintf('<a href="%s%s=%d" class="number %s" title="%d">%d</a>', $extArgs, $pageArgKey, $i, $isCurrent, $i, $i);
    }
    //
    if ($pageCurrent < $pageTotal) {
        $end .= sprintf('<a href="%s%s=%d" title="后页">后页 &raquo;</a>', $extArgs, $pageArgKey, $pageCurrent + 1);
    }
    $end .= sprintf('<a href="%s%s=%d" title="最后页">最后页 &raquo;</a>', $extArgs, $pageArgKey, $pageTotal);
    $end .= "</div>";
    return $end;
}