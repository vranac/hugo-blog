---
date: 2013-01-08 20:32:08+00:00
slug: targeting-mongodb-driver-version-with-puppet
title: Targeting MongoDB driver version with Puppet
categories:
- Automation
- Linux
- Puppet
- Vagrant
tags:
- mongo
- pear
- puppet
- vagrant
comments: false
draft: false
---

As mentioned [here](2013/01/pear-packages-installation-under-vagrant-with-puppet/) for our current project we are using Vagrant and Puppet.
In the link above I described how I solved the pear packages installation under Puppet.

We are using Symfony 2.0.15 with MongoDB, I need to use version 1.2.9 to avoid the whole setSlaveOK hubbub as described [here](https://github.com/doctrine/mongodb/issues/66).
<!--more-->
The original puppet task we used looked like:
{{< codecaption lang="ruby" >}}
# install mongodb driver
exec { "/usr/bin/pecl install -f mongo-1.2.9":
    unless  => "/usr/bin/pecl info mongo",
    require => Exec["pear update-channels"]
}
{{< /codecaption >}}

Which would be great apart from one little detail, Puppet Pear setup executes the

{{< codecaption lang="bash" >}}
pear upgrade
{{< /codecaption >}}

command which updates all the pear packages and updates the MongoDB driver to the latest version (1.3.9 at the time of writing), which then breaks the project and

{{< codecaption lang="bash" >}}
sudo pecl install -f mongo-1.2.9
{{< /codecaption >}}

would have to be executed manually to bring order to chaos.

Luckily with a bit of shell scripting we can solve that by executing

{{< codecaption lang="bash" >}}
test `pecl info mongo | grep 'Release Version' | tr -s '[:blank:]' | cut -d ' ' -f3` != '1.2.9'
{{< /codecaption >}}

which will return 0 if the condition is true (namely Release Version number is **not** 1.2.9).

By adding the one-liner above to the onlyif parameter of the [exec](http://docs.puppetlabs.com/references/latest/type.html#exec) task we can ensure that if the MongoDB driver version is not 1.2.9 the task will be executed.

The task now looks like this, note the use of full path:
{{< codecaption lang="bash" >}}
# install mongodb driver
exec { "/usr/bin/pecl install -f mongo-1.2.9":
    require => Exec["pear update-channels"],
    onlyif => "/usr/bin/test `pecl info mongo | grep 'Release Version' | tr -s '[:blank:]' | cut -d ' ' -f3` != '1.2.9'"
}
{{< /codecaption >}}
