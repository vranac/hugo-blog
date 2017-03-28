---
date: 2017-03-28T16:25:42+02:00
draft: false
title: Running ERD in docker
categories:
    - Docker
    - Haskell
    - ERD
tags:
    - Docker
    - Haskell
    - ERD
---

Recently we started developing a new system on a project, and I needed to create
the Entity Relationship Diagram. This time I wanted something simple, where
I could just type it out, and the utility would spit out the file in format I need.

After some search I found this interesting tool called [ERD][erd], it was written
in Haskell, and it seemed to do just what I wanted.

But as usual something had to give, and in this case it was the setup on OSX.
Haskell install was simple, but then installing ERD itself proved to be very
error prone, and building it from scratch was a long operation, and it required
a few undocumented steps (discoverable in issues and PR's). Unleashing that kind
of inconvenience on myself, and my team was absolutely out of the question.

I mean, there has to be a better way...
Of course there is, and it gives me a chance to play with Docker as well.

So, I put together a Docker image available on [Docker Hub][erdhub].
It is based on official Haskell image, to get it you need to execute

{{< codecaption lang="bash" >}}
docker pull vranac/erd
{{< /codecaption >}}

and once that is done you can use it, by executing the following command

{{< codecaption lang="bash" >}}
docker run --rm -v $(pwd):/data -w /data vranac/erd -i INPUT_FILENAME.er -o OUTPUT_FILENAME.fmt
{{< /codecaption >}}

Replace the `INPUT_FILENAME.er` and `OUTPUT_FILENAME.fmt` with your ERD input file
and your desired outputfile in format you specify by extension.

For help, execute

{{< codecaption lang="bash" >}}
docker run --rm -v $(pwd):/data -w /data vranac/erd
{{< /codecaption >}}

The above command can also be aliased for ease of use.

The downside of this image is it's size, as it is based on Debian, in coming weeks
I will try to figure out if it is possible to make it smaller.

[erd]: https://github.com/BurntSushi/erd
[erdhub]: https://hub.docker.com/r/vranac/erd/
