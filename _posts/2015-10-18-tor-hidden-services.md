---
layout: post
section-type: post
has-comments: true
title: TOR Hidden Services
category: tech
tags: ["privacy", "tor"]
---

Tor (The Onion Router) is a free and open-source software used for anonymous
communication and internet browsing. It routes traffic through a network of
servers, making it difficult to trace the origin of the traffic. One of the most
interesting features of Tor is the ability to create hidden services. A Tor
hidden service is a web service that its physical location is hidden from the
end user. The only difference for the end user is that instead of a url, an
onion address is used to reach the service.

A Tor hidden service will secure the physical location of your web service,
while it will be accessible only through the Tor network, which will also favor
the privacy of your service's end users. In order to create your own hidden
service, you first need to install Tor. Then, you need to setup the path where
you want to place your service's private and public keys, as well as its
listening port in the `torrc` configuration file:

```text
HiddenServiceDir /home/username/hidden-service/
HiddenServicePort 80 127.0.0.1:4000
```

Once you have restarted the Tor service, you can find your service's onion
address (public key) in the `HiddenServiceDir/hostname` file. It's important to
note that if someone gets their hands on your private key, they will be able to
steal your service's identity. Therefore, it's crucial to keep your private key
secure. To access your hidden service, simply run a Tor browser, paste the onion
address and you're live! Keep in mind that the first time you access the
service, it may take a few minutes to respond since the Tor network needs to map
your onion address to your service's IP address.

While using Tor, you should be mindful of giving away your personal identifiable
information, such as your location, name, phone number etc. Additionally, there
have been speculations about the NSA decrypting TLS, which may compromise the
security of your hidden service. However, the benefits of Tor and its hidden
services far outweigh the risks.
