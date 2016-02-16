# Ethernet
## Description

Layer 2 Protocol to transmit data between two linked computers.

## Structure
- Prelude, Sequence to synchronize clocks : 0b1010101 => 7 bytes
- Destination Mac Address => 6 bytes
- Source Mac Address => 6 bytes
- Protocol type, Encapsulated Protocol type => 2 bytes
- Data => between 46 and 1500 bytes
- FCS, Frame Check Sequence, calculated with crc => 4 bytes

### Protocol types
- 0x6000 : DEC
- 0x0609 : DEC
- 0x0600 : XNS
- 0x0800 : IPv4
- 0x0806 : ARP
- 0x8019 : Domain
- 0x8035 : RARP
- 0x809B : AppleTalk
- 0x86DD : IPv6
