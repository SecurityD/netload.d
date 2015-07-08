module netload.protocols.icmp.common;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

enum ICMPType {
  ANY,
  NONE,
  ECHO_REQUEST,
  ECHO_REPLY,
  INFORMATION_REQUEST,
  INFORMATION_REPLY,
  TIMESTAMP_REQUEST,
  TIMESTAMP_REPLY,
  DEST_UNREACH,
  TIME_EXCEED,
  SOURCE_QUENCH,
  REDIRECT,
  PARAM_PROBLEM,
  ADVERT,
  SOLLICITATION
};

alias ICMP = ICMPBase!(ICMPType.ANY);

class ICMPBase(ICMPType __type__) : Protocol {
  public:
    this() {}

    this(ubyte type, ubyte code) {
      _type = type;
      _code = code;
    }

    this(Json json) {
      _type = json.packetType.to!ubyte;
      _code = json.code.to!ubyte;
      _checksum = json.checksum.to!ushort;
      auto packetData = ("data" in json);
      if (json.data.type != Json.Type.Null && packetData != null)
        _data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
    }

    this(ref ubyte[] encodedPacket) {
      _type = encodedPacket.read!ubyte();
      _code = encodedPacket.read!ubyte();
      _checksum = encodedPacket.read!ushort();
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
      assert(json.dest_mac_address == "00:00:00:00:00:00");
      assert(json.src_mac_address == "ff:ff:ff:ff:ff:ff");

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

    override string toString() const { return toJson.toPrettyString; }

    @property {
      inout ushort checksum() { return _checksum; }
      void checksum(ushort checksum) { _checksum = checksum; }
      static if (__type__ == ICMPType.ANY) {
        inout ubyte type() { return _type; }
        void type(ubyte type) { _type = type; }
        inout ubyte code() { return _code; }
        void code(ubyte code) { _code = code; }
      }
    }

  protected:
    Protocol _data = null;
    ubyte _type = 0;
    ubyte _code = 0;
    ushort _checksum = 0;
}

unittest {
  Json json = Json.emptyObject;
  json.packetType = 3;
  json.code = 2;
  json.checksum = 0;
  ICMP packet = cast(ICMP)to!ICMP(json);
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "ICMP";
  json.packetType = 3;
  json.code = 2;
  json.checksum = 0;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  ICMP packet = cast(ICMP)to!ICMP(json);
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0];
  ICMP packet = cast(ICMP)encodedPacket.to!ICMP;
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}
