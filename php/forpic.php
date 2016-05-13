<?php
/**
 * Created by PhpStorm.
 * User: rhett
 * Date: 14/12/21
 * Time: 19:41
 */
?>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Pic生成器</title>
</head>
<body>
<pre><?php


    $prefix =$_REQUEST['prefix'];
    $from=$_REQUEST['from'];
    $to=$_REQUEST['to'];
    if(!empty($prefix))
    {
        for($i = $from ; $i<=$to ;$i++)
        {
            echo("$prefix" . $i . ";");
        }
    }

    ?></pre>
<form action="">
    <h2>产生批量PicX</h2>
    <input type="text" name="prefix" value="Pic" />
    <input type="text" name="from" value="1" />
    <input type="text" name="to" value="30" />
    <input type="submit" value="立即产生"/>
</form>
</body>
</html>