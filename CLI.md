```
[root@localhost ~]$ nf generate tcp src=80 dst=8080 / raw data="HTTP1.1 GET" > packet
[root@localhost ~]$ nf send packet
Sending packet...
Packet successfully sent.
[root@localhost ~]$
```

```
[root@localhost ~]$ nf --help
Usage: nf [--version] [--help] [<command> [<args>]]

Netfire is a Command Line Interface (CLI) that allows you to manipulate network
packets through a complete shell interface. If no argument is given, the program
is run in interactive mode.

Available commands
==================

  Packet manipulation
  -------------------
  generate <protocol> [<args>] [ / ...]
      Generate a packet with the given protocols stacked. Available protocols:
        raw data=<packet data>
            Builds a raw packet with the given raw data.

        ip src=<source IP> dst=<destination IP>
            Builds an IP packet with the given source address (src) and destina-
            tion address (dst). If IP is set, the program will sent it with a
            raw socket.

        udp src=<source port> dst=<destination port>
            Builds an UDP packet with the given source port (src) and destina-
            tion port (dst).

        tcp src=<source port> dst=<destination port>
            Builds a TCP packet with the given source port (src) and destination
            port (dst).

  layer <protocol>
      Returns the layer corresponding to the given protocol. If no file is spe-
      cified, it will read on the standard input.

      Options:
        -f, --file <file>
            Specify an input file. If no file is specified, it will read on the
            standard input.

  update <protocol> <args>
      Update the given fields in the protocol. If no file is specified, it will
      read on the standard input.

      Options:
        -f, --file <file>
            Specify an input file. If no file is specified, it will read on the
            standard input.

  Packet transmission
  -------------------
  send [<file>]
      Send a packet to the network. It will use the best option between a raw
      socket, a TCP socket and an UDP socket depending on the packet that will
      be sent.

      Options:
        -f, --file <file>
            Specify an input file. If no file is specified, it will read on the
            standard input.

        -v, --verbose
            Activate the verbose mode.

        -n, --number <nb>
            Specify the number of packet that should be sent.

        -r, --retry <nb>
            Specify the number of times it will retry to sent the packet on
            error. If this option is not specified, it will only retry 3 times.

        -s, --socket <socket>
            Force the using of the specified socket. Possible values are:
              RAW|TCP|UDP

  capture [<filter>]
      Capture packets on the network. If no filter is specified, it will captu-
      rate all packets.

      Options:
        -o, --output <file>
            Specify an output file. If no file is specified, it will write on
            the standard output.

        -v, --verbose
            Activate the verbose mode.

        -f, --filter <filter>
            Set a filter for the capturing.

  Interfacing with others
  -----------------------
  to-json [<file>]
      Convert the given packet to JSON. If no file is specified, it will read on
      the standard input.

      Options:
          -p, --pretty
              Print a pretty JSON.

          -m, --minified
              Print a minified JSON.

Common options
==============

  -h, --help
      Display general or command specific help.

  --version
      Prints the version number.

NetFire version 0.0.1, built on Jun 28 2015.
Developed by Maxime Fischer, Matthieu Kern and Alan Zanatta.
```
