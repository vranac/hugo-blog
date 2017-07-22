---
date: 2017-07-22T13:58:45+02:00
draft: false
title: Loading SQL fixtures before behat features

categories:
    - php
    - doctrine
    - fixtures
    - database
    - behat
    - bdd
tags:
    - php
    - doctrine
    - fixtures
    - database
    - behat
    - bdd
---

After figuring out the way to [load the sql fixtures][loading-sql-fixtures]
it was time to integrate fixtures loading in our [behat][behat] suites.

<!--more-->

While I'll keep my thoughts on [behat][behat] for another time, with just a bit
of googling you can find a lot of material how to load fixtures before scenario/feature, for example [Robert's post][robert-behat-fixtures], or you could use [Alice behat extension][alice-extension], or if you like plain and simple,
you could use [Behat Fixtures extension][behat-fixtures-extension].

This way or that, you have a lot of options, still, they require more or less
work to get up and running, and in our particular case, there was a problem
of sql inserts.

Latelly I have been trying to hold to ["law of parsimony"][occams-razor] to make
 the simplest solution possible, and complicate it only when needed.

With that in mind, it occured to me, that I could circumvent a nice chunk of code
by executing the `doctrine:fixtures:load` with arguments before running
behat feature.

All the pieces were there, just needed to connect them in a meaningfull way.

I would need to use [Symfony Process][symfony-process] component to execute
the shell command we need.

{{< codecaption lang="php" title="src/AppBundle/Tests/Features/Context/BaseContext.php" >}}
<?php

namespace AppBundle\Tests\Features\Context;

use Behat\WebApiExtension\Context\WebApiContext;
use PHPUnit\Framework\Assert;
use Symfony\Component\Process\Exception\ProcessFailedException;
use Symfony\Component\Process\Process;

class BaseContext extends WebApiContext
{
    /**
     * Load data fixtures by executing the console command
     *
     * @param $fixture The directory to load data fixtures from
     * @param $em The entity manager to use for this command
     * @param $env The environment name
     */
    public static function loadDataFixture($fixture, $em, $env): void
    {
        print(__DIR__) . PHP_EOL;
        $command = __DIR__ . "/../../../../../bin/console doctrine:fixtures:load --env={$env} --fixtures={$fixture} --em={$em} -n";

        $process = new Process($command);
        $process->run();

        // executes after the command finishes
        if (!$process->isSuccessful()) {
            throw new ProcessFailedException($process);
        }

        echo $process->getOutput();
    }
}
{{< /codecaption >}}

The code is pretty much standard and no surprises there, apart from the
atrocity of line 22, but hey, it works.

It is a bit generalized so you can pass the path to fixtures, entity manager, and environment name.

Awesome, now how to use it?
Well, after looking into [behat hooks][behat-hooks], I learned that I need
to hook into the `BeforeFeature`, by annotating a static function with it

{{< codecaption lang="php" title="src/AppBundle/Tests/Features/Context/BaseContext.php" >}}
<?php

namespace AppBundle\Tests\Features\Context;

use Behat\WebApiExtension\Context\WebApiContext;
use PHPUnit\Framework\Assert;
use Symfony\Component\Process\Exception\ProcessFailedException;
use Symfony\Component\Process\Process;

class BaseContext extends WebApiContext
{
    /** @BeforeFeature */
    public static function setupFeature()
    {
        print "Loading fixtures for app " . PHP_EOL;
        self::loadDataFixture("DataFixtures/ORM/App", "app", "test");
        print "Loading fixtures for legacy " . PHP_EOL;
        self::loadDataFixture("DataFixtures/ORM/Legacy", "legacy", "test");
    }

    /**
     * Load data fixtures by executing the console command
     *
     * @param $fixture The directory to load data fixtures from
     * @param $em The entity manager to use for this command
     * @param $env The environment name
     */
    public static function loadDataFixture($fixture, $em, $env): void
    {
        print(__DIR__) . PHP_EOL;
        $command = __DIR__ . "/../../../../../bin/console doctrine:fixtures:load --env={$env} --fixtures={$fixture} --em={$em} -n";

        $process = new Process($command);
        $process->run();

        // executes after the command finishes
        if (!$process->isSuccessful()) {
            throw new ProcessFailedException($process);
        }

        echo $process->getOutput();
    }
}
{{< /codecaption >}}

Now before each feature, the database will be purged, and the fixtures will be
reloaded, just like that.

All you need to do, is to have your context classes inherit this `BaseContext`
class.

So when `vendor/bin/behat` is run, the output will be something along the lines
of:

{{< codecaption lang="bash" >}}
ubuntu@sample-project:/var/www/sample-project$ vendor/bin/behat
┌─ @BeforeFeature # AppBundle\Tests\Features\Context\LoginContext::setupFeature()
│
│  Loading fixtures for app
│  /var/www/sample-project/src/AppBundle/Tests/Features/Context
│    > purging database
│    > loading DataFixtures\ORM\App\LoadData
│  Importing: 001-sample-data.sql
│  Importing: 002-more-sample-data.sql
│  Importing: 003-even-more-sample-data.sql
│  Loading fixtures for legacy
│  /var/www/sample-project/src/AppBundle/Tests/Features/Context
│    > purging database
│    > loading DataFixtures\ORM\Legacy\LoadData
│  Importing: 001-sample-data.sql
│  Importing: 002-more-sample-data.sql
│  Importing: 003-even-more-sample-data.sql
│
Feature: Our shiny login feature
{{< /codecaption >}}

Now all only thing needed, is for them tests to keep green, and their numbers
increasing.

[loading-sql-fixtures]:http://blog.code4hire.com/2017/07/loading-sql-sequentially-with-doctrine-fixtures-in-symfony-project/
[behat]:http://behat.org/en/latest/
[robert-behat-fixtures]:https://robertbasic.com/blog/loading-fixtures-for-a-symfony-app-in-behat-tests/
[alice-extension]:https://github.com/rezzza/alice-extension
[behat-fixtures-extension]:https://github.com/BehatExtension/DoctrineDataFixturesExtension
[nih-syndrome]:https://en.wikipedia.org/wiki/Not_invented_here
[occams-razor]:https://en.wikipedia.org/wiki/Occam%27s_razor
[behat-hooks]: http://docs.behat.org/en/v2.5/guides/3.hooks.html
[symfony-process]:https://symfony.com/doc/current/components/process.html
