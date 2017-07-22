---
date: 2017-07-22T09:33:19+02:00
draft: true
title: Loading SQL sequentially with doctrine fixtures in Symfony project
---

Most of today applications store and retrieve data of some sorts,
no matter if they are web, desktop or mobile (if there is a clear
distinction anymore).

And it is always nice during development and testing process to have a sample
data set to work with, and that can be expanded as the application evolves.
It makes things simpler for onbaording new developers, because you can see
how the data relates as opposed to relying on the schema and documentation
(you have documentation, right?), and easier to achieve a result required
for a feature when you actually have data to run queries against.

And, of course, if you have BDD/End-to-end tests, they will require test data.

<!--more-->

One of the better known tools for loading sample data (from here on, I'll refer
to them as data fixtures, or fixtures) is [Doctrine Data Fixtures][doctrine-data-fixtures] and if you work with Symfony framework, there is a [bundle][doctrine-fixtures-bundle], so it saves you some development time.
All of this gives you a neat package to get going and be productive.

Now for the problem, we are working on an application that has multiple databases.
And to make matters more interesting, one of them is legacy, which means,
due to security constraints we are not allowed to have full/dev dump during
development, but we can get a few rows here and there for the tables we need to
interact during development. This is perfectly fine, but the thing is, we get
a bunch of sql inserts, and I'll be damned if I waste project development time
on rewriting those sql inserts into doctrine entity inserts.

So I do what I do best, I automate things and make our lives easier.
I decided to make doctrine fixtures load sql inserts, and because I'm lazy
I decided to do it sequentially.

Because multiple databases are involved, and there can't be a clean separation
across the bundles, the location of the migration files is in application root
in `DataFixtures` directory. After that you follow the standard setup `DataFixtures/ORM/`, as we have two dbs, we have the `App`, and `Legacy` as well.
The sql files are located in `DataFixtures/Sql` as there are two databases,
they mirror the `ORM` paths as well, so there is `App` and `Legacy`.

The final layout looks like this

{{< codecaption lang="text" title="Directory Structure" >}}
DataFixtures
    |
    |-> ORM
    |    |
    |    |-> App
    |    |-> Legacy
    |
    |-> Sql
         |
         |-> App
         |-> Legacy
{{< /codecaption >}}

Again this should be nothing new, Classes to load the data should be in `ORM`.
Sql files should be in `Sql`.

As we get new sql inserts, they are to be placed in the file, **and this is important** the files are to be named in the form of `XXX-description.sql`,
 where `XXX` is sequential numeric value (001, 002, 003 and so on).
The zero padding is important for sorting, as you will see in a minute,
so be careful.

Lets put together a fixture loader for sql.

{{< codecaption lang="php" title="DataFixtures/ORM/Legacy/LoadData.php" >}}
<?php

namespace DataFixtures\ORM\Legacy;

use Doctrine\Common\DataFixtures\FixtureInterface;
use Doctrine\Common\Persistence\ObjectManager;
use Symfony\Component\Finder\Finder;

class LoadData implements FixtureInterface
{
    /**
     * Load data fixtures with the passed EntityManager
     *
     * @param ObjectManager $manager
     */
    public function load(ObjectManager $manager)
    {
        // Bundle to manage file and directories
        $finder = new Finder();
        $finder->in(__DIR__ . '/../../Sql/Legacy');
        $finder->name('*.sql');
        $finder->files();
        $finder->sortByName();

        foreach( $finder as $file ){
            print "Importing: {$file->getBasename()} " . PHP_EOL;

            $sql = $file->getContents();

            $manager->getConnection()->exec($sql);  // Execute native SQL

            $manager->flush();
        }
    }
}
{{< /codecaption >}}

It turns out it is rather simple, we need the Symfony finder component.

