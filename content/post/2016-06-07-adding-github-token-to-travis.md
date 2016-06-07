---
date: 2016-06-07T13:35:15+02:00
draft: false
title: Adding GitHub token to Travis CI configuration
categories:
    - CI
    - TravisCI
    - GitHub
tags:
    - CI
    - TravisCI
    - GitHub
---

We are using Travis CI for our projects, and as we are using PHP a lot, and as great
as composer is, constantly pulling in the full source for dependencies it can become tedious
when you are constantly building and running tests (yes yes, I know I can limit
the branches which are run).
Luckily for us, composer provides a nice `--prefer-dist` option that will download
the distribution package/zip that can save you a lot of time.

From the manual:

> --prefer-dist: Reverse of --prefer-source, Composer will install from dist if possible. This can speed up installs substantially on build servers and other use cases where you typically do not run updates of the vendors. It is also a way to circumvent problems with git if you do not have a proper setup.

Which is great, except you will be running into GitHub imposed limits, and you will get a nice message saying:

{{< codecaption lang="text" >}}
GitHub rate limit reached. To increase the limit use GitHub authentication.
{{< /codecaption >}}

Well this kind of sucks, so what can be done?

For starters you can, and should, generate the github personal access token,
explained nicely [here][gh-oauth]

Awesome, now that you have an oauth token, and you could paste it into your travis config,
and commit it, and ...

Well, you can't, as GitHub is actively scanning the repos for oauth tokens, and if it detects one,
it gets disabled, so now we are back to square two.

Travis provides a nice solution to this problem called Encrypted Variables.
As great as this sounds, the question of "How does one encrypts a variable?" remains.

It turns out, solution is pretty straight forward.

Start by finding out the version of Ruby you have installed (if any) by running

{{< codecaption lang="bash" >}}
$ ruby -v
ruby 2.0.0p648 (2015-12-16 revision 53162) [universal.x86_64-darwin15]
{{< /codecaption >}}

If you do not have Ruby installed, google for solution related to your OS.

Then you need to install the travis gem, at the time of writing the version is `1.8.2`

To find out which is the latest version of travis gem available you need to run the following comamnd

{{< codecaption lang="bash" >}}
$ gem search travis

*** REMOTE GEMS ***
...
travis (1.8.2)
...
{{< /codecaption >}}

OK, so you now know that the latest verion is `1.8.2`, you can now install it by running

{{< codecaption lang="bash" >}}
$ gem install travis -v 1.8.2 --no-rdoc --no-ri
{{< /codecaption >}}

It may take some time for the command to complete.

Optionally, after the command has completed, check the version that was installed
{{< codecaption lang="bash" >}}
$ travis version
{{< /codecaption >}}

You may get asked about shell completion,
{{< codecaption lang="bash" >}}
Shell completion not installed. Would you like to install it now? |y|
{{< /codecaption >}}

Answer to your preference, and you will finally see the travis gem version
{{< codecaption lang="bash" >}}
Shell completion not installed. Would you like to install it now? |y|
1.8.2
{{< /codecaption >}}

OK, now you are ready to encrypt the variable, still, there are a few things you need to know.
The token can be reused as much as you want, **BUT the encryption must be done against
a particular github repo**. For simplicity, I am going to assume you are in you repo directory,
and will demonstrate how to do it from anywhere later.

If this is your first time running travis gem, you will have to authenticate against GitHub.
You can do this by running the following command, the `--pro` switch is optional unless
you are on paid account.

{{< codecaption lang="bash" >}}
$ travis login --pro
We need your GitHub login to identify you.
This information will not be sent to Travis CI, only to api.github.com.
The password will not be displayed.

Try running with --github-token or --auto if you don't want to enter your password anyway.

Username: <username>
Password for <username>: ************
Two-factor authentication code for <username>: XXXXXX
Successfully logged in as <username>!
{{< /codecaption >}}

Alrighty then, now you are logged in...

Lets Encrypt!

Run the following command, and, of course,
replace the `<YOUR_GITHUB_TOKEN>` with your token

{{< codecaption lang="bash" >}}
$  travis encrypt 'GITHUB_TOKEN=<YOUR_GITHUB_TOKEN>'
Detected repository as <YOUR_REPO_NAME>, is this correct? |yes|
Please add the following to your .travis.yml file:

  secure: "<LONG_STRING_OF_ENCRYPTED_CHARACTERS>"
{{< /codecaption >}}

Now, if you are a lazy person, you can add `--add` to the end of the command
and travis gem will add what is needed to your travis configuration for the repo.

IF you want to encrypt against a different repo, you can add the `-r` or `--repo` switch to
the command, followed by repo slug(everything in the repo url after `http://www.github.com/`)

{{< codecaption lang="bash" >}}
$  travis encrypt 'GITHUB_TOKEN=<YOUR_GITHUB_TOKEN>' -r <REPO_SLUG>
{{< /codecaption >}}

So now that you have your encrypted string, you can add it to your travis config

{{< codecaption lang="yaml" >}}
...
env:
  global:
    secure: <LONG_STRING_OF_ENCRYPTED_CHARACTERS>

before_install:
  - composer config --global github-oauth.github.com "$GITHUB_TOKEN"

install:
  - composer install --dev --prefer-dist

...
{{< /codecaption >}}

Lines 2-4 are your encrypted variable values, do replace
`<LONG_STRING_OF_ENCRYPTED_CHARACTERS>` with the output of the `travis encrypt` command.
Now you have the encrypted variable values added to your travis configuration, congratulations.

On line 7 you will actually be using the GitHub token by adding `"$GITHUB_TOKEN"`, travis
will know that is is a encrypted variable, and will decrypt and replace it.

With all this in place, you can now use `--prefer-dist`, and not have to worry about
GitHub limits.


[gh-oauth]: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
[travis-encrypted-vars]: https://docs.travis-ci.com/user/environment-variables/#Encrypted-Variables


