# ICMP

## Description
The Internet Control Message Protocol (ICMP) is one of the main protocols of the Internet Protocol Suite. It is used by network devices, like routers, to send error messages indicating, for example, that a requested service is not available or that a host or router could not be reached. ICMP can also be used to relay query messages. It is assigned protocol number 1. ICMP differs from transport protocols such as TCP and UDP in that it is not typically used to exchange data between systems, nor is it regularly employed by end-user network applications (with the exception of some diagnostic tools like ping and traceroute).

## Structure
```
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|     Type      |     Code      |          Checksum             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                         Message Body                          +
|                                                               |
```

#### Type
Indicates the type of the packet.

#### Code
In case of an error, it indicates what problem happened.

#### Checksum
The checksum is the 16-bit ones's complement of the one's complement sum of the ICMP message starting with the ICMP Type.

#### Message Body
In case of an error, the message body is composed of 2 fields whose one's is a 4 bytes field of additional informations (given in the next section for each type of error). The other is defined by the Internet Header (IP) of the request packet plus the first 8 bytes of its payload.

#### Notable Control Messages

<table>
  <tr>
    <th>Type</th>
    <th>Code</th>
    <th>Status</th>
    <th>Description</th>
    <th>Class</th>
  </tr>
  <tr>
    <td>0 - Echo reply</td>
    <td>0</td>
    <td></td>
    <td>Used to ping</td>
    <td>ICMPv4EchoReply</td>
  </tr>
  <tr>
    <td>1 and 2</td>
    <td></td>
    <td>unassigned</td>
    <td><b>reserved</b></td>
    <td></td>
  </tr>
  <tr>
    <td rowspan="16" >3 - Destination unreachable</td>
    <td>0</td>
    <td></td>
    <td>Destination network unreachable</td>
    <td rowspan="16" >ICMPv4DestUnreach</td>
  </tr>
  <tr>
    <td>1</td>
    <td></td>
    <td>Destination host unreachable</td>
  </tr>
  <tr>
    <td>2</td>
    <td></td>
    <td>Destination protocol unreachable</td>
  </tr>
  <tr>
    <td>3</td>
    <td></td>
    <td>Destination port unreachable</td>
  </tr>
  <tr>
    <td>4</td>
    <td></td>
    <td>Fragmentation required, and DF flag set</td>
  </tr>
  <tr>
    <td>5</td>
    <td></td>
    <td>Source route failed</td>
  </tr>
  <tr>
    <td>6</td>
    <td></td>
    <td>Destination network unknown</td>
  </tr>
  <tr>
    <td>7</td>
    <td></td>
    <td>Destination host unknown</td>
  </tr>
  <tr>
    <td>8</td>
    <td></td>
    <td>Source host isolated</td>
  </tr>
  <tr>
    <td>9</td>
    <td></td>
    <td>Network administratively prohibited</td>
  </tr>
  <tr>
    <td>10</td>
    <td></td>
    <td>Host administratively prohibited</td>
  </tr>
  <tr>
    <td>11</td>
    <td></td>
    <td>Network unreachable for TOS</td>
  </tr>
  <tr>
    <td>12</td>
    <td></td>
    <td>Host unreachable for TOS</td>
  </tr>
  <tr>
    <td>13</td>
    <td></td>
    <td>Communication administratively prohibited</td>
  </tr>
  <tr>
    <td>14</td>
    <td></td>
    <td>Host Precedence Violation</td>
  </tr>
  <tr>
    <td>15</td>
    <td></td>
    <td>Precedence cutoff in effect</td>
  </tr>
  <tr>
    <td>4 - Source Quench</td>
    <td>0</td>
    <td>deprecated</td>
    <td>Source quench (congestion control)</td>
    <td>ICMPv4SourceQuench</td>
  </tr>
  <tr>
    <td rowspan="4">5 - Redirect Message</td>
    <td>0</td>
    <td></td>
    <td>Redirect Datagram for the Network</td>
    <td rowspan="4">ICMPv4Redirect</td>
  </tr>
  <tr>
    <td>1</td>
    <td></td>
    <td>Redirect Datagram for the Host</td>
  </tr>
  <tr>
    <td>2</td>
    <td></td>
    <td>Redirect Datagram for the TOS & network</td>
  </tr>
  <tr>
    <td>3</td>
    <td></td>
    <td>Redirect Datagram for the TOS & host</td>
  </tr>
  <tr>
    <td>6</td>
    <td></td>
    <td>deprecated</td>
    <td>Alternate Host Address</td>
    <td></td>
  </tr>
  <tr>
    <td>7</td>
    <td></td>
    <td>unassigned</td>
    <td>**reserved**</td>
    <td></td>
  </tr>
  <tr>
    <td>8 - Echo Request</td>
    <td>0</td>
    <td></td>
    <td>Used to ping</td>
    <td>ICMPv4EchoRequest</td>
  </tr>
  <tr>
    <td>9 - Router Advertisement</td>
    <td>0</td>
    <td></td>
    <td>Router Advertisement</td>
    <td></td>
  </tr>
  <tr>
    <td>10 - Router Solicitation</td>
    <td>0</td>
    <td></td>
    <td>Router discovery/selection/solicitation</td>
    <td></td>
  </tr>
  <tr>
    <td rowspan="2">11 - Time Exceeded</td>
    <td>0</td>
    <td></td>
    <td>TTL expired in transit</td>
    <td rowspan="2">ICMPv4TimeExceed</td>
  </tr>
  <tr>
    <td>1</td>
    <td></td>
    <td>Fragment reassembly time exceeded</td>
  </tr>
  <tr>
    <td rowspan="3">12 - Parameter Problem: Bad IP header</td>
    <td>0</td>
    <td></td>
    <td>Pointer indicates the error</td>
    <td rowspan="3">ICMPv4ParamProblem</td>
  </tr>
  <tr>
    <td>1</td>
    <td></td>
    <td>Missing a required option</td>
  </tr>
  <tr>
    <td>2</td>
    <td></td>
    <td>Bad length</td>
  </tr>
  <tr>
    <td>13 - Timestamp</td>
    <td>0</td>
    <td></td>
    <td>Timestamp</td>
    <td>ICMPv4TimestampRequest</td>
  </tr>
  <tr>
    <td>14 - Timestamp Reply</td>
    <td>0</td>
    <td></td>
    <td>Timestamp reply</td>
    <td>ICMPv4TimestampReply</td>
  </tr>
  <tr>
    <td>15 - Information Request</td>
    <td>0</td>
    <td>deprecated</td>
    <td>Information Request</td>
    <td>ICMPv4InformationRequest</td>
  </tr>
  <tr>
    <td>16 - Information Reply</td>
    <td>0</td>
    <td>deprecated</td>
    <td>Information Reply</td>
    <td>ICMPv4InformationReply</td>
  </tr>
  <tr>
    <td>17 - Address Mask Request</td>
    <td>0</td>
    <td>deprecated</td>
    <td>Address Mask Request</td>
    <td></td>
  </tr>
  <tr>
    <td>18 - Address Mask Reply</td>
    <td>0</td>
    <td>deprecated</td>
    <td>Address Mask Reply</td>
    <td></td>
  </tr>
  <tr>
    <td>19</td>
    <td></td>
    <td>**reserved**</td>
    <td>Reserved for security</td>
    <td></td>
  </tr>
  <tr>
    <td>20 through 29</td>
    <td></td>
    <td>**reserved**</td>
    <td>Reserved for robustness experiment</td>
    <td></td>
  </tr>
  <tr>
    <td>30 - Traceroute</td>
    <td>0</td>
    <td>deprecated</td>
    <td>Information Request</td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td></td>
    <td>deprecated</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>31</td>
    <td></td>
    <td>deprecated</td>
    <td>Datagram Conversion Error</td>
    <td></td>
  </tr>
  <tr>
    <td>32</td>
    <td></td>
    <td>deprecated</td>
    <td>Mobile Host Redirect</td>
    <td></td>
  </tr>
  <tr>
    <td>33</td>
    <td></td>
    <td>deprecated</td>
    <td>Where-Are-You (originally meant for IPv6)</td>
    <td></td>
  </tr>
  <tr>
    <td>34</td>
    <td></td>
    <td>deprecated</td>
    <td>Here-I-Am (originally meant for IPv6)</td>
    <td></td>
  </tr>
  <tr>
    <td>35</td>
    <td></td>
    <td>deprecated</td>
    <td>Mobile Registration Request</td>
    <td></td>
  </tr>
  <tr>
    <td>36</td>
    <td></td>
    <td>deprecated</td>
    <td>Mobile Registration Reply</td>
    <td></td>
  </tr>
  <tr>
    <td>37</td>
    <td></td>
    <td>deprecated</td>
    <td>Domain Name Request</td>
    <td></td>
  </tr>
  <tr>
    <td>38</td>
    <td></td>
    <td>deprecated</td>
    <td>Domain Name Reply</td>
    <td></td>
  </tr>
  <tr>
    <td>39</td>
    <td></td>
    <td>deprecated</td>
    <td>SKIP Algorithm Discovery Protocol, Simple Key-Management for Internet Protocol</td>
    <td></td>
  </tr>
  <tr>
    <td>40</td>
    <td></td>
    <td></td>
    <td>Photuris, Security failures</td>
    <td></td>
  </tr>
  <tr>
    <td>41</td>
    <td></td>
    <td>experimental</td>
    <td>ICMP for experimental mobility protocols such as Seamoby [RFC4065](https://www.ietf.org/rfc/rfc4065.txt)</td>
    <td></td>
  </tr>
  <tr>
    <td>42 through 252</td>
    <td></td>
    <td>unassigned</td>
    <td>**reserved**</td>
    <td></td>
  </tr>
  <tr>
    <td>253</td>
    <td></td>
    <td>experimental</td>
    <td>RFC3692-style Experiment 1 [RFC 4727](https://www.ietf.org/rfc/rfc4727.txt)</td>
    <td></td>
  </tr>
  <tr>
    <td>254</td>
    <td></td>
    <td>experimental</td>
    <td>RFC3692-style Experiment 2 [RFC 4727](https://www.ietf.org/rfc/rfc4727.txt)</td>
    <td></td>
  </tr>
  <tr>
    <td>255</td>
    <td></td>
    <td>reserved</td>
    <td>**reserved**</td>
    <td></td>
  </tr>
</table>

A general class ICMP is also provided.

## Reference

- Internet Control Message Protocol [RFC 777](https://www.ietf.org/rfc/rfc777.txt)
- Internet Control Message Protocol [RFC 792](https://www.ietf.org/rfc/rfc792.txt)
- Internet Control Message Protocol (ICMPv6) for the Internet Protocol Version 6 (IPv6) Specification [RFC 4443](https://www.ietf.org/rfc/rfc4443.txt)
