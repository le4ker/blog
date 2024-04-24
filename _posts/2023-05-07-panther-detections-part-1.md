---
layout: post
section-type: post
has-comments: true
title: Monitoring a Web Server with Panther - Part 2 (Detection)
category: tech
tags: ["security", "panther"]
---

[Last time]({% post_url 2023-04-17-panther %}) we configured
[Fluentd](https://www.fluentd.org/) to collect and transmit activity data from
my personal server to [Panther](https://panther.com/). Sinse then, I also
onboarded more data sources using [Zeek](https://zeek.org/) because "all data is
security data", and the more we have, the more sophisticated
[detections](https://panther.com/cyber-explained/detection-engineering-benefits/)
we'll be able to build.

In this post, we'll create our first detection. Our goal is to detect any
unexpected port that gets opened on the server, as we want to minimize the
attack surface of our server. Whenever an unexpected port is detected, we want
to be alerted immediately with a High level alert.

First, we'll use the `Custom.Netstat` schema that [we
built]({% post_url 2023-04-17-panther %}) using
[pantherlog](https://docs.panther.com/panther-developer-workflows/pantherlog) to
create a detection rule that triggers on unexpected open ports:

```python
allowed_open_ports = [
    '80',    # HTTP
    '443',   # HTTPS
    '22',    # SSH
    '53',    # DNS
    '47760', # Zeek
]

def get_open_port(event):
    port_delimiter = ':'
    port_index = event['local_address'].rfind(port_delimiter) + 1
    open_port = event['local_address'][port_index:]

    return open_port

def rule(event):
    # Return True to match the log event and trigger an alert.
    open_port = get_open_port(event)

    if open_port not in allowed_open_ports:
        return True

    return False

def title(event):
    # (Optional) Return a string which will be shown as the alert title.
    # If no 'dedup' function is defined, the return value of this method will act as deduplication string.
    open_port = get_open_port(event)

    return f"Unexpected Port Opened: {open_port}"
```

Next, we'll test our detection with a few test cases:

![test_http](/img/posts/panther-detections/test-1.png)

![test_triggers](/img/posts/panther-detections/test-2.png)

As we can see, the detection works as expected. To further validate our
detection, we'll start the FTP daemon on our server using the following command:

```bash
systemctl start vsftpd.service
```

Less than a minute later, the detection triggers a High level alert:

![alert](/img/posts/panther-detections/alert-port-21.png)

In the next post, we'll continue building detections, and we'll detect
successful Tor SSH authentications to trigger Critical level alerts.
