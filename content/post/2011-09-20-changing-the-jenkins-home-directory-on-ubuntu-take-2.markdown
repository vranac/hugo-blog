---
date: 2011-09-20 08:53:20+00:00
slug: changing-the-jenkins-home-directory-on-ubuntu-take-2
title: Changing the Jenkins home directory on Ubuntu - take 2
categories:
- Jenkins
- Linux
- Ubuntu
tags:
- ci
- jenkins
- ubuntu
comments: false
draft: false
---

A month ago, [Robert](http://robertbasic.com/blog/changing-jenkins-home-directory-on-ubuntu/) blogged about changing the Jenkins CI home directory on Ubuntu.
<!--more-->
Only thing I did not like was setting the path directly in the **DAEMON_ARGS** and excluding the **$JENKINS_HOME** variable.

It may not be a problem, but just in case, wouldn't it be better if we just defined the **$JENKINS_HOME** to point to the new home directory?
That way, any part of the Jenkins that relies on the **$JENKINS_HOME** will know where to look.

Instead of editing **/etc/init.d/jenkins**, and modifying it like Robert suggests to
{{< codecaption lang="bash" >}}
DAEMON_ARGS="--name=$NAME --inherit --env=JENKINS_HOME=/home/jenkins --output=$JENKINS_LOG --pidfile=$PIDFILE"
{{< /codecaption >}}

I would suggest editing the /etc/default/jenkins
{{< codecaption lang="bash" >}}
vi /etc/default/jenkins
{{< /codecaption >}}

And changing the **$JENKINS_HOME** variable (around line 23) to
{{< codecaption lang="bash" >}}
# jenkins home location
JENKINS_HOME=/home/jenkins
{{< /codecaption >}}

Then restart the Jenkins with usual
{{< codecaption lang="bash" >}}
/etc/init.d/jenkins start
{{< /codecaption >}}


