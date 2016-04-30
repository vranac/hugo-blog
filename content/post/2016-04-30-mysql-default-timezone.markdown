---
date: 2016-04-30T07:21:25+02:00
title: MySql default timezone
categories:
    - MySql
tags:
    - mysql
---

So lately we have been hitting some interesting egde cases (at least to us) while
using the MySql on RDS and in local when using the `CONVERT_TZ` functions.
<!--more-->
If we executed the following query on production database
{{< codecaption lang="mysql" >}}
mysql> SELECT DATE(CONVERT_TZ(FROM_UNIXTIME(1456479303), "+00:00", "America/New_York"));
{{< /codecaption >}}

The result would be the desired date
{{< codecaption lang="mysql" >}}
+---------------------------------------------------------------------------+
| DATE(CONVERT_TZ(FROM_UNIXTIME(1456479303), "+00:00", "America/New_York")) |
+---------------------------------------------------------------------------+
| 2016-02-26                                                                |
+---------------------------------------------------------------------------+
1 row in set (0.00 sec)
{{< /codecaption >}}

But, if we ran the same query on our local dev boxes, the result would be something
else entirely
{{< codecaption lang="mysql" >}}
+---------------------------------------------------------------------------+
| DATE(CONVERT_TZ(FROM_UNIXTIME(1456479303), "+00:00", "America/New_York")) |
+---------------------------------------------------------------------------+
| NULL                                                                      |
+---------------------------------------------------------------------------+
1 row in set (0.00 sec)
{{< /codecaption >}}

As you can guess this is not a good thing, and made a mess of a few important queries.

So first things first, lets see what the timezone settings are in MySql db.
You can find that out by running the following query

{{< codecaption lang="mysql" >}}
mysql> SELECT @@global.time_zone, @@session.time_zone;
{{< /codecaption >}}

The results on the RDS instance were expected, `UTC`
{{< codecaption lang="mysql" >}}
+--------------------+---------------------+
| @@global.time_zone | @@session.time_zone |
+--------------------+---------------------+
| UTC                | UTC                 |
+--------------------+---------------------+
1 row in set (0.00 sec)
{{< /codecaption >}}

But... The results on the local box were not
{{< codecaption lang="mysql" >}}
+--------------------+---------------------+
| @@global.time_zone | @@session.time_zone |
+--------------------+---------------------+
| SYSTEM             | SYSTEM              |
+--------------------+---------------------+
1 row in set (0.00 sec)
{{< /codecaption >}}

Namely, the local MySql has timezone set to whatever the System time zone setting
is for the Ubuntu box, and we need it to be `UTC`.

For our intents and purposed this works, note the following before proceeding:

1. Changing the timezone will not change the stored datetime or timestamp, but it will select a different datetime from timestamp columns

2. UTC does not use daylight savings time, GMT (the region) does, GMT (the timezone) does not (GMT is also confusing the definition of seconds which is why UTC was invented).

3. **Warning!** UTC has leap seconds, these look like '2012-06-30 23:59:60' and can be added randomly, with 6 months prior notice, due to the slowing of the earths rotation

4. **Warning!** different regional timezones might produce the same datetime value due to daylight savings time

5. The timestamp column only supports dates 1970-01-01 00:00:01 to 2038-01-19 03:14:07 UTC

6. Internally a [MySQL timestamp column][MySQL timestamp column] is stored as [UTC][MySql UTC] but when selecting a date MySQL will automatically convert it to the current session timezone.
When storing a date in a timestamp, MySQL will assume that the date is in the current session timezone and convert it to UTC for storage.

7. MySQL can store partial dates in datetime columns, these look like "2013-00-00 04:00:00"
8. MySQL stores "0000-00-00 00:00:00" if you set a datetime column as NULL, unless you specifically set the column to allow null when you create it.
9. [Read this][Read this]

Source of these notes is a [StackOverflow answer][StackOverflow answer]

There are few ways of going on about setting the default timezone,
the solution I opted for is to have the timezone configured in the `my.cnf` file.

But, in order to be able to do that, I needed to have the MySql timezone tables populated.

This can be checked by running the following queries

{{< codecaption lang="mysql" >}}
mysql> SELECT * FROM mysql.`time_zone` ;
Empty set (0.00 sec)

mysql> SELECT * FROM mysql.`time_zone_leap_second` ;
Empty set (0.00 sec)

mysql> SELECT * FROM mysql.`time_zone_name` ;
Empty set (0.00 sec)

mysql> SELECT * FROM mysql.`time_zone_transition` ;
Empty set (0.00 sec)

mysql> SELECT * FROM mysql.`time_zone_transition_type` ;
Empty set (0.00 sec)
{{< /codecaption >}}

Well now, seems that by default MySql 5.6 on Ubuntu Trusty does not have the timezone
tables populated by default.

OK, we can fix that quickly, by running the following from bash

{{< codecaption lang="bash" >}}
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p mysql
{{< /codecaption >}}

The `-p` switch is optional, depending on your setup.

The output might report some errors, but it did not pose any problems for me
in further setting this up, as usual YMMV.
The output of the command might look like

{{< codecaption lang="bash" >}}
vagrant@vagrant-ubuntu-trusty-64:~$ mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql
Warning: Unable to load '/usr/share/zoneinfo/iso3166.tab' as time zone. Skipping it.
Warning: Unable to load '/usr/share/zoneinfo/zone.tab' as time zone. Skipping it.
{{< /codecaption >}}

Now, when you run the timezone table queries from above again, the result will be
a nice wall of data.

OK, two steps to go.
First, in the `my.cnf` config file, add the `default_time_zone` option, under the
`mysqld` section

{{< codecaption lang="ini" title="/etc/mysql/my.cnf">}}
[mysqld]
...
default_time_zone = 'UTC'
{{< /codecaption >}}

And now only thing left to do, is to restart the MySql and check the results.

To restart the MySql execute

{{< codecaption lang="bash" >}}
sudo service mysql restart
{{< /codecaption >}}

And then you can check in the MySql if it is all working properly.
First run the timezone query

{{< codecaption lang="mysql" >}}
mysql> SELECT @@global.time_zone, @@session.time_zone;
+--------------------+---------------------+
| @@global.time_zone | @@session.time_zone |
+--------------------+---------------------+
| UTC                | UTC                 |
+--------------------+---------------------+
1 row in set (0.00 sec)
{{< /codecaption >}}

Seems that it is now configured properly.
Lets run the query that discovered this whole mess to see if it is working.

{{< codecaption lang="mysql" >}}
mysql> SELECT DATE(CONVERT_TZ(FROM_UNIXTIME(1456479303), "+00:00", "America/New_York"));
+---------------------------------------------------------------------------+
| DATE(CONVERT_TZ(FROM_UNIXTIME(1456479303), "+00:00", "America/New_York")) |
+---------------------------------------------------------------------------+
| 2016-02-26                                                                |
+---------------------------------------------------------------------------+
1 row in set (0.00 sec)
{{< /codecaption >}}

Awesome, the result is properly displayed, and now we can go back to making awesome stuff.


[MySQL timestamp column]:http://dev.mysql.com/doc/refman/5.1/en/datetime.html
[MySql UTC]:http://en.wikipedia.org/wiki/Coordinated_Universal_Time
[Read this]: http://stackoverflow.com/a/1650910/175071
[StackOverflow answer]:http://stackoverflow.com/a/19075291/99219

