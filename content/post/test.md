+++
date = "2016-03-30T19:08:42+02:00"
title = "test"
slug="aye"
draft=true
+++

lorem

``` bash linenos=inline
cd

```

{{< highlight bash "linenos=inline" >}}

[group test]
writable = test
members = your_email_from_ssh_key

{{< /highlight >}}

{{< codecaption lang="html" >}}
<figure class="code">
  <figcaption>
    <span>{{ .Get "title" }}</span>
  </figcaption>
  <div class="codewrapper">
    {{ highlight .Inner (.Get "lang") "linenos=true" }}
  </div>
</figure>
{{< /codecaption >}}