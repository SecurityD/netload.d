module netload.protocols.udp.udp;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

class UDP : Protocol {
  public:
    this(ushort srcPort, ushort destPort) {
      _srcPort = srcPort;
      _destPort = destPort;
    }

    override @property inout string name() { return "UDP"; };
    override @property Protocol data() { return _data; }
    override @property void data(Protocol p) { _data = p; }
    override @property int osiLayer() const { return 4; }

    override Json toJson() const {
      Json packet = Json.emptyObject;
      packet.src_port = _srcPort;
      packet.dest_port = _destPort;
      packet.len = _length;
      packet.checksum = _checksum;
      return packet;
    }

    unittest {
      UDP packet = new UDP(8000, 7000);
      assert(packet.toJson().src_port == 8000);
      assert(packet.toJson().dest_port == 7000);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[8];
      packet.write!ushort(_srcPort, 0);
      packet.write!ushort(_destPort, 2);
      packet.write!ushort(_length, 4);
      packet.write!ushort(_checksum, 6);
      return packet;
    }

    unittest {
      import std.stdio;
      auto packet = new UDP(8000, 7000);
      auto bytes = packet.toBytes;
      assert(bytes == [31, 64, 27, 88, 0, 0, 0, 0]);
    }

    override string toString() const {
      return toJson().toString;
    }

    unittest {
      import std.stdio;
      UDP packet = new UDP(8000, 7000);
      assert(packet.toString == `{"checksum":0,"dest_port":7000,"src_port":8000,"len":0}`);
    }

    @property ushort srcPort() const { return _srcPort; }
    @property void srcPort(ushort port) { _srcPort = port; }
    @property ushort destPort() const { return _destPort; }
    @property void destPort(ushort port) { _destPort = port; }
    @property ushort length() const { return _length; }
    @property void length(ushort length) { _length = length; }
    @property ushort checksum() const { return _checksum; }
    @property void checksum(ushort checksum) { _checksum = checksum; }


  private:
      Protocol _data = null;
      ushort _srcPort = 0;
      ushort _destPort = 0;
      ushort _length = 0;
      ushort _checksum = 0;
}

Protocol toUDP(Json json) {
  UDP packet = new UDP(json.src_port.to!ushort, json.dest_port.to!ushort);
  packet.length = json.len.to!ushort;
  packet.checksum = json.checksum.to!ushort;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.src_port = 8000;
  json.dest_port = 7000;
  json.len = 0;
  json.checksum = 0;
  UDP packet = cast(UDP)toUDP(json);
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.length == 0);
  assert(packet.checksum == 0);
}

Protocol toUDP(ubyte[] encodedPacket) {
  UDP packet = new UDP(encodedPacket.read!ushort, encodedPacket.read!ushort);
  packet.length = encodedPacket.read!ushort;
  packet.checksum = encodedPacket.read!ushort;
  return packet;
}

unittest {
  ubyte[] encoded = [31, 64, 27, 88, 0, 0, 0, 0];
  UDP packet = cast(UDP)encoded.toUDP;
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.length == 0);
  assert(packet.checksum == 0);
}
