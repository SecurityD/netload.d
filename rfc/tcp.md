# TCP
## Description
The Transmision Control Protocol (TCP) of transport layer is used to have a synchronized connection without any packet loss.

## Structure
```
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|          Source Port          |       Destination Port        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Sequence Number                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Acknowledgment Number                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Data |           |U|A|P|R|S|F|                               |
| Offset| Reserved  |R|C|S|S|Y|I|            Window             |
|       |           |G|K|H|T|N|N|                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|           Checksum            |         Urgent Pointer        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options                    |    Padding    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                             data                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

#### Source Port
Source Port Number.
#### Destination Port
Destination Port Number.
#### Sequence Number
Sequence Number of first segment's byte.
#### Acknowledgment Number
Sequence Number of next waited segment.
#### Data Offset
Header size in 32 bits words.
#### Reserved
Reserved field.
#### URG FLAG
Indicates urgent data.
#### ACK FLAG
Indicates packet is an acknowledgment.
#### PSH FLAG
Indicates data that must be sent immediatly.
#### RST FLAG
Indicates abnormal reset of connection.
#### SYN FLAG
Indicates a synchronization request.
#### FIN FLAG
Indicates a end of connection request.
#### Window
Size in byte the recepter request.
#### Checksum
Checksum of TCP header, data, and part of IP.
#### Urgent Pointer
Relative position of last urgent data.
#### Options
Falcutatives Options.
#### Padding
Added zero to align the size on 32 bits words.

## References
- Transmission Control Protocol [RFC 793](https://www.ietf.org/rfc/rfc793.txt)
