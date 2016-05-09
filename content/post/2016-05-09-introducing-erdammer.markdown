---
date: 2016-05-09T22:08:27+02:00
title: Introducing ERDammer
categories:
    - Databases
    - Diagrams
    - Graphs
tags:
    - Databases
    - Diagrams
    - Graphs
---

Lately I have been looking into tools that can help us generate Entity Relationship
Diagrams from database schema, and to create some kind of editable format
that can be then integrated with rest of the documentation and transformed by
Sphinx to html.
<!--more-->
Needles to say the options were sorely lacking, they either fell short of my
requirements or they required java to be installed, or both.
So in a moment of idleness, my mind decided to build a playground... Again.

I present to you ERDammer, because your database documentation is usually full
of holes, like cheese.

ERDammer is a simple tool that will output the database schema into:

- svg
- rst
- csv
- dot

To install it, you just need to execute in the terminal:
{{< codecaption lang="bash" >}}
pip install erdammer
{{< /codecaption >}}

# The Good

The syntax is pretty simple, to get you started you can run `erdammer --help`

Things to note, to connect to the database you will have to supply a connection string uri.

For example:
{{< codecaption lang="bash" >}}
erdammer --uri "mysql+mysqlconnector://user:password@server/dbname" \
--output-directory="db-schema/" --output-format=svg
{{< /codecaption >}}

Or, to use a more 'realistic' example of northwind database, loaded into MySql,
you would execute the following command
{{< codecaption lang="bash" >}}
erdammer --uri "mysql+mysqlconnector://user:pass@localhost/northwind" \
--output-directory="/var/www/northwind" --output-format=svg --output-name="northwind"
{{< /codecaption >}}

And the output svg would look like this

[![](/images/2016-05-09-introducing-erdammer/northwind.svg)]
(/images/2016-05-09-introducing-erdammer/northwind.svg)

But what about the database documentation, as the svg is nice, but not really
easily editable.

Well in that case we can output to ReStructured text with the following command:

{{< codecaption lang="bash" >}}
erdammer --uri "mysql+mysqlconnector://user:pass@localhost/northwind" \
--output-directory="/var/www/northwind" --output-format=rst
{{< /codecaption >}}

The command will output one rst file per table, with table name as the filename
into the northwind directory. The content of the rst file looks like:

{{< codecaption lang="rst" title="customers.rst" >}}
==================    ===========
Name                  Type
==================    ===========
\* id                 INTEGER(11)
company               VARCHAR(50)
last_name             VARCHAR(50)
first_name            VARCHAR(50)
email_address         VARCHAR(50)
job_title             VARCHAR(50)
business_phone        VARCHAR(25)
home_phone            VARCHAR(25)
mobile_phone          VARCHAR(25)
fax_number            VARCHAR(25)
address               LONGTEXT
city                  VARCHAR(50)
state_province        VARCHAR(50)
zip_postal_code       VARCHAR(15)
country_region        VARCHAR(50)
web_page              LONGTEXT
notes                 LONGTEXT
attachments           LONGBLOB
==================    ===========
{{< /codecaption >}}

So now you have a nice SVG to give you an overview of your database, and, you have
a nice ReStructured text file that you can include into your Sphinx documentation
for nice html generation.

Or if you want, you can export the table definitions as csv, again, one file per
table, with table name as filename by executing
{{< codecaption lang="bash" >}}
erdammer --uri "mysql+mysqlconnector://user:pass@localhost/northwind" \
--output-directory="/var/www/northwind" --output-format=csv
{{< /codecaption >}}

And the result would look like
{{< codecaption lang="text" title="customers.csv" >}}
Name,Type
* id,INTEGER(11)
company,VARCHAR(50)
last_name,VARCHAR(50)
first_name,VARCHAR(50)
email_address,VARCHAR(50)
job_title,VARCHAR(50)
business_phone,VARCHAR(25)
home_phone,VARCHAR(25)
mobile_phone,VARCHAR(25)
fax_number,VARCHAR(25)
address,LONGTEXT
city,VARCHAR(50)
state_province,VARCHAR(50)
zip_postal_code,VARCHAR(15)
country_region,VARCHAR(50)
web_page,LONGTEXT
notes,LONGTEXT
attachments,LONGBLOB
{{< /codecaption >}}

And in case you want a png or some other image format instead of svg, you can export
the ERD in dot format, which you can then transform to your liking.

To export the ERD into dot format, you would execute the following:

{{< codecaption lang="bash" >}}
erdammer --uri "mysql+mysqlconnector://user:pass@localhost/northwind" \
--output-directory="/var/www/northwind" --output-format=dot --output-name="northwind"
{{< /codecaption >}}

# The Bad

ERDammer does not mark the relationships properly, that will
be fixed in future versions.

Now we can generate our database ERD and documentation straight from the command
line, and it can be automated and integrated into our Sphinx build tool chain.
