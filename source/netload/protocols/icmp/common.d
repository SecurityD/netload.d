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
      packet.name = name;
      if (_data is null)
        packet.data = null;
      else
        packet.data = _data.toJson;
      return packet;
    }

    unittest {
      ICMP packet = new ICMP(3, 2);
      assert(packet.toJson.packetType == 3);
      assert(packet.toJson.code == 2);
      assert(packet.toJson.checksum == 0);
    }

    unittest {
      import netload.protocols.ethernet;
      import netload.protocols.raw;
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);

      ICMP icmp = new ICMP(3, 2);
      packet.data = icmp;

      packet.data.data = new Raw([42, 21, 84]);

      Json json = packet.toJson;
      assert(json.name == "Ethernet");
      assert(deserializeJson!(ubyte[6])(json.dest_mac_address) == [0, 0, 0, 0, 0, 0]);
      assert(deserializeJson!(ubyte[6])(json.src_mac_address) == [255, 255, 255, 255, 255, 255]);

      json = json.data;
      assert(json.name == "ICMP");
      assert(json.packetType == 3);
      assert(json.code == 2);
      assert(json.checksum == 0);

      json = json.data;
      assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[4];
      packet.write!ubyte(_type, 0);
      packet.write!ubyte(_code, 1);
      packet.write!ushort(_checksum, 2);
      if (_data !is null)
        packet ~= _data.toBytes;
      return packet;
    }

    unittest {
      ICMP packet = new ICMP(3, 2);
      assert(packet.toBytes == [3, 2, 0, 0]);
    }

    unittest {
      import netload.protocols.raw;

      ICMP packet = new ICMP(3, 2);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [3, 2, 0, 0] ~ [42, 21, 84]);
    }

    override string toString() const {
      return toJson.toString;
    }

    unittest {
      ICMP packet = new ICMP(3, 2);
      assert(packet.toString == `{"checksum":0,"name":"ICMP","data":null,"code":2,"packetType":3}`);
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

Protocol toICMP(Json json) {
  ICMP packet = new ICMP();
  packet.type = json.packetType.to!ubyte;
  packet.code = json.code.to!ubyte;
  packet.checksum = json.checksum.to!ushort;
  auto data = ("data" in json);
  if (data != null)
    packet.data = netload.protocols.conversion.protocolConversion[deserializeJson!string(data.name)](*data);
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.packetType = 3;
  json.code = 2;
  json.checksum = 0;
  ICMP packet = cast(ICMP)toICMP(json);
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

Protocol toICMP(ubyte[] encodedPacket) {
  ICMP packet = new ICMP();
  packet.type = encodedPacket.read!ubyte();
  packet.code = encodedPacket.read!ubyte();
  packet.checksum = encodedPacket.read!ushort();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0];
  ICMP packet = cast(ICMP)encodedPacket.toICMP;
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}
