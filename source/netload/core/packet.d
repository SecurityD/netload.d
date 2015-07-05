module netload.core.packet;

import netload.core;
import std.datetime;

class Packet {
  public:
    this(Protocol packetData) {
      _time = Clock.currTime;
      _data = packetData;
    }

    this(Protocol packetData, SysTime packetTime) {
      _data = packetData;
      _time = packetTime;
    }

    @property Protocol data() { return _data; }
    @property SysTime time() { return _time; }
    @property string annotation() { return _annotation; }
    @property void annotation(string comment) { _annotation = comment; }
  private:
    Protocol _data;
    SysTime _time;
    string _annotation;
}

unittest {
  Packet p = new Packet(new netload.protocols.raw.Raw());
  p.annotation = "malicious packet";
  assert(p.annotation == "malicious packet");
}

Protocol create()() {
  return null;
}

FirstProtocol create(FirstProtocol : Protocol, OthersProtocol...)() {
  FirstProtocol header = new FirstProtocol;
  header.data = create!(OthersProtocol)();
  return header;
}

unittest {
  import netload.protocols;
  Ethernet packet = create!(Ethernet, IP, TCP)();
  packet.layer!TCP.srcPort = 80;
  assert(packet.layer!TCP.srcPort == 80);
}
