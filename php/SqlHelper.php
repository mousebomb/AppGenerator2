<?php

/**
 *  SqlHelper : 封装Insert,update,delete
 * User: rhett
 * Date: 14-2-14
 * Time: 14:13
 * To change this template use File | Settings | File Templates.
 */

define("FIELD_INT","%d");
define("FIELD_STRING","'%s'");
define("FIELD_FLOAT",'%f');
define("FIELD_NUMBERCALC","+-");


// DB默认时间
define("TIMESTAMP_0","0000-00-00 00:00:00");
define("TIMESTAMP_NOW",date("Y-m-d H:i:s"));


class SqlHelper
{
    static $fieldTypeString = '\'%s\'';
    static $fieldTypeInt = '%d';
    static $fieldTypeFloat = '%f';


    public $sql;

    private $tables = array();

    private $kvPair = array();
    private $ktPair = array();

    private $selectField = array();

    private $whereKvPair = array();
    private $whereKtPair = array();
    private $whereKoPair = array();


    function __construct($table)
    {
        $this->joinTable($table);
    }

    public function joinTable($table)
    {
        $this->tables[] = $table;
    }

    /**
     * SELECT 状态下可追加表
     */
    private function fromTables()
    {
        $end = array();
        foreach ($this->tables as $table) {
            $end[] = '`@#' . $table . '`';
        }
        return implode(",", $end);
    }

    public function addKVPair($key, $val, $type)
    {
        $this->kvPair[$key] = $val;
        $this->ktPair[$key] = $type;
    }

    public function addWhereKVPair($key, $val, $type , $opr = "=")
    {
        $this->whereKvPair[$key] = $val;
        $this->whereKtPair[$key] = $type;
        $this->whereKoPair[$key] = $opr;
    }

    public function getInsertSql()
    {
        $sqlKeys = '';
        $sqlVals = '';
        foreach ($this->kvPair as $key => $val) {
            $sqlKeys .= "`" . $key . "`,";
            $type = $this->ktPair[$key];
            $sqlVals .= sprintf($type, $val) . ",";
        }
//
        $sql = sprintf("INSERT INTO %s (%s) VALUES(%s)", $this->fromTables()
            , substr($sqlKeys, 0, strlen($sqlKeys) - 1)
            , substr($sqlVals, 0, strlen($sqlVals) - 1));
        return $sql;
    }

    public function getUpdateSql()
    {
//        set
        $setPair = "";
        foreach ($this->kvPair as $key => $val) {
            $type = $this->ktPair[$key];
            if($type == FIELD_NUMBERCALC)
            {
                $setPair .= sprintf("`%s` = `%s`%s,",$key,$key, $val);
            }else{
                $format = "`%s` = " . $type . ",";
                $setPair .= sprintf($format,$key, $val);
            }
        }
        $setPair = substr($setPair, 0, strlen($setPair) - 1);
//        where
        $wherePair = "";
        foreach ($this->whereKvPair as $key => $val) {
            $type = $this->whereKtPair[$key];
            $opr = $this->whereKoPair[$key];
            $format = " %s %s " . $type . " AND";
            $wherePair .= sprintf($format,$key,$opr, $val);
        }
        $wherePair = substr($wherePair, 0, strlen($wherePair)-3);
//
        $sql = sprintf("UPDATE %s SET %s WHERE %s", $this->fromTables()
            , $setPair
            , $wherePair);
        return $sql;
    }


//    SELECT

    static public function getLimitSql($page, $countPerPage)
    {
        $start = ($page - 1) * $countPerPage;
        return sprintf(" LIMIT %d , %d ", $start, $countPerPage);
    }

    /**
     * 添加要查询的项，若一次都不调用，则当作查询所有字段
     * @param $field
     */
    public function addSelectField($field)
    {
        $this->selectField[] = '`'.$field.'`';
    }

    /**
     * @param     $page 不填则全部取出
     * @param int $countPerPage
     *
     * @return string
     */
    public function getSelectSql($page=-1, $countPerPage=50)
    {
        if (count($this->selectField) == 0)
            $fields = "*";
        else
            $fields = implode(",", $this->selectField);
//
        $sql = sprintf("SELECT %s FROM %s", $fields , $this->fromTables() );
        if(count($this->whereKvPair)>0)
        {
            $wherePair = "";
            foreach ($this->whereKvPair as $key => $val) {
                $type = $this->whereKtPair[$key];
                $opr = $this->whereKoPair[$key];
                $format = " %s %s " . $type . " AND";
                $wherePair .= sprintf($format,$key,$opr, $val);
            }

            $wherePair = substr($wherePair, 0, strlen($wherePair)-3);
            $sql .= " WHERE " . $wherePair;
        }
        if($page >0 )
        {
            $sql .= SqlHelper::getLimitSql($page, $countPerPage);
        }
        return $sql;
    }

}