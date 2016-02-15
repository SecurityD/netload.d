# UDP
## Description

The User Datagram Protocol (UDP) uses a simple connectionless transmission model with a minimum of protocol mechanism. It has no handshaking dialogues, and thus exposes the user's program to any unreliability of the underlying network protocol. There is no guarantee of delivery, ordering, or duplicate protection. UDP provides checksums for data integrity, and port numbers for addressing different functions at the source and destination of the datagram.

## Structure
```
0      7 8     15 16    23 24    31
+--------+--------+--------+--------+
|     Source      |   Destination   |
|      Port       |      Port       |
+--------+--------+--------+--------+
|                 |                 |
|     Length      |    Checksum     |
+--------+--------+--------+--------+
|
|          data octets ...
+---------------- ...
```
#### Source port
Source Port Number.
#### Destination port
Destination Port Number.
#### Length
Length in octets of this user datagram including this header and the data.
#### Checksum
Checksum of UDP header, data, and part of IP.

## References
- User Datagram Protocol [RFC 768](https://www.ietf.org/rfc/rfc768.txt)
