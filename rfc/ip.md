# IP
## Description

## Structure
```
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |Type of Service|          Total Length         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Identification        |Flags|      Fragment Offset    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Time to Live |    Protocol   |         Header Checksum       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Source Address                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Destination Address                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options                    |    Padding    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

#### Version
The Version field indicates the format of the internet header.
#### Internet Header Length (IHL)
Internet Header Length is the length of the internet header in 32
bit words, and thus points to the beginning of the data.  Note that
the minimum value for a correct header is 5.
#### Type of Service (ToS)
The Type of Service provides an indication of the abstract
parameters of the quality of service desired.  These parameters are
to be used to guide the selection of the actual service parameters
when transmitting a datagram through a particular network.  Several
networks offer service precedence, which somehow treats high
precedence traffic as more important than other traffic (generally
by accepting only traffic above a certain precedence at time of high
load).  The major choice is a three way tradeoff between low-delay,
high-reliability, and high-throughput.

- Bits 0-2:  Precedence.
- Bit    3:  0 = Normal Delay,      1 = Low Delay.
- Bits   4:  0 = Normal Throughput, 1 = High Throughput.
- Bits   5:  0 = Normal Relibility, 1 = High Relibility.
- Bit  6-7:  Reserved for Future Use.
```
         0     1     2     3     4     5     6     7
      +-----+-----+-----+-----+-----+-----+-----+-----+
      |                 |     |     |     |     |     |
      |   PRECEDENCE    |  D  |  T  |  R  |  0  |  0  |
      |                 |     |     |     |     |     |
      +-----+-----+-----+-----+-----+-----+-----+-----+
```
Precedence

- 111 - Network Control
- 110 - Internetwork Control
- 101 - CRITIC/ECP
- 100 - Flash Override
- 011 - Flash
- 010 - Immediate
- 001 - Priority
- 000 - Routine

The use of the Delay, Throughput, and Reliability indications may
increase the cost (in some sense) of the service.  In many networks
better performance for one of these parameters is coupled with worse
performance on another.  Except for very unusual cases at most two
of these three indications should be set.

The type of service is used to specify the treatment of the datagram
during its transmission through the internet system.  Example
mappings of the internet type of service to the actual service
provided on networks such as AUTODIN II, ARPANET, SATNET, and PRNET
is given in "Service Mappings" [8].

The Network Control precedence designation is intended to be used
within a network only.  The actual use and control of that
designation is up to each network. The Internetwork Control
designation is intended for use by gateway control originators only.
If the actual use of these precedence designations is of concern to
a particular network, it is the responsibility of that network to
control the access to, and use of, those precedence designations.

#### Total Length
Total Length is the length of the datagram, measured in octets,
including internet header and data.  This field allows the length of
a datagram to be up to 65,535 octets.  Such long datagrams are
impractical for most hosts and networks.  All hosts must be prepared
to accept datagrams of up to 576 octets (whether they arrive whole
or in fragments).  It is recommended that hosts only send datagrams
larger than 576 octets if they have assurance that the destination
is prepared to accept the larger datagrams.

#### Identification
An identifying value assigned by the sender to aid in assembling the
fragments of a datagram.

#### Flags
Various Control Flags.
- Bit 0: reserved, must be zero
- Bit 1: (DF) 0 = May Fragment,  1 = Don't Fragment.
- Bit 2: (MF) 0 = Last Fragment, 1 = More Fragments.
```
          0   1   2
        +---+---+---+
        |   | D | M |
        | 0 | F | F |
        +---+---+---+
```

#### Fragment Offset
This field indicates where in the datagram this fragment belongs.
The fragment offset is measured in units of 8 octets (64 bits).  The
first fragment has offset zero.

#### Time To Live (TTL)
This field indicates the maximum time the datagram is allowed to
remain in the internet system.  If this field contains the value
zero, then the datagram must be destroyed.  This field is modified
in internet header processing.  The time is measured in units of
seconds, but since every module that processes a datagram must
decrease the TTL by at least one even if it process the datagram in
less than a second, the TTL must be thought of only as an upper
bound on the time a datagram may exist.  The intention is to cause
undeliverable datagrams to be discarded, and to bound the maximum
datagram lifetime.

#### Protocol
This field indicates the next level protocol used in the data portion of the internet datagram.
```
Decimal    Octal      Protocol Numbers
-------    -----      ----------------
     0       0         Reserved
     1       1         ICMP                           
     2       2         Unassigned
     3       3         Gateway-to-Gateway
     4       4         CMCC Gateway Monitoring Message
     5       5         ST
     6       6         TCP
     7       7         UCL
     8      10         Unassigned
     9      11         Secure
    10      12         BBN RCC Monitoring
    11      13         NVP
    12      14         PUP
    13      15         Pluribus
    14      16         Telenet
    15      17         XNET
    16      20         Chaos
    17      21         User Datagram
    18      22         Multiplexing
    19      23         DCN
    20      24         TAC Monitoring
 21-62   25-76         Unassigned
    63      77         any local network
    64     100         SATNET and Backroom EXPAK
    65     101         MIT Subnet Support
 66-68 102-104         Unassigned
    69     105         SATNET Monitoring
    70     106         Unassigned
    71     107         Internet Packet Core Utility
 72-75 110-113         Unassigned
    76     114         Backroom SATNET Monitoring
    77     115         Unassigned
    78     116         WIDEBAND Monitoring
    79     117         WIDEBAND EXPAK
80-254 120-376         Unassigned
   255     377         Reserved
```

#### Header Checksum
A checksum on the header only.  Since some header fields change
(e.g., time to live), this is recomputed and verified at each point
that the internet header is processed.

The checksum algorithm is:

The checksum field is the 16 bit one's complement of the one's
complement sum of all 16 bit words in the header.  For purposes of
computing the checksum, the value of the checksum field is zero.

This is a simple to compute checksum and experimental evidence
indicates it is adequate, but it is provisional and may be replaced
by a CRC procedure, depending on further experience.

#### Source Address
The source address.

#### Destination Address
The destination address.

#### Options
The options may appear or not in datagrams.  They must be
implemented by all IP modules (host and gateways).  What is optional
is their transmission in any particular datagram, not their
implementation.

In some environments the security option may be required in all
datagrams.

The option field is variable in length.  There may be zero or more
options.  There are two cases for the format of an option:

- Case 1:  A single octet of option-type.

- Case 2:  An option-type octet, an option-length octet, and the
           actual option-data octets.

The option-length octet counts the option-type octet and the
option-length octet as well as the option-data octets.

The option-type octet is viewed as having 3 fields:

- 1 bit   copied flag
- 2 bits  option class
- 5 bits  option number.

The copied flag indicates that this option is copied into all
fragments on fragmentation.

- 0 = not copied
- 1 = copied

The option classes are:

- 0 = control
- 1 = reserved for future use
- 2 = debugging and measurement
- 3 = reserved for future use
