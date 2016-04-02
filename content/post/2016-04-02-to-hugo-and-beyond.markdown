---
date: 2016-04-02T16:06:51+02:00
title: To Hugo and Beyond
slug: to-hugo-and-beyond
categories:
    - octopress
    - migration
    - hugo
tags:
    - octopress
    - migration
    - hugo
comments: false
draft: false

---

So... It has come to this... Again...

I moved from Wordpress a long time ago in favor of Octopress, version 2.x at the time.
It worked beautifully, for a while, and then it was time to update, and it was messy, as it did not have a separate content from theme, but I chugged along, it wasn't like I was writing much.

Then a few months ago I wanted to use Octopress 3, and it was a mess, and when I finally got it running, my alloted time was at an end.

Fast forward two weeks ago, I wanted to write something, I wanted to use the latest version of Octopress, I tried to update, and it blew up in my face. That was the proverbial straw that broke the camels back. Time to look at alternatives.

I found this nice [website][staticgen] that displayed my options in a nice way. 
I did not want ruby all over again, nor javascript, I would prefer Python, and lo and behold I found [Pelican][pelican].

Pelican is awesome, pelican is extendable, plethora of themes, nice docs, a familiar language and syntax, everyhing I ever wanted, apart from one thing, and that is that every post can be only in one category, and by default it is blog. And this is a minor thing, but since I was shopping around for a replacement, I wanted to have as little changes as possible.

And so I came upon [Hugo][hugo], a general-purpose website framework written in Go. I haven't dug too deep into it, but it has all I need atm, an octopress like theme, ease of install (brew), just-works(tm).

There are some drawbacks, namely no archive page (something to play with when I have time), no easy way to deploy content to the website which I quickly fixed by slaming together a few bash commands (again something to play with in the future by adding makefile or fabric), but these are not show stoppers.

Hopefully this will get me back to writing short posts about a problem I am solving at that moment.

[staticgen]:https://www.staticgen.com/
[pelican]:http://blog.getpelican.com/
[hugo]:http://gohugo.io/
