---
date: 2016-09-28T13:07:40+02:00
draft: false
title: Deleting keys with wildcards in Redis
categories:
    - Redis
    - Lua
    - PHP
tags:
    - Redis
    - Lua
    - PHP
---

So, for you who don't know [Redis][redis] is an

> open source (BSD licensed), in-memory data structure store, used as database, cache and message broker

Or to put it simply, it is a **Key/Value Store and so much more**

You have different data structures, that are efficient and great and all, that are at the end of the day identified by their keys,
and this is where my problem begins.

I have some 100k+ hashes in redis with keys in the form of `yer:key:harry:xxxyyzz`.
Which means that when I need to purge them from the application,
I could just use `yer:key:harry:*` and be sure that only those hashes
would be purged and not anything else of value.

So I looked at the [del][redis-docs-del] keyword in redis, and found out it can't
do wildcards. Isn't that fun...

But, I can run LUA scripts by using [eval][redis-docs-eval] command.
So I google a bit and put together this piece of erm... code.

{{< codecaption lang="lua" >}}
local keys = redis.call('keys', ARGV[1])
 for i=1,#keys,5000 do
  redis.call('del', unpack(keys, i, math.min(i+4999, #keys)))
 end
return keys
{{< /codecaption >}}

What the above does is call the [keys][redis-docs-keys] with arguments passed `ARGV[1]` and then calls the [del][redis-docs-del] with nice 5000 item slices,
so as to avoid [Redis][redis] choking

So when you put it together with [eval][redis-docs-eval] the command looks like

{{< codecaption lang="lua" >}}
EVAL "local keys = redis.call('keys', ARGV[1]) \n for i=1,#keys,5000 do \n redis.call('del', unpack(keys, i, math.min(i+4999, #keys))) \n end \n return keys" 0 yer:key:harry:*
{{< /codecaption >}}

Second argument is the number of arguments that follows the script (starting from the third argument) that represent Redis key names, in this case it is 0.

The third argument is actually your wildcarded key name.

And since I am using PHP and [phpredis][phpredis], the full command is

{{< codecaption lang="php" >}}
$client->eval("local keys = redis.call('keys', ARGV[1]) \n for i=1,#keys,5000 do \n redis.call('del', unpack(keys, i, math.min(i+4999, #keys))) \n end \n return keys", ["yer:key:harry:*"], 0);
{{< /codecaption >}}

Notice that the second argument is wildcaded key name **THAT MUST BE PASSED AS ARRAY**, and that the third argument is second argument in the [Redis][redis] lua example

With this in place, I can delete my keys in bulk, and go back to being productive.


[redis]: http://redis.io
[redis-docs-del]: http://redis.io/commands/del
[redis-docs-eval]: http://redis.io/commands/eval
[redis-docs-keys]: http://redis.io/commands/keys
[phpredis]: https://github.com/phpredis/phpredis

