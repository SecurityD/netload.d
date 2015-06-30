# SNMPv1
## Description
Simple Network Managment Protocol.

## Structure
  - Version Number : 0 => 4 bytes
  - Community, location of sender and recipient of message => variable size
  - PDU, body of message => variable size
    - #### PDU
      - PDU Type
      - Request Id, Associates Request with responses
      - Error Status
      - Error Index
      - Variable Bindings
    - #### Trap PDU
      - Enterprise, type of object generating the trap
      - Agent Address, address of object generating the trap
      - Generic trap type
      - Specific trap code
      - Time stamp, time elapsed between last network reinitialization and generation of the trap
      - Variable Bindings
