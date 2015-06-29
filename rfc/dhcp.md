# DHCP
## Description
The Dynamic Host Configuration Protocol (DHCP) is a standardized network protocol used on Internet Protocol (IP) networks for dynamically distributing network configuration parameters, such as IP addresses for interfaces and services. With DHCP, computers request IP addresses and networking parameters automatically from a DHCP server, reducing the need for a network administrator or a user to configure these settings manually.

## Structure
```
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|     op (1)    |   htype (1)   |   hlen (1)    |   hops (1)    |
+---------------+---------------+---------------+---------------+
|                            xid (4)                            |
+-------------------------------+-------------------------------+
|           secs (2)            |           flags (2)           |
+-------------------------------+-------------------------------+
|                          ciaddr  (4)                          |
+---------------------------------------------------------------+
|                          yiaddr  (4)                          |
+---------------------------------------------------------------+
|                          siaddr  (4)                          |
+---------------------------------------------------------------+
|                          giaddr  (4)                          |
+---------------------------------------------------------------+
|                                                               |
|                          chaddr  (16)                         |
|                                                               |
|                                                               |
+---------------------------------------------------------------+
|                                                               |
|                          sname   (64)                         |
+---------------------------------------------------------------+
|                                                               |
|                          file    (128)                        |
+---------------------------------------------------------------+
|                                                               |
|                          options (variable)                   |
+---------------------------------------------------------------+
```

FIELD     | OCTETS | DESCRIPTION
----------|--------|-----------------------------------------------------
op        |   1    | Message op code / message type. 1 = BOOTREQUEST, 2 = BOOTREPLY
htype     |   1    | Hardware address type, see ARP section in "Assigned Numbers" RFC; e.g., '1' = 10mb ethernet.
hlen      |   1    | Hardware address length (e.g.  '6' for 10mb ethernet).
hops      |   1    | Client sets to zero, optionally used by relay agents when booting via a relay agent.
xid       |   4    | Transaction ID, a random number chosen by the client, used by the client and server to associate messages and responses between a client and a server.
secs      |   2    | Filled in by client, seconds elapsed since client began address acquisition or renewal process.
flags     |   2    | Flags (see figure 2).
ciaddr    |   4    | Client IP address; only filled in if client is in BOUND, RENEW or REBINDING state and can respond to ARP requests.
yiaddr    |   4    | 'your' (client) IP address.
siaddr    |   4    | IP address of next server to use in bootstrap; returned in DHCPOFFER, DHCPACK by server.
giaddr    |   4    | Relay agent IP address, used in booting via a relay agent.
chaddr    |  16    | Client hardware address.
sname     |  64    | Optional server host name, null terminated string.
file      | 128    | Boot file name, null terminated string; "generic" name or null in DHCPDISCOVER, fully qualified directory-path name in DHCPOFFER.
options   | var    | Optional parameters field.  See the options documents for a list of defined options.

## References
- Dynamic Host Configuration Protocol [RFC 2131](https://www.ietf.org/rfc/rfc2131.txt)
