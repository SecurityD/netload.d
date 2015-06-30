module netload.protocols.icmp.v4;

import netload.core.protocol;
import netload.protocols.icmp.common;
import vibe.data.json;
import std.bitmanip;

class ICMPv4Communication : ICMP {
  public:
    this(ubyte type) {
      super(type, 0);
    }

    override Json toJson() const {
      Json packet = Json.emptyObject;
      packet.packetType = _type;
      packet.code = _code;
      packet.checksum = _checksum;
      packet.id = _id;
      packet.seq = _seq;
      return packet;
    }

    unittest {
      ICMPv4Communication packet = new ICMPv4Communication(8);
      assert(packet.toJson.packetType == 8);
      assert(packet.toJson.code == 0);
      assert(packet.toJson.checksum == 0);
      assert(packet.toJson.id == 0);
      assert(packet.toJson.seq == 0);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[8];
      packet.write!ubyte(_type, 0);
      packet.write!ubyte(_code, 1);
      packet.write!ushort(_checksum, 2);
      packet.write!ushort(_id, 4);
      packet.write!ushort(_seq, 6);
      return packet;
    }

    unittest {
      ICMPv4Communication packet = new ICMPv4Communication(8);
      packet.id = 1;
      packet.seq = 2;
      assert(packet.toBytes == [8, 0, 0, 0, 0, 1, 0, 2]);
    }

    @disable @property {
      override void code(ubyte code) { _code = code; }
    }

    @property {
      inout ushort id() { return _id; }
      void id(ushort id) { _id = id; }
      inout ushort seq() { return _seq; }
      void seq(ushort seq) { _seq = seq; }
    }

  private:
    ushort _id = 0;
    ushort _seq = 0;
}

ICMPv4Communication toICMPv4Communication(Json json) {
  ICMPv4Communication packet = new ICMPv4Communication(json.type.to!ubyte);
  packet.checksum = json.checksum.to!ushort;
  packet.id = json.id.to!ushort;
  packet.seq = json.seq.to!ushort;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.packetType = 8;
  json.checksum = 0;
  json.id = 1;
  json.seq = 2;
  ICMPv4Communication packet = toICMPv4Communication(json);
  assert(packet.type == 8);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

ICMPv4Communication toICMPv4Communication(ubyte[] encodedPacket) {
  ICMPv4Communication packet = new ICMPv4Communication(encodedPacket.read!ubyte());
  encodedPacket.read!ubyte();
  packet.checksum = encodedPacket.read!ushort();
  packet.id = encodedPacket.read!ushort();
  packet.seq = encodedPacket.read!ushort();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2];
  ICMPv4Communication packet = encodedPacket.toICMPv4Communication;
  assert(packet.type == 8);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

class ICMPv4EchoRequest : ICMPv4Communication {
  public:
    this() {
      super(8);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}

class ICMPv4EchoReply : ICMPv4Communication {
  public:
    this() {
      super(0);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}

class ICMPv4InformationRequest : ICMPv4Communication {
  public:
    this() {
      super(15);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}

class ICMPv4InformationReply : ICMPv4Communication {
  public:
    this() {
      super(16);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}
