# NTP
## Description
The Network Time Protocol (NTP) is a protocol for synchronizing a set of
network clocks using a set of distributed clients and servers.

## Structure
```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|LI |   Status  |      Type     |           Precision           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Estimated Error                         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     Estimated Drift Rate                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                  Reference Clock Identifier                   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
|                 Reference Timestamp (64 bits)                 |
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
|                 Originate Timestamp (64 bits)                 |
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
|                  Receive Timestamp (64 bits)                  |
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
|                  Transmit Timestamp (64 bits)                 |
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

#### Leap Indicator (LI)
Code warning of impending leap-second to be inserted at the end of
the last day of the current month. Bits are coded as follows:

   Value | Meaning
  -------|----------------------------------------
   00    | no warning
   01    | +1 second (following minute has 61 seconds)
   10    | -1 second (following minute has 59 seconds)
   11    | reserved for future use

#### Status
Code indicating status of local clock. Values are defined as
follows:

   Value | Meaning
  -------|----------------------------------------
   0     | clock operating correctly
   1     | carrier loss
   2     | synch loss
   3     | format error
   4     | interface (Type 1) or link (Type 2) failure

#### Reference Clock Type (Type)
Code identifying the type of reference clock. Values are defined
as follows:

   Value | Meaning
  -------|----------------------------------------
   0     | unspecified
   1     | primary reference (e.g. radio clock)
   2     | secondary reference using an Internet host via NTP
   3     | secondary reference using some other host or protocol
   4     | eyeball-and-wristwatch

#### Precision
Signed integer in the range +32 to -32 indicating the precision of
the local clock, in seconds to the nearest power of two.

#### Estimated Error
Fixed-point number indicating the estimated error of the local
clock at the time last set, in seconds with fraction point between
bits 15 and 16.

#### Estimated Drift Rate
Signed fixed-point number indicating the estimated drift rate of
the local clock, in dimensionless units with fraction point to the
left of the high-order bit.

#### Reference Clock Identifier
Code identifying the particular reference clock. In the case of
type 1 (primary reference), this is a left-justified, zero-filled
ASCII string identifying the clock, for example:

   Value | Meaning
  -------|----------------------------------------
   WWVB  | WWVB radio clock (60 KHz)
   GOES  | GOES satellite clock (468 HMz)
   WWV   | WWV radio clock (2.5/5/10/15/20 MHz)

In the case of type 2 (secondary reference) this is the 32-bit
Internet address of the reference host. In other cases this field
is reserved for future use and should be set to zero.

#### Reference Timestamp
Local time at which the local clock was last set or corrected.

#### Originate Timestamp
Local time at which the request departed the client host for the
service host.

#### Receive Timestamp
Local time at which the request arrived at the service host.

#### Transmit Timestamp
Local time at which the reply departed the service host for the
client host.
