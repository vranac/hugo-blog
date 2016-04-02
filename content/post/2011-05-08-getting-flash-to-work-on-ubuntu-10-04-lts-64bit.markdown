---
date: 2011-05-08 15:31:25+00:00
slug: getting-flash-to-work-on-ubuntu-10-04-lts-64bit
title: Getting Flash to work in Chrome on Ubuntu 10.04 LTS 64bit
comments: false
draft: false
---

This is a digest from a bunch of information from the web.
If Flash is not working in your Chrome browser you may need to create the following symlink to get it working

{{< codecaption lang="bash" >}}

sudo ln -s /usr/lib64/mozilla/plugins-wrapped/nswrapper_32_64.libflashplayer.so \
/usr/lib/mozilla/plugins/

{{< /codecaption >}}


As usual YMMV, have fun.
