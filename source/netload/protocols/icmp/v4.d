module netload.protocols.icmp.v4;

import netload.core.protocol;
import netload.protocols.icmp.common;
import vibe.data.json;
import std.bitmanip;

class ICMPv4Echo : ICMP {
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
      ICMPv4Echo packet = new ICMPv4Echo(8);
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
      ICMPv4Echo packet = new ICMPv4Echo(8);
      assert(packet.toBytes == [8, 0, 0, 0, 0, 0, 0, 0]);
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

class ICMPEchoRequest : ICMPEcho {
  public:
    this() {
      super(8);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}

class ICMPEchoRequest : ICMPEcho {
  public:
    this() {
      super(0);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}
