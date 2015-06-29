module netload.protocols.icmp;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

class ICMPEchoRequest : Protocol {
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
      ICMPEchoRequest packet = new ICMPEchoRequest();
      assert(packet.toJson.type == 8);
    }

    ubyte[] toBytes() {
      ubyte[] packet = new ubyte[4];
      packet.write!ubyte(_type, 0);
      return packet;
    }

    unittest {
      ICMPEchoRequest packet = new ICMPEchoRequest();
      assert(packet.toBytes == [8, 0, 0, 0]);
    }

    override string toString() {
      return toJson().toString;
    }

    unittest {
      ICMPEchoRequest packet = new ICMPEchoRequest();
      assert(packet.toString == `{"packetType":8}`);
    }

    @property ubyte type() { return _type; }

  private:
    Protocol _data;
    ubyte _type = 8;
}

ICMPEchoRequest toICMPEchoRequest(Json json) {
  ICMPEchoRequest packet = new ICMPEchoRequest();
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.packeType = 8;
  ICMPEchoRequest packet = toICMPEchoRequest(json);
  assert(packet.type == 8);
}

ICMPEchoRequest toICMPEchoRequest(ubyte[] encodedPacket) {
  ICMPEchoRequest packet = new ICMPEchoRequest();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0];
  ICMPEchoRequest packet = encodedPacket.toICMPEchoRequest();
  assert(packet.type == 8);
}

class ICMPEchoReply : Protocol {
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
      ICMPEchoReply packet = new ICMPEchoReply();
      assert(packet.toJson.packetType == 0);
    }

    ubyte[] toBytes() {
      ubyte[] packet = new ubyte[4];
      packet.write!ubyte(_type, 0);
      return packet;
    }

    unittest {
      ICMPEchoReply packet = new ICMPEchoReply();
      assert(packet.toBytes == [0, 0, 0, 0]);
    }

    override string toString() {
      return toJson().toString;
    }

    unittest {
      ICMPEchoReply packet = new ICMPEchoReply();
      assert(packet.toString == `{"packetType":0}`);
    }

    @property ubyte type() { return _type; }

  private:
    Protocol _data;
    ubyte _type = 0;
}

ICMPEchoReply toICMPEchoReply(Json json) {
  ICMPEchoReply packet = new ICMPEchoReply();
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.packeType = 0;
  ICMPEchoReply packet = toICMPEchoReply(json);
  assert(packet.type == 0);
}

ICMPEchoReply toICMPEchoReply(ubyte[] encodedPacket) {
  ICMPEchoReply packet = new ICMPEchoReply();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [0, 0, 0, 0];
  ICMPEchoReply packet = encodedPacket.toICMPEchoReply();
  assert(packet.type == 0);
}
