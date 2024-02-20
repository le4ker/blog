---
layout: post
section-type: post
has-comments: true
title:
  "Enhancing Web Server Security with Event Monitoring and Detection - Part 3:
  Enrichment"
category: tech
tags: ["security", "panther"]
---

[Last time]({% post_url 2023-05-07-panther-detections-part-1 %}), we built a
detection that alerts us when an unexpected port is opened on the server. How
about creating an alert whenever a successful SSH connection is established from
a TOR exit node? I would never SSH to my personal server over TOR, so such
activity would be a clear signal of compromise.

We can retrieve any connection attempt using the
[Zeek.Conn](https://docs.panther.com/data-onboarding/supported-logs/zeek#zeek.conn)
managed schema. However, how can we classify the originating IP as a TOR exit
node? Note that this is a dynamic piece of information since TOR exit nodes are
constantly being added or removed.

Panther has a solution for this called
[Enrichment](https://docs.panther.com/enrichment). Enrichment provides external
data sources that you can pull into Panther and
[join them against your schemas](https://docs.panther.com/enrichment/lookup-tables)
on a field, such as an IP address. This information is then available within the
JSON `event` that detections process, and you can use provided helper functions
to easily access the enriched data.

After enabling the
[TOR Lookup Tables](https://github.com/panther-labs/panther-analysis/blob/master/packs/tor.yml)
pack and its enrichment provider, all IP addresses within Panther's managed
schemas will be enriched with TOR exit node data, whenever they match a TOR exit
node IP address that Panther is periodically pulling. If `Zeek.Conn` was not a
managed schema, we would simply specify the IP field of the custom schema to be
enriched in the TOR Lookup Table.

Enrichment data is placed under `p_enrichment`, followed by the selector of each
enrichment provider and the fields of each enrichment schema. In the case of TOR
Exit Nodes and using the `Zeek.Conn` schema (and the `id_orig_h` field as the
selector), the incoming event would be enriched with the following data:

```json
"p_enrichment": {
    "tor_exit_nodes": {
        "id_orig_h": {
            "ip": "3.86.140.74"
        }
    },
    "p_any_ip_addresses": [
        "3.86.140.74"
    ]
},
```

We can use the following helper provided to detect whether the incoming
connection originated from a TOR exit node:

```python
import panther_tor_helpers as p_tor_h

p_tor_h.TorExitNodes(event).has_exit_nodes()
```

Now let's build a heuristic that will detect successful SSH connections as a new
helper, so we can reuse it in other detections as well:

```python
# zeek_helpers.py
SSH_PORT = 22

ID_ORIG_H = 'id_orig_h'
ID_RESP_P = 'id_resp_p'
CONN_STATE = 'conn_state'
HISTORY = 'history'

def get_originator_ip(event):
    return event[ID_ORIG_H]

def successfull_ssh_connection(event):
    return event[ID_RESP_P] == SSH_PORT and \
        event[CONN_STATE] == 'S0' and \
        event[HISTORY] == 'ScADCc' \
```

And combining them we can now write our detection:

```python
import zeek_helpers as zeek_h
import panther_tor_helpers as p_tor_h

def rule(event):
    # Return True to match the log event and trigger an alert.

    if not zeek_h.successfull_ssh_connection(event):
        return False

    connection_from_tor = p_tor_h.TorExitNodes(event).has_exit_nodes()

    return connection_from_tor

def title(event):
    # (Optional) Return a string which will be shown as the alert title.
    ip = zeek_h.get_originator_ip(event)
    return f"SSH Connection Established from TOR Exit Node ({ip})"
```

Let's try an SSH connection from TOR using
[proxychains]({% post_url 2017-03-24-proxychains %}):

![ssh-tor](/img/posts/panther-enrichment//tor-ssh.png)

Less than a minute later, the new detection alerts:

![alert-tor-ssh](/img/posts/panther-enrichment/alert-tor-ssh.png)

Since the Zeek helpers are in place, why not enable
[GreyNoise](https://docs.panther.com/enrichment/greynoise) enrichment as well,
so we can alert on SSH connections that are established from malicious IP
addresses?

After enabling the
[GreyNoise Basic](https://github.com/panther-labs/panther-analysis/blob/master/packs/greynoise_basic.yml)
pack and the relevant Lookup table, the new detection that will alert when a
malicious IP address connects over SSH will look like this:

```python
import zeek_helpers as zeek_h
import panther_greynoise_helpers as p_greynoise_h

def rule(event):
    # Return True to match the log event and trigger an alert.
    if not zeek_h.successfull_ssh_connection(event):
        return False

    classification = p_greynoise_h.GreyNoiseBasic(event).classification(zeek_h.ID_ORIG_H)

    return classification == 'malicious'

def title(event):
    # (Optional) Return a string which will be shown as the alert title.
    ip = zeek_h.get_originator_ip(event)
    return f"SSH Connection Established from Malicious IP {ip}"
```
