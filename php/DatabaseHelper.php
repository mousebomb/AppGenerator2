<?php
/**
 * Created by JetBrains PhpStorm.
 * User: rhett mousebomb@gmail.com
 * Created: 12-6-26 17:11
 * Modified: 13-10-30
 *  add: 简化query+fetch
 */
 class DatabaseHelper
{
    private $db;
    private $lastResult;
    /**
     * @var 查询次数
     */
    public $queryTime = 0;

    private static $instance;


    public static  function getInstance()
    {
        $end =null;
        if( empty(DatabaseHelper::$instance ) )
        {
            $end  = new DatabaseHelper();
        }else{
            $end = DatabaseHelper::$instance;
        }
        DatabaseHelper::$instance = $end;
        return $end;
    }

    private function __construct()
    {
        if(!empty(DatabaseHelper::$instance)) err(ErrorCodeConst::$sDbLinkError);
        $this->db = mysql_connect(DBHOST, DBUSER, DBPASS);
        if($this->db == false){writeLogErr('db connect err.'.mysql_error());}
        $db = mysql_select_db(DBNAME,$this->db);
        if ($db == false) writeLogErr("db construct err"."(".DBHOST .",".DBNAME. ','.DBUSER.','.DBPASS.")".":" . mysql_error());
        mysql_query("SET NAMES utf8");
    }

    /**
     * 执行update或delete语句，返回影响行数
     * @return int
     * @param String $sql
     */
    public function execute($sql)
    {
        $sql = str_replace("@#",DBTABLEPREFIX,$sql);
        if(IS_DEBUG)   writeLog($sql);
        #echo "<br/>sql:".$sql;
        $res =mysql_query($sql);
        ++$this->queryTime;
        if($res ===false){
            writeLogErr("SQL Error: $sql;" . mysql_error());
        return false;
        }
        return mysql_affected_rows($this->db);
    }

    public function lastError()
    {
        return mysql_error();
    }

    public function insertId()
    {
        return mysql_insert_id($this->db);
    }

    private function query($sql)
    {
        $sql = str_replace("@#",DBTABLEPREFIX,$sql);
        if(IS_DEBUG)   writeLog($sql);
        #echo "<br/>sql:".$sql;
        $this->lastResult = null;
        $this->lastResult = mysql_query($sql, $this->db);
        if ($this->lastResult == false) {
            writeLogErr(mysql_error().": ". $sql);
        }
        ++$this->queryTime;
        #var_dump($this->lastResult);
        #echo "<br/>";
    }

    public function fetchAll($sql)
    {
        $this->query($sql);
        $data = array();
        if ($this->lastResult) {
            while ($dbRow = mysql_fetch_assoc($this->lastResult)) {
                $data[] = $dbRow;
            }
        }
        return $data;
    }

    public function fetch($sql)
    {
        $this->query($sql);
        return mysql_fetch_assoc($this->lastResult);
    }

    public function transaction($sqlQueue)
    {
        mysql_query("BEGIN");
        foreach ($sqlQueue as $sql) {
            $sql = str_replace("@#",DBTABLEPREFIX,$sql);
            writeLog("事务:" . $sql);
            $executeResult = mysql_query($sql, $this->db);
            if (!$executeResult) {
                writeLog("事务处理出错:" . arrToString($sqlQueue));
                //失败一个就回滚并结束
                mysql_query("ROLLBACK");
                mysql_query("END");
                return false;
            }
        }
        mysql_query("COMMIT");
        mysql_query("END");
        ++$this->queryTime;
        return true;
    }

    public function rowCount()
    {
        return mysql_num_rows($this->lastResult);
    }

    public function __destruct()
    {
        #mysql_close($this->db);
    }
}
