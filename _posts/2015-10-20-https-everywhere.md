---
layout: post
section-type: post
has-comments: true
title: Expanding HTTPS Everywhere's Domain Support
category: tech
tags: ["privacy", "opensource"]
---

_Update: You no longer need HTTPS Everywhere to set HTTPS by default, major
browsers now offer native support for an HTTPS only mode_

HTTPS Everywhere is a collaboration project between the Tor Project and the
[Electronic Frontier Foundation (EFF)](https://www.eff.org/). It's a browser
extension for Firefox, Chrome, and Opera that always opts in for HTTPS
communication for every known domain that supports it. Tracking which domains
support HTTPS communication is not an easy task and requires a community to
support this.

Let's see how you can help improve the repository of the tracked domains that
support HTTPS. When you come across a website that is served over HTTP, try
accessing it with HTTPS. If it works, you can easily add a rule for that
website. To do this, fork the GitHub repository, navigate to
`src/chrome/content/rules`, and run the following command:

```bash
./make-trivial-rule &lt;domain&gt;
```

For example, to generate a trivial rule for `di.uoa.gr`, run:

```bash
./make-trivial-rule di.uoa.gr
```

This will generate a default rule set file that looks like this:

```xml
&lt;ruleset name="National and Kapodistrian University of Athens - Department of Informatics and Telecommunications"&gt;
  &lt;target host="di.uoa.gr" /&gt;
  &lt;target host="www.di.uoa.gr" /&gt;
  &lt;rule from="^http:" to="https:" /&gt;
&lt;/ruleset&gt;
```

Once you've created the rule, open a pull request on the HTTPS Everywhere GitHub
repository. This is a quick and easy way to contribute to enhancing the privacy
and security of many.
