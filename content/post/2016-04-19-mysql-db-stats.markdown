---
date: 2016-04-19T11:09:11+02:00
draft: false
title: MySql database statistics
categories:
    - MySql
tags:
    - mysql
---

One of the projects we are involved with has a data store in RDS, recently I had
to figure out the size of the tables and one of the databases. As RDS does not
report this diectly, I had to dig through some internet to get my answers, and
this post is the result, having all the queries in one place, so next time I need
it, I can find it with ease.

OK, first thing I wanted to find out is exactly how much space is the db using,
the following query answers that in a nice way.

{{< codecaption lang="mysql" >}}
SELECT table_schema "DB Name",
    Round(Sum(data_length + index_length) / 1024 / 1024, 1) "DB Size in MB",
    Round(Sum(data_free) / 1024 / 1024, 1) "Free Space in MB"
FROM   information_schema.tables
GROUP  BY table_schema;


+--------------------+---------------+------------------+
| DB Name            | DB Size in MB | Free Space in MB |
+--------------------+---------------+------------------+
| dbase              |     1463760.2 |             20.0 |
| information_schema |           0.0 |              0.0 |
| mysql              |           5.6 |              0.0 |
| performance_schema |           0.0 |              0.0 |
+--------------------+---------------+------------------+
4 rows in set (0.49 sec)

{{< /codecaption >}}

So this tells me that database `dbase` has the size of 1.4TB.
This is a good thing to know, but lets see how much space is each MySql engine
using. The following query answers that in a nice way.

{{< codecaption lang="mysql" >}}
SELECT
    IF(ISNULL(DB)+ISNULL(ENGINE)=2,'Database Total',
    CONCAT(DB,' ',IFNULL(ENGINE,'Total'))) "Reported Statistic",
    LPAD(CONCAT(FORMAT(DAT/POWER(1024,pw1),2),' ',
    SUBSTR(units,pw1*2+1,2)),17,' ') "Data Size",
    LPAD(CONCAT(FORMAT(NDX/POWER(1024,pw2),2),' ',
    SUBSTR(units,pw2*2+1,2)),17,' ') "Index Size",
    LPAD(CONCAT(FORMAT(TBL/POWER(1024,pw3),2),' ',
    SUBSTR(units,pw3*2+1,2)),17,' ') "Total Size"
FROM
(
    SELECT DB,ENGINE,DAT,NDX,TBL,
    IF(px>4,4,px) pw1,IF(py>4,4,py) pw2,IF(pz>4,4,pz) pw3
    FROM
    (SELECT *,
        FLOOR(LOG(IF(DAT=0,1,DAT))/LOG(1024)) px,
        FLOOR(LOG(IF(NDX=0,1,NDX))/LOG(1024)) py,
        FLOOR(LOG(IF(TBL=0,1,TBL))/LOG(1024)) pz
    FROM
    (SELECT
        DB,ENGINE,
        SUM(data_length) DAT,
        SUM(index_length) NDX,
        SUM(data_length+index_length) TBL
    FROM
    (
       SELECT table_schema DB,ENGINE,data_length,index_length FROM
       information_schema.tables WHERE table_schema NOT IN
       ('information_schema','performance_schema','mysql')
       AND ENGINE IS NOT NULL
    ) AAA GROUP BY DB,ENGINE WITH ROLLUP
) AAA) AA) A,(SELECT ' BKBMBGBTB' units) B;


+--------------------+-------------------+-------------------+-------------------+
| Reported Statistic | Data Size         | Index Size        | Total Size        |
+--------------------+-------------------+-------------------+-------------------+
| dbase InnoDB       |         472.19 GB |         957.27 GB |           1.40 TB |
| dbase Total        |         472.19 GB |         957.27 GB |           1.40 TB |
| Database Total     |         472.19 GB |         957.27 GB |           1.40 TB |
+--------------------+-------------------+-------------------+-------------------+
3 rows in set (0.12 sec)

{{< /codecaption >}}

So now I know that my people were smart and only used InnoDB, and that Index size
of the database is ridiculous, more than twice the size of the data.
I needed a moment to pick my jaw from the floor.

OK, lets dig in some more and see the actual tables data size and index size.
The following  query answers that in a nice way, remember to change `table_schema`
to your db name at line 16.

{{< codecaption lang="mysql" >}}
SELECT
    TABLE_NAME,
    CONCAT(FORMAT(DAT/POWER(1024,pw1),2),' ',SUBSTR(units,pw1*2+1,2)) DATSIZE,
    CONCAT(FORMAT(NDX/POWER(1024,pw2),2),' ',SUBSTR(units,pw2*2+1,2)) NDXSIZE,
    CONCAT(FORMAT(TBL/POWER(1024,pw3),2),' ',SUBSTR(units,pw3*2+1,2)) TBLSIZE
FROM
(
    SELECT TABLE_NAME, DAT,NDX,TBL,IF(px>4,4,px) pw1,IF(py>4,4,py) pw2,IF(pz>4,4,pz) pw3
    FROM
    (
        SELECT TABLE_NAME, data_length DAT,index_length NDX,data_length+index_length TBL,
        FLOOR(LOG(IF(data_length=0,1,data_length))/LOG(1024)) px,
        FLOOR(LOG(IF(index_length=0,1,index_length))/LOG(1024)) py,
        FLOOR(LOG(data_length+index_length)/LOG(1024)) pz
        FROM information_schema.tables
        WHERE table_schema='dbase'
    ) AA
) A,(SELECT 'B KBMBGBTB' units) B;


+-----------------------+-----------+-----------+-----------+
| TABLE_NAME            | DATSIZE   | NDXSIZE   | TBLSIZE   |
+-----------------------+-----------+-----------+-----------+
| alembic_version       | 16.00 KB  | 0.00 B    | 16.00 KB  |
| chump_change          | 2.52 MB   | 3.50 MB   | 6.02 MB   |
| my_table              | 82.09 GB  | 103.35 GB | 185.44 GB |
| splatter_table        | 389.17 GB | 851.52 GB | 1.21 TB   |
| optimization          | 943.00 MB | 2.40 GB   | 3.32 GB   |
+-----------------------+-----------+-----------+-----------+
5 rows in set (0.00 sec)

{{< /codecaption >}}

And once again the results are in. It is obvious hat `splatter_table` is out of control.

So there you go, a nice set of queries that will answer the questions about the
database size.
