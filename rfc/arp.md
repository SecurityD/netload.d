# ARP
## Description
The Address Resolution Protocol (ARP) is a telecommunication protocol used for resolution of network layer addresses into link layer addresses, a critical function in multiple-access networks.

## Structure
```
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Hardware Type         |         Protocol Type         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|   Hw Address  | Protocol Addr |             Opcode            |
|     Length    |    Length     |                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Sender Hardware Address                    |
+                               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                               |         Sender Protocol       -
|                               |          Address              -
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-        Sender Protocol        |                               |
-           Address             |                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               +
|                    Target Hardware Address                    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Target Protocol Address                    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

#### Hardware Type
This field specifies the type of hardware used for the local network transmitting the ARP message; thus it also identifies the type of addressing used.

[ARP Parameters](http://www.iana.org/assignments/arp-parameters/arp-parameters.xhtml)

#### Protocol Type
This field is the complement of the Hardware Type field, specifying the type of layer three addresses used in the message.

#### Hardware Address Length
This field specifies how long hardware addresses are in this message.

#### Protocol Address Length
This fields is, again, the complement of the preceding field; it specifies how long protocol (layer three) addresses are in this message.

#### Opcode
This field allows to know the function of the message and therefore its objective.

Opcode | ARP Message Type
:----: | :--------------:
1      | ARP Request
2      | ARP Reply
3      | RARP Request
4      | RARP Reply
5      | DRARP Request
6      | DRARP Reply
7      | DRARP Error
8      | InARP Request
9      | InARP Reply

#### Sender Hardware Address
**Size**: variable (depending on the Hardware Address Length field)<br />
The hardware (layer two) address of the device sending this message.

#### Sender Protocol Address
**Size**: variable (depending on the Protocol Address Length field)<br />
The IP address of the device sending this message.

#### Target Hardware Address
**Size**: variable (depending on the Hardware Address Length field)<br />
The hardware (layer two) address of the device this message is being sent to.

#### Target Protocol Address
**Size**: variable (depending on the Protocol Address Length field)<br />
The IP address of the device this message is being sent to.

## References
- An Ethernet Address Resolution Protocol [RFC 826](https://www.ietf.org/rfc/rfc826.txt)
- Requirements for Internet Hosts -- Communication Layers[RFC 1122](https://www.ietf.org/rfc/rfc1122.txt)
