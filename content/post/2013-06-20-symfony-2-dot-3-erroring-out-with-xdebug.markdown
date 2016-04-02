---
title: "Symfony 2.3 erroring out with Xdebug"
date: 2013-06-20 18:08:00+00:00
categories:
    - symfony
    - xdebug
    - php
comments: false
draft: false
---
When working with Symfony 2.3 there is a chance that xdebug will start erroring out with "Maximum function nesting level of '100' reached, aborting!" pretty quick.
<!--more-->
To solve it, add
{{< codecaption lang="ini" >}}
xdebug.max_nesting_level = 1000
{{< /codecaption >}}

into your xdebug.ini file.

It will make your life a whole lot easier...