---
date: 2011-03-08 21:38:00+00:00
slug: setting-up-virtual-hosts-for-apache-on-ubuntu-for-local-development
title: Setting up virtual hosts for Apache on Ubuntu for local development
categories:
- Apache
- Linux
- Ubuntu
comments: false
draft: false
---

Lately I have been doing a lot of php development, and I am using Ubuntu Linux for it.

One of my biggest pains was/is setting up an alias or virtual host for the new project (yes, I am coming from the lazy windows world).

After a few tries and a lot of help from [Robert Basic](http://robertbasic.com/) I put together this post to remind me next time I get a bad case of stupid.
<!--more-->


So... First things first, I will assume that you have an Ubuntu setup with Apache web server installed, and that you are using gedit.



Fire up the terminal and type:

{{< codecaption lang="bash" >}}

sudo a2enmod vhost_alias

{{< /codecaption >}}


If you did not get any error messages and your return looks like below, you are on the right track.


{{< codecaption lang="bash" >}}

Enabling module vhost_alias.
Run '/etc/init.d/apache2 restart' to activate new configuration!

{{< /codecaption >}}




Next thing to do is to go to sites-available directory by typing

{{< codecaption lang="bash" >}}

cd /etc/apache2/sites-available/

{{< /codecaption >}}




OK, now we are in apaches directory where all the definition files for virtual hosts are. We want to copy the default template one, cryptically named default

{{< codecaption lang="bash" >}}

sudo cp default our-test-site

{{< /codecaption >}}




This will create a copy of the default template named our-test-site (you of course should substitute this with anything you wish).
Let's edit it, type

{{< codecaption lang="bash" >}}

sudo gedit our-test-site

{{< /codecaption >}}




This will open up the file in the editor, below are the contents of default vhost file (as usual YMMV if you did some customization)


{{< codecaption lang="bash" >}}


	ServerAdmin webmaster@localhost

	DocumentRoot /var/www

		Options FollowSymLinks
		AllowOverride None


		Options Indexes FollowSymLinks MultiViews
		AllowOverride None
		Order allow,deny
		allow from all


	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/

		AllowOverride None
		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		Order allow,deny
		Allow from all


	ErrorLog /var/log/apache2/error.log

	# Possible values include: debug, info, notice, warn, error, crit,
	# alert, emerg.
	LogLevel warn

	CustomLog /var/log/apache2/access.log combined

    Alias /doc/ "/usr/share/doc/"

        Options Indexes MultiViews FollowSymLinks
        AllowOverride None
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128




{{< /codecaption >}}




We need to add one line and edit two lines.

Add **ServerName our-test-site.local** just above the DocumentRoot directive (in front of line 4).

Edit **DocumentRoot /var/www** path on line 4 and set it to **/path-to-the-test-site-WITHOUT-trailing-slash**.
It should look something like this

{{< codecaption lang="bash" >}}
DocumentRoot /path-to-the-test-site-WITHOUT-trailing-slash
{{< /codecaption >}}

In case you did not notice my subtle hints, **there should NOT be a trailing slash at the end of the path**.



Edit path on line 9 and set it to **/path-to-the-test-site-WITH-trailing-slash/**.
It should look something like this

{{< codecaption lang="bash" >}}

DocumentRoot /path-to-the-test-site-WITHOUT-trailing-slash

{{< /codecaption >}}

In case you did not notice my subtle hints, **there SHOULD be a trailing slash at the end of the path**.



And there you have it, almost done, the virtual host file is setup.
Enable it by typing

{{< codecaption lang="bash" >}}

sudo a2ensite our-test-site

{{< /codecaption >}}


The response should look like this

{{< codecaption lang="bash" >}}

Enabling site our-test-site.
Run '/etc/init.d/apache2 reload' to activate new configuration!

{{< /codecaption >}}




At this point the virtual host setup is done, all that is left is to tell the server that our-test-site.local should be resloved to 127.0.0.1.
We do that by typing

{{< codecaption lang="bash" >}}

sudo gedit /etc/hosts

{{< /codecaption >}}

and adding 127.0.0.1	our-test-site.local after the localhost (line 1).

The entire hosts file should look like

{{< codecaption lang="bash" >}}

127.0.0.1	localhost
127.0.0.1	our-test-site.local
127.0.1.1	ubuntu-vm

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts

{{< /codecaption >}}




Save it, close the editor and finally type

{{< codecaption lang="bash" >}}

sudo /etc/init.d/apache2 restart

{{< /codecaption >}}

or

{{< codecaption lang="bash" >}}

sudo apache2ctl restart

{{< /codecaption >}}




So there you go, your virtual host is setup, open the browser and type http://our-test-site.local and enjoy.

**Update:**
In case you encounter problems accessing the content of the localhost, you should add the ServerName localhost into your default virtual host (as described above for the new virtual host).
Then disable and enable site, and restart the apache

{{< codecaption lang="bash" >}}

sudo a2dissite default
sudo a2ensite default
sudo /etc/init.d/apache2 restart

{{< /codecaption >}}


**Update 2:**
In your new virtual host file you should change your

{{< codecaption lang="bash" >}}

AllowOverride None

{{< /codecaption >}}

to

{{< codecaption lang="bash" >}}

AllowOverride All

{{< /codecaption >}}

for your first two directory nodes (the / one and the one with the path to your site).
That will allow all the .htaccess files to work properly and allow redirection.

And of course do not forget to

{{< codecaption lang="bash" >}}

sudo a2dissite our-test-site
sudo a2ensite our-test-site
sudo /etc/init.d/apache2 restart

{{< /codecaption >}}

