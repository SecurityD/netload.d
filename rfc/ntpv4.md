# NTP
## Description
The Network Time Protocol (NTP) is a protocol for synchronizing a set of
network clocks using a set of distributed clients and servers.

## Structure
```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|LI | VN  |Mode |    Stratum     |     Poll      |  Precision   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Root Delay                            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Root Dispersion                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                          Reference ID                         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                     Reference Timestamp (64)                  +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                      Origin Timestamp (64)                    +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                      Receive Timestamp (64)                   +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                      Transmit Timestamp (64)                  +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
.                                                               .
.                    Extension Field 1 (variable)               .
.                                                               .
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
.                                                               .
.                    Extension Field 2 (variable)               .
.                                                               .
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                          Key Identifier                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
|                            dgst (128)                         |
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

#### LI Leap Indicator (leap)
2-bit integer warning of an impending leap
second to be inserted or deleted in the last minute of the current
month with values defined like:

   Value | Meaning
  -------|----------------------------------------
   0     | no warning
   1     | last minute of the day has 61 seconds  
   2     | last minute of the day has 59 seconds  
   3     | unknown (clock unsynchronized)

#### VN Version Number (version)
3-bit integer representing the NTP version number, currently 4.

#### Mode (mode)
3-bit integer representing the mode, with values defined like:

   Value | Meaning
  -------|--------------------------
   0     | reserved
   1     | symmetric active
   2     | symmetric passive
   3     | client
   4     | server
   5     | broadcast
   6     | NTP control message
   7     | reserved for private use

#### Stratum (stratum):
8-bit integer representing the stratum, with values defined like:

   Value  | Meaning
  --------|-----------------------------------------------------
   0      | unspecified or invalid
   1      | primary server (e.g., equipped with a GPS receiver)
   2-15   | secondary server (via NTP)
   16     | unsynchronized
   17-255 | reserved

It is customary to map the stratum value 0 in received packets to
MAXSTRAT (16) in the peer variable p.stratum and to map p.stratum
values of MAXSTRAT or greater to 0 in transmitted packets.  This
allows reference clocks, which normally appear at stratum 0, to be
conveniently mitigated using the same clock selection algorithms used
for external sources (see Appendix A.5.5.1 for an example).

#### Poll:
8-bit signed integer representing the maximum interval between
successive messages, in log2 seconds.  Suggested default limits for
minimum and maximum poll intervals are 6 and 10, respectively.

#### Precision:
8-bit signed integer representing the precision of the
system clock, in log2 seconds.  For instance, a value of -18
corresponds to a precision of about one microsecond.  The precision
can be determined when the service first starts up as the minimum
time of several iterations to read the system clock.

#### Root Delay (rootdelay):
Total round-trip delay to the reference clock, in NTP short format.

#### Root Dispersion (rootdisp):
Total dispersion to the reference clock, in NTP short format.

#### Reference ID (refid):
32-bit code identifying the particular server or reference clock.
The interpretation depends on the value in the stratum field.  For
packet stratum 0 (unspecified or invalid), this is a four-character
ASCII [RFC1345] string, called the "kiss code", used for debugging
and monitoring purposes. For stratum 1 (reference clock), this is
a four-octet, left-justified, zero-padded ASCII string assigned to
the reference clock.  The authoritative list of Reference Identifiers
is maintained by IANA; however, any string beginning with the ASCII
character "X" is reserved for unregistered experimentation and
development. The identifiers have been used as ASCII identifiers:

   ID   | Clock Source
  ------|----------------------------------------------------------
   GOES | Geosynchronous Orbit Environment Satellite
   GPS  | Global Position System
   GAL  | Galileo Positioning System
   PPS  | Generic pulse-per-second
   IRIG | Inter-Range Instrumentation Group
   WWVB | LF Radio WWVB Ft. Collins, CO 60 kHz
   DCF  | LF Radio DCF77 Mainflingen, DE 77.5 kHz
   HBG  | LF Radio HBG Prangins, HB 75 kHz
   MSF  | LF Radio MSF Anthorn, UK 60 kHz
   JJY  | LF Radio JJY Fukushima, JP 40 kHz, Saga, JP 60 kHz
   LORC | MF Radio LORAN C station, 100 kHz
   TDF  | MF Radio Allouis, FR 162 kHz
   CHU  | HF Radio CHU Ottawa, Ontario
   WWV  | HF Radio WWV Ft. Collins, CO
   WWVH | HF Radio WWVH Kauai, HI
   NIST | NIST telephone modem
   ACTS | NIST telephone modem
   USNO | USNO telephone modem
   PTB  | European telephone modem

Above stratum 1 (secondary servers and clients): this is the
reference identifier of the server and can be used to detect timing
loops.  If using the IPv4 address family, the identifier is the four-
octet IPv4 address.  If using the IPv6 address family, it is the
first four octets of the MD5 hash of the IPv6 address.  Note that,
when using the IPv6 address family on an NTPv4 server with a NTPv3
client, the Reference Identifier field appears to be a random value
and a timing loop might not be detected.

#### Reference Timestamp:
Time when the system clock was last set or corrected, in NTP timestamp format.

#### Origin Timestamp (org):
Time at the client when the request departed for the server, in NTP timestamp format.

#### Receive Timestamp (rec):
Time at the server when the request arrived from the client, in NTP timestamp format.

#### Transmit Timestamp (xmt):
Time at the server when the response left for the client, in NTP timestamp format.

#### Destination Timestamp (dst):
Time at the client when the reply arrived from the server, in NTP timestamp format.

Note: The Destination Timestamp field is not included as a header
field; it is determined upon arrival of the packet and made available
in the packet buffer data structure.

If the NTP has access to the physical layer, then the timestamps are
associated with the beginning of the symbol after the start of frame.
Otherwise, implementations should attempt to associate the timestamp
to the earliest accessible point in the frame.

The MAC consists of the Key Identifier followed by the Message
Digest.  The message digest, or cryptosum, is calculated as in
[RFC1321] over all NTP-header and optional extension fields, but not
the MAC itself.

#### Extension Field n:
See Section 7.5 for a description of the format of this field.

#### Key Identifier (keyid):
32-bit unsigned integer used by the client and server to designate
a secret 128-bit MD5 key.

#### Message Digest (digest):
128-bit MD5 hash computed over the key followed by the NTP packet
header and extensions fields (but not the Key Identifier or Message
Digest fields).

It should be noted that the MAC computation used here differs from
those defined in [RFC1305] and [RFC4330] but is consistent with how
existing implementations generate a MAC.
