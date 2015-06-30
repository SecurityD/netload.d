module netload.protocols.icmp.v4;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

class ICMPv4EchoRequest : Protocol {
  public:
    this() {}

    @property Protocol data() { return _data; }

    void prepare() {

    }

    Json toJson() {
      Json packet = Json.emptyObject;
      packet.packetType = _type;
      return packet;
    }

    unittest {
      ICMPv4EchoRequest packet = new ICMPv4EchoRequest();
      assert(packet.toJson.type == 8);
    }

    ubyte[] toBytes() {
      ubyte[] packet = new ubyte[4];
      packet.write!ubyte(_type, 0);
      return packet;
    }

    unittest {
      ICMPv4EchoRequest packet = new ICMPv4EchoRequest();
      assert(packet.toBytes == [8, 0, 0, 0]);
    }

    override string toString() {
      return toJson().toString;
    }

    unittest {
      ICMPv4EchoRequest packet = new ICMPv4EchoRequest();
      assert(packet.toString == `{"packetType":8}`);
    }

    @property inout ubyte type() { return _type; }

  private:
    Protocol _data;
    ubyte _type = 8;
}

ICMPv4EchoRequest toICMPEchoRequest(Json json) {
  ICMPv4EchoRequest packet = new ICMPv4EchoRequest();
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.packeType = 8;
  ICMPv4EchoRequest packet = toICMPEchoRequest(json);
  assert(packet.type == 8);
}

ICMPv4EchoRequest toICMPEchoRequest(ubyte[] encodedPacket) {
  ICMPv4EchoRequest packet = new ICMPv4EchoRequest();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0];
  ICMPv4EchoRequest packet = encodedPacket.toICMPEchoRequest();
  assert(packet.type == 8);
}

class ICMPv4EchoReply : Protocol {
  public:
    this() {}

    @property Protocol data() { return _data; }

    void prepare() {

    }

    Json toJson() {
      Json packet = Json.emptyObject;
      packet.packetType = _type;
      return packet;
    }

    unittest {
      ICMPv4EchoReply packet = new ICMPv4EchoReply();
      assert(packet.toJson.packetType == 0);
    }

    ubyte[] toBytes() {
      ubyte[] packet = new ubyte[4];
      packet.write!ubyte(_type, 0);
      return packet;
    }

    unittest {
      ICMPv4EchoReply packet = new ICMPv4EchoReply();
      assert(packet.toBytes == [0, 0, 0, 0]);
    }

    override string toString() {
      return toJson().toString;
    }

    unittest {
      ICMPv4EchoReply packet = new ICMPv4EchoReply();
      assert(packet.toString == `{"packetType":0}`);
    }

    @property inout ubyte type() { return _type; }

  private:
    Protocol _data;
    ubyte _type = 0;
}

ICMPv4EchoReply toICMPEchoReply(Json json) {
  ICMPv4EchoReply packet = new ICMPv4EchoReply();
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.packeType = 0;
  ICMPv4EchoReply packet = toICMPEchoReply(json);
  assert(packet.type == 0);
}

ICMPv4EchoReply toICMPEchoReply(ubyte[] encodedPacket) {
  ICMPv4EchoReply packet = new ICMPv4EchoReply();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [0, 0, 0, 0];
  ICMPv4EchoReply packet = encodedPacket.toICMPEchoReply();
  assert(packet.type == 0);
}
