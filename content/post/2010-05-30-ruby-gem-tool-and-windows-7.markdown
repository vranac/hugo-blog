---
date: 2010-05-30 18:30:26+00:00
slug: ruby-gem-tool-and-windows-7
title: Ruby Gem tool and Windows 7
categories:
- Rails
- Ruby
- Windows
tags:
- command prompt
- Gem
- Rails
- ROR
- Ruby
- windows 7
comments: false
draft: false
---

While trying to setup the RoR with XAMPP on my windows 7 machine I encoundered an error

{{< codecaption lang="bash" >}}

ERROR:  While executing gem ... (Errno::EEXIST)

{{< /codecaption >}}

while trying to run

{{< codecaption lang="bash" >}}

gem install rails --include-dependencies

{{< /codecaption >}}


Turns out none of the other gem commands worked.

The solution is simple, you need to run the command prompt with elevated privileges (run as admin) to get it to work.

