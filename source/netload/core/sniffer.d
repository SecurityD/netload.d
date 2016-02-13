module netload.core.sniffer;

import netload.core;
import netload.protocols.ethernet;
import std.conv;

/++
 + A packet sniffer using the pcap binding `PacketCapturer`. Can be used
 + to capture packets on a given interface.
 +
 + Examples:
 + ---
 + import std.stdio;
 + import netload.d;
 +
 + Sniffer sniffer = new Sniffer("enp0s25", &toEthernet);
 + sniffer.sniff(delegate(Packet packet) {
 +  static uint nbr = 0;
 +  log(packet);
 +  ++nbr;
 +  if (nbr == 3) {
 +    showLoggedPackets();
 +    return false;
 +  }
 +  return true;
 + });
 + ---
 +/
class Sniffer {
  public:
    /++
     + Creates a `Sniffer`.
     + Params:
     + iface              = is the interface to sniff
     + linkLayerConverter = is a delegate converting the data received as ubyte[]
     +                      to the right Protocol (defaults to Ethernet)
     + promisc            = is the promiscuous mode
     +/
    this(string iface = null,
          Protocol function(ubyte[] data) linkLayerConverter = function(ubyte[] data) { return cast(Protocol)to!Ethernet(data); },
          bool promisc = false) {
      _promisc = promisc;
      if (iface is null)
        _packetCapturer = new PacketCapturer(promisc);
      else
        _packetCapturer = new PacketCapturer(iface, promisc);
      _linkLayerConverter = linkLayerConverter;
      _packetCapturer.initialize;
    }

    /++
     + Reads the next packet and use `linkLayerConverter` given to the ctor
     + to convert it.
     + Returns the converted packet.
     +/
    Packet nextPacket() {
      ubyte[] data = _packetCapturer.nextPacket();
      Protocol protocol = _linkLayerConverter(data);
      Packet packet = new Packet(protocol);
      return packet;
    }

    /++
     + Sniffs while the given callback returns `true`.
     + Params:
     + callback = is a delegate called each time a packet is captured
     +/
    void sniff(bool delegate(Packet packet) callback) {
      bool mustSniff = true;
      while (mustSniff) {
        mustSniff = callback(nextPacket());
      }
    }
  private:
    bool _promisc;
    Protocol function(ubyte[] data) _linkLayerConverter;
    PacketCapturer _packetCapturer;
}
