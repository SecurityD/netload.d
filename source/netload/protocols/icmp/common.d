module netload.protocols.icmp.common;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

class ICMP : Protocol {
  public:
    this() {}

    this(ubyte type, ubyte code) {
      _type = type;
      _code = code;
    }

    override @property inout string name() { return "ICMP"; };
    override @property Protocol data() { return _data; }
    override @property void data(Protocol p) { _data = p; }
    override @property int osiLayer() const { return 3; }

    void prepare() {

    }

    override Json toJson() const {
      Json packet = Json.emptyObject;
      packet.packetType = _type;
      packet.code = _code;
      packet.checksum = _checksum;
      return packet;
    }

    unittest {
      ICMP packet = new ICMP(3, 2);
      assert(packet.toJson.packetType == 3);
      assert(packet.toJson.code == 2);
      assert(packet.toJson.checksum == 0);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[4];
      packet.write!ubyte(_type, 0);
      packet.write!ubyte(_code, 1);
      packet.write!ushort(_checksum, 2);
      return packet;
    }

    unittest {
      ICMP packet = new ICMP(3, 2);
      assert(packet.toBytes == [3, 2, 0, 0]);
    }

    override string toString() const {
      return toJson.toString;
    }

    unittest {
      ICMP packet = new ICMP(3, 2);
      assert(packet.toString == `{"checksum":0,"code":2,"packetType":3}`);
    }

    @property {
      inout ubyte type() { return _type; }
      void type(ubyte type) { _type = type; }
      inout ubyte code() { return _code; }
      void code(ubyte code) { _code = code; }
      inout ushort checksum() { return _checksum; }
      void checksum(ushort checksum) { _checksum = checksum; }
    }

  protected:
    Protocol _data = null;
    ubyte _type = 0;
    ubyte _code = 0;
    ushort _checksum = 0;
}

ICMP toICMP(Json json) {
  ICMP packet = new ICMP();
  packet.type = json.packetType.to!ubyte;
  packet.code = json.code.to!ubyte;
  packet.checksum = json.checksum.to!ushort;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.packetType = 3;
  json.code = 2;
  json.checksum = 0;
  ICMP packet = toICMP(json);
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

ICMP toICMP(ubyte[] encodedPacket) {
  ICMP packet = new ICMP();
  packet.type = encodedPacket.read!ubyte();
  packet.code = encodedPacket.read!ubyte();
  packet.checksum = encodedPacket.read!ushort();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0];
  ICMP packet = encodedPacket.toICMP;
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}
