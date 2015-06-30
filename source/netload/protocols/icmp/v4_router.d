module netload.protocols.icmp.v4.router;

import netload.core.protocol;
import netload.protocols.icmp.common;
import vibe.data.json;
import std.bitmanip;

//class ICMPv4RouterAdvert

class ICMPv4RouterSollicitation : ICMP {
  public:
    this() {
      super(10, 0);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = super.toBytes();
      packet ~= [0, 0, 0, 0];
      return packet;
    }

    unittest {
      ICMPv4RouterSollicitation packet = new ICMPv4RouterSollicitation();
      assert(packet.toBytes == [10, 0, 0, 0, 0, 0, 0, 0]);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
      override void code(ubyte code) { _code = code; }
    }
}

ICMPv4RouterSollicitation toICMPv4RouterSollicitation(Json json) {
  ICMPv4RouterSollicitation packet = new ICMPv4RouterSollicitation();
  packet.checksum = json.checksum.to!ushort;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.checksum = 0;
  ICMPv4RouterSollicitation packet = toICMPv4RouterSollicitation(json);
  assert(packet.checksum == 0);
}

ICMPv4RouterSollicitation toICMPv4RouterSollicitation(ubyte[] encodedPacket) {
  ICMPv4RouterSollicitation packet = new ICMPv4RouterSollicitation();
  encodedPacket.read!ushort();
  packet.checksum = encodedPacket.read!ushort();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [10, 0, 0, 0, 0, 0, 0, 0];
  ICMPv4RouterSollicitation packet = encodedPacket.toICMPv4RouterSollicitation;
  assert(packet.checksum == 0);
}
