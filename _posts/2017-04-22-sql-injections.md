---
layout: post
section-type: post
has-comments: true
title: Exploiting SQL Injections to Access User Passwords
category: tech
tags: ["security", "redteam"]
---

In this post, we'll demonstrate how to exploit SQL injections in the [DVWA web
app]({% post_url 2017-04-02-dvwa-kali %}) to access user passwords. SQL
injections are similar to other attacks such as
[XSS]({% post_url 2017-04-15-dvwa-xss %}) and [command
injection]({% post_url 2017-04-18-command-injection %}) where user input is not
sanitized and can manipulate the vulnerable application.

Let's navigate to the SQL Injection section of DVWA and examine its source code:

![sqli](/img/posts/sqli/sqli-source.png)

As you can see, the web app queries the users table for a given ID value, which
is provided by the user and is not sanitized. Then, the results are iterated and
returned to the client.

First, let's use the web app to query user ID 1:

![sqli](/img/posts/sqli/sqli.png)

Now, let's inject a condition that will always be true in order to read all
tuples from the users table:

```bash
' OR ''='
```

![sqli](/img/posts/sqli/sqli-0.png)

Although we know the web app is vulnerable, the data we obtained is not that
interesting. We could enumerate the IDs manually and get the same results, which
does not provide unauthorized access to data. So, how can we access columns
other than the first and last names?

Let's try to append a SQL query after the web app's query:

```bash
'; SELECT password FROM users WHERE user_id = '1
```

However, this attempt did not work and we received the following error message:

> You have an error in your SQL syntax; check the manual that corresponds to
> your MySQL server version for the right syntax to use near 'SELECT password
> FROM users WHERE user_id = '1'' at line 1

This error occurred because the mysqli_query does not allow the execution of
more than one query in a single call. To address this limitation, we can use the
SQL UNION operator. The UNION operator expects two result table operands with
the same number of columns and appends the second table at the end of the first
one. We can close the web app's query and then do a UNION on our injected query,
which will ask for the passwords column of the users table:

```bash
' UNION SELECT user_id, password FROM users #
```

Note that we are commenting out the web app's SQL query that comes after our
injected one by using the `#` character.

![sqli-passwords](/img/posts/sqli/sqli-passwords.png)

It worked, as you'll notice the passwords are hashed, but we will cover how to
crack them in another post.
