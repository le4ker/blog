---
layout: post
section-type: post
title: "Introducing a Suite of Whitehat Rootkits for the Linux kernel"
category: tech
tags: ["security", "opensource"]
---

Rootkits are malicious binaries that run in the kernel of an operating system, which essentially gives them god-like powers over the entire machine.
While it's true that you need root permissions to add a rootkit to the kernel, social engineering and zero-day vulnerabilities can make this a relatively easy feat.
After a rootkit is installed, it can cause extensive damage to your system by performing various malicious activities, like concealing files and processes, deploying malware, exfiltrating passwords and certificates, and logging all user activity on your machine.
To achieve all this, rootkits often alter the system call table, which can be a scary thought for anyone who values their online privacy and security.

In order to mitigate such a risk, I developed the following kernel modules which can prevent and detect rootkit activities.
[The Drip Dry Carbonite](https://github.com/le4ker/linux-kernel-security-suite/tree/master/the-drip-dry-carbonite) protects the system call table and logs snapshots of the running processes.
In case an attempt is made to modify the table, the machine is frozen to prevent any further damage.
[Dresden](https://github.com/le4ker/linux-kernel-security-suite/tree/master/dresden) blocks any attempts to insert rootkits into the kernel, while also dumping the instruction memory and logging a critical message.
[Netlog](https://github.com/le4ker/linux-kernel-security-suite/tree/master/netlog) logs all network activity by probing the inet stack of the kernel.

In the future, I'll be sharing some interesting snippets of the source code for these rootkits.
While there are ways to protect yourself from rootkits, they are a moving target, and the threat of new and innovative attacks is always present.