In lines 19-23 the following is happening...
To the instance of the finder, path needs to be supplied,
file mask for filtering, tell the finder only files are of interest, and that
they should be sorted by name (and here is why the padding is important, m'kay).

And there we go, sql can now be loaded for the legacy database when needed.

Suppose you have the following sql files in the `Sql/Legacy` directory:

- 001-sample-data.sql
- 002-more-sample-data.sql
- 003-even-more-sample-data.sql

We can now load the fixtures by executing the

{{< codecaption lang="bash">}}
bin/console doctrine:fixtures:load --env=dev --fixtures=DataFixtures/ORM/Legacy \
 --em=legacy -n
{{< /codecaption >}}

the output is

{{< codecaption lang="bash" title="Command output" >}}
  > purging database
  > loading DataFixtures\ORM\Legacy\LoadData
Importing: 001-sample-data.sql
Importing: 002-more-sample-data.sql
Importing: 003-even-more-sample-data.sql
{{< /codecaption >}}

As you can see, the db was purged first, and then our fixtures were loaded.

If you need to load the fixtures in the test db (provided you have a test
environment setup) can be done by replacing `--env=dev` with `--env=test` (or
whatever your testing environment is called).

But what about the app database? Well it is as simple as it comes,
Copy the class above to its new place, and fix the namespaces and paths
like in the example below.

{{< codecaption lang="php" title="DataFixtures/ORM/App/LoadData.php" >}}
<?php

namespace DataFixtures\ORM\App;

use Doctrine\Common\DataFixtures\FixtureInterface;
use Doctrine\Common\Persistence\ObjectManager;
use Symfony\Component\Finder\Finder;

class LoadData implements FixtureInterface
{
    /**
     * Load data fixtures with the passed EntityManager
     *
     * @param ObjectManager $manager
     */
    public function load(ObjectManager $manager)
    {
        // Bundle to manage file and directories
        $finder = new Finder();
        $finder->in(__DIR__ . '/../../Sql/App');
        $finder->name('*.sql');
        $finder->files();
        $finder->sortByName();

        foreach( $finder as $file ){
            print "Importing: {$file->getBasename()} " . PHP_EOL;

            $sql = $file->getContents();

            $manager->getConnection()->exec($sql);  // Execute native SQL

            $manager->flush();
        }
    }
}
{{< /codecaption >}}

And to load for the app database data when needed, we execute the following

{{< codecaption lang="bash">}}
bin/console doctrine:fixtures:load --env=dev --fixtures=DataFixtures/ORM/App \
 --em=app -n
{{< /codecaption >}}

Same thing applies for loading the test environment data.

Yeah, this could be refactored and such, but hey, it works, and it is almost
Good Enough(tm).

In case you are reading carefully, I did say "almost good enough".
There is a subtle problem with this approach as noted by [Robert][robertbasic].

As you import the sql statements, and if there is a problem with any of the
statements, doctrine will miss report the line at which the problem happened.
The fix is simple, but it is a **tradeoff**.

{{< codecaption lang="php" title="DataFixtures/ORM/Legacy/LoadData.php" >}}
<?php

namespace DataFixtures\ORM\Legacy;

use Doctrine\Common\DataFixtures\FixtureInterface;
use Doctrine\Common\Persistence\ObjectManager;
use Symfony\Component\Finder\Finder;

class LoadData implements FixtureInterface
{
    /**
     * Load data fixtures with the passed EntityManager
     *
     * @param ObjectManager $manager
     */
    public function load(ObjectManager $manager)
    {
        // Bundle to manage file and directories
        $finder = new Finder();
        $finder->in(__DIR__ . '/../../Sql/Legacy');
        $finder->name('*.sql');
        $finder->files();
        $finder->sortByName();

        foreach( $finder as $file ){
            print "Importing: {$file->getBasename()} " . PHP_EOL;

            $sql = $file->getContents();

            $sqls = explode("\n", $sql);

            foreach ($sqls as $sql) {
                if ($sql != '') {
                    $manager->getConnection()->exec($sql);  // Execute native SQL
                }
            }

            $manager->flush();
        }
    }
}
{{< /codecaption >}}

On lines 30-36 we explode the file by line ending, and then execute each line.
This means that if there is a an error, it will be correctly reported by
doctrine.

The downside of this is that if your sql file has sql statements that
are formatted over multilpe lines (not wrapped, mind you, line ended), you will not have a good time, then again all sql dumps are one line per statement.

And there you go, now you can load your sql statements when you need,
where you need.

[doctrine-data-fixtures]: https://github.com/doctrine/data-fixtures
[doctrine-fixtures-bundle]: http://symfony.com/doc/current/bundles/DoctrineFixturesBundle/index.html
[robertbasic]:https://twitter.com/robertbasic
