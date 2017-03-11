---
title: "Adding Mockery to Symfony 2.3"
date: 2013-07-09 09:08:00+00:00
categories:
    - mockery
    - php,
    - phpunit
    - symfony
    - testing 
tags:
    - mockery
    - php
    - phpunit
    - symfony
    - testing
comments: false
draft: false
---

Mockery is an essential part of my toolset. You can get more information about mockery from the repo itself, or from nettuts+.

My current project in Symfony framework, 2.3 LTS, and I need to use mockery to make my life a whole lot easier.

The process consists of three steps, of which step 3 is least documented.

First you need to add mockery to your composer.json among other libs you will use

{{< codecaption lang="json" title="composer.json" >}}
"require-dev": {
    ....

    "mockery/mockery": "dev-master@dev"

    ....
},
{{< /codecaption >}}

Second step is to add the mockery listener to your phpunit.xml in the app dir

{{< codecaption lang="xml" title="phpunit.xml.dist" >}}
<listeners>
    <listener class="\Mockery\Adapter\Phpunit\TestListener"
        file="Mockery/Adapter/Phpunit/TestListener.php">
    </listener>
</listeners>
{{< /codecaption >}}

when you run the composer install, the composer will download the mockery from the repo, and install it in the vendors dir. 
The phpunit will know to use the listner, but the project itself have no idea what mockery is at this point, 
and where to find it. To fix that in `app/autoloader.php` before ‘return $loader;’

{{< codecaption lang="php" title="app/autoloader.php">}}
<?php

if (class_exists('PHPUnit_Runner_Version')) {
    set_include_path(get_include_path() . PATH_SEPARATOR . __DIR__.'/../vendor/mockery/mockery/library/');
    require_once('Mockery/Loader.php');
    $mockeryLoader = new \Mockery\Loader;
    $mockeryLoader->register();
}
{{< /codecaption >}}

And you are good to go…
