---
layout: post
section-type: post
has-comments: true
title: "Introducing a Suite of Whitehat Rootkits for the Linux kernel"
category: tech
tags: ["security", "opensource"]
---

Rootkits are malicious binaries that run in the kernel of an operating system,
which essentially gives them god-like powers over the entire machine. While it's
true that you need root permissions to add a rootkit to the kernel, social
engineering and zero-day vulnerabilities can make this a relatively easy feat.
After a rootkit is installed, it can cause extensive damage to your system by
performing various malicious activities, like concealing files and processes,
deploying malware, exfiltrating passwords and certificates, and logging all user
activity on your machine. To achieve all this, rootkits often alter the system
call table, which results in the user being unable to detect the malicious
activity and behaviour.

In order to mitigate risks, I built the following kernel modules which can
prevent and detect rootkit activities.

**[The Drip Dry Carbonite](https://github.com/le4ker/linux-kernel-security-suite/tree/master/the-drip-dry-carbonite)**
protects the system call table and logs snapshots of the running processes. In
case an attempt is made to modify the table, the machine is frozen to prevent
any further damage.

**[Dresden](https://github.com/le4ker/linux-kernel-security-suite/tree/master/dresden)**
blocks any attempts to insert rootkits into the kernel, while also dumping the
instruction memory and logging a critical message. As long as this module is the
last one inserted in the kernel after its boot, then it will be able to prevent
any rootkit that tries to load itself into the kernel.

**[Netlog](https://github.com/le4ker/linux-kernel-security-suite/tree/master/netlog)**
logs all network activity by probing the inet stack of the kernel in order to be
used for forensic analysis in case of a security breach.

In the future, I'll be sharing some interesting snippets of the source code of  
these rootkits. While there are ways to protect yourself from rootkits, they are
a moving target, which means that you have to constantly advance your defensive
tools in order to keep up with the latest threats.
