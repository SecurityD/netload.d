module netload.core.sniffer;

import netload.core;
import netload.protocols.ethernet;

class Sniffer {
  public:
    this(string iface = null,
          Protocol function(ubyte[] data) linkLayerConverter = &toEthernet,
          bool promisc = false) {
      _promisc = promisc;
      if (iface is null)
        _packetCapturer = new PacketCapturer(promisc);
      else
        _packetCapturer = new PacketCapturer(iface, promisc);
      _linkLayerConverter = linkLayerConverter;
      _packetCapturer.initialize;
    }

    Packet nextPacket() {
      ubyte[] data = _packetCapturer.nextPacket();
      Protocol protocol = _linkLayerConverter(data);
      Packet packet = new Packet(protocol);
      return packet;
    }

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
