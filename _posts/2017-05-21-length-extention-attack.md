---
layout: post
section-type: post
has-comments: true
title: "Understanding Length Extension Attacks in Digital Signature Schemes"
category: tech
tags: ["security", "redteam", "crypto"]
---

Digital signatures are a crucial tool in the digital world, used to verify the
authenticity and integrity of a message. Essentially, they provide a way to
prove that you sent a piece of data and that it was not tampered with in
transit. However, if the signature scheme is not designed correctly, it can be
exploited in order to corrupt data without being detected.

The way digital signatures work is by operating on a secret key that is shared
between the parties who need to use the authentication scheme, the data that
needs to be signed, and a mathematical function. To generate a signature, you
apply the mathematical function to the secret key and the data, resulting in a
signature that is transmitted along with the message.

When the message and signature are received, the receiver performs the same
computation and compares the resulting signature with the transmitted one. If
the signatures match, the receiver knows that the message came from you and that
the data was not tampered with.

However, if the digital signature scheme is not properly designed, there are
several potential problems that can arise. For example, if the secret key is not
kept secure, an attacker could steal the key and generate fraudulent signatures.
Similarly, if the mathematical function used to generate the signature is weak
or flawed, it may be possible for an attacker to generate a fraudulent signature
without knowing the secret key.

Such an example is the
[Merkle–Damgård construction](https://en.wikipedia.org/wiki/Merkle%E2%80%93Damg%C3%A5rd_construction)
applied on the secret key appended by the message:

```bash
H(secret | message)
```

The digital signature scheme being discussed is susceptible to length extension
attacks, which means that if an attacker has knowledge of the message, the
length of the secret key used to sign it, and the resulting digest, they can
generate a signature for a new message that is appended to the original message,
without needing to know the secret key. To understand this type of attack, it's
important to first understand how the Merkle–Damgård construction works.

The Merkle–Damgård construction works by padding the message so that its length
is divisible by a specific value, which is a requirement for the algorithm to
work properly. For instance, in the case of SHA-256, this value is 512. The
padding scheme for the Merkle–Damgård construction involves appending a 1 bit to
the end of the message, followed by 0s and then the length of the original
message, until the total length is a multiple of the chosen value. This ensures
that the resulting padded message has a fixed length that can be processed by
the algorithm.

For example, the message _"Hello world"_ would be padded to:

```bash
# H    e    l    l    o         w    o
0x48 0x65 0x6c 0x6c 0x6f 0x20 0x77 0x6f
#  r    l    d   1
0x72 0x6c 0x64 0x80 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x58
                                   # 88
```

The _compression function_, denoted as f, is applied to each 256-bit block of
the message and the previous result of the compression function. For the first
round, a fixed value called the Initialization Vector (IV) is used as the output
of the "previous" compression function. The result of f is then used as the
input for the next round of compression, and so on. Once the compression
function has been applied to all the blocks of the message, the final result is
the digest of the hash function:

![merkle](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Merkle-Damgard_hash_big.svg/800px-Merkle-Damgard_hash_big.svg.png)

Given the signing scheme, the length of the secret used, the original message
and its digest, and a hash function that behaves as described earlier, it is
possible to forge an authentic signature by continuing the compression rounds on
an arbitrary message that is appended to the original message. This type of
attack is known as a length extension attack.

Essentially, an attacker can use the information provided above to calculate an
intermediate state of the hash function after it has processed the original
message. The attacker can then use this intermediate state as the initial state
for processing the appended message. By doing so, the attacker can generate a
new digest that is the same as the original digest, but for a different message.

Let's consider the scenario where we have the authentic signature of the message
_message_ when the secret _secret_ is applied:

```bash
SHA256('secret' | 'message') -> '33dd93031495b1e73b345ef5b7f494146d6c361908b4f2ad9cf7bbd35cffaa26'
```

Our objective is to generate a new signature on a message that is appended to
the "message" string, without having access to the secret that was used to sign
the original message. In order to accomplish this, we need to create a modified
version of the SHA-256 hash function that allows for the injection of the
Initialization Vector and the length of the input message:

```ruby
class SHA256

  def self.digest(input)

    input = input.force_encoding('US-ASCII')

    return self.inner_digest(
            input,
            # Original initialization vector of SHA-256
            [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19],
            input.length)
  end

  def self.inner_digest(input, z, length)
    # Padding and compression rounds of SHA-256
  end
end
```

When we call the digest function, we receive the anticipated SHA-256 digest of
the input. However, if we invoke the inner_digest function using the intercepted
digest as the initialization vector and the length of the known message plus the
data we wish to append, we can proceed with the compression function
calculations, as if we possessed the secret!

Let us compute the signature of _messageforged_ by injecting the intercepted
signature as the Initialization Vector of our first compression round:

```ruby
input = 'forged'.force_encoding('US-ASCII')
puts 'Forged signature:       ' + SHA256.inner_digest(input, [0x33dd9303, 0x1495b1e7, 0x3b345ef5, 0xb7f49414, 0x6d6c3619, 0x08b4f2ad, 0x9cf7bbd3, 0x5cffaa26], 70)
# Forged signature:       f9f333d547088763f8767a241baae7b50532f95a5ad75071a8e2960bc430fd37
```

Next, we need to create the message that will produce an authentic signature
that matches the forged signature we just computed. We can do this by
calculating the padding that the original signer of the forged message would
apply:

```ruby
input = 'message'.force_encoding('US-ASCII')

# Construct the padding so when our message is appended on the secret, then our 'forged' string is pushed to the next block message
length = (input.length + 6) * 8
input << 0x80
input << 0x00 while (input.size + 6) % 64 != 56
input += [length].pack('Q').reverse
input += 'forged'
```

For the following message:

```bash
#  m    e    s    s    a    g    e   1
0x6d 0x65 0x73 0x73 0x61 0x67 0x65 0x80
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
#     104    f    o    r    g    e    d
0x00 0x68 0x66 0x6f 0x72 0x67 0x65 0x64
```

The authentic signature would be:

```bash
SHA256('secret' | input) -> 'f9f333d547088763f8767a241baae7b50532f95a5ad75071a8e2960bc430fd37'
```

Our computation has been successful, which guarantees that our message will pass
the integrity check and be authenticated without any issues.

You can find the complete source code
[here](https://gist.github.com/le4ker/58fda8b16f12a4b52790b0011322d4c9).
