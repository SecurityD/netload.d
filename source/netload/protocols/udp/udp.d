module netload.protocols.udp;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

class UDP : Protocol {
  public:
    this(ushort srcPort, ushort destPort) {
      _srcPort = srcPort;
      _destPort = destPort;
    }

    @property Protocol data() { return _data; }

    void prepare() {

    }

    Json toJson() {
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

    void fromJson(Json json) {

    }

    ubyte[] toBytes() {
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

    void fromBytes(ubyte[]) {

    }

    override string toString() {
      return toJson().toString;
    }

    unittest {
      import std.stdio;
      UDP packet = new UDP(8000, 7000);
      assert(packet.toString == `{"checksum":0,"dest_port":7000,"src_port":8000,"len":0}`);
    }

  private:
      Protocol _data;
      ushort _srcPort = 0;
      ushort _destPort = 0;
      ushort _length = 0;
      ushort _checksum = 0;
}
