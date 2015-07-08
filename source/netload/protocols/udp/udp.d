module netload.protocols.udp.udp;

import netload.core.protocol;
import netload.protocols;
import vibe.data.json;
import std.bitmanip;

private Protocol delegate(ubyte[])[ushort] udpType;

shared static this() {
  udpType[80] = delegate(ubyte[] encoded) { return cast(Protocol)to!HTTP(encoded); };
  udpType[110] = delegate(ubyte[] encoded) { return cast(Protocol)to!POP3(encoded); };
  udpType[995] = delegate(ubyte[] encoded) { return cast(Protocol)to!POP3(encoded); };
  udpType[143] = delegate(ubyte[] encoded) { return cast(Protocol)to!IMAP(encoded); };
  udpType[993] = delegate(ubyte[] encoded) { return cast(Protocol)to!IMAP(encoded); };
  udpType[25] = delegate(ubyte[] encoded) { return cast(Protocol)to!SMTP(encoded); };
  udpType[2525] = delegate(ubyte[] encoded) { return cast(Protocol)to!SMTP(encoded); };
  udpType[465] = delegate(ubyte[] encoded) { return cast(Protocol)to!SMTP(encoded); };
  udpType[67] = delegate(ubyte[] encoded) { return cast(Protocol)to!DHCP(encoded); };
  udpType[68] = delegate(ubyte[] encoded) { return cast(Protocol)to!DHCP(encoded); };
  udpType[53] = delegate(ubyte[] encoded) { return cast(Protocol)to!DNS(encoded); };
  udpType[123] = delegate(ubyte[] encoded) { return cast(Protocol)to!NTPv4(encoded); };
};

class UDP : Protocol {
  public:
    this() {}

    this(ushort srcPort, ushort destPort) {
      _srcPort = srcPort;
      _destPort = destPort;
    }

    this(Json json) {
      this(json.src_port.to!ushort, json.dest_port.to!ushort);
      _length = json.len.to!ushort;
      _checksum = json.checksum.to!ushort;
      auto packetData = ("data" in json);
      if (json.data.type != Json.Type.Null && packetData != null)
        _data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
    }

    this(ubyte[] encodedPacket) {
      this(encodedPacket.read!ushort, encodedPacket.read!ushort);
      _length = encodedPacket.read!ushort;
      _checksum = encodedPacket.read!ushort;
      auto func = (_destPort in udpType);
      if (func !is null)
        _data = udpType[_destPort](encodedPacket);
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
      packet.name = name;
      if (_data is null)
        packet.data = null;
      else
        packet.data = _data.toJson;
      return packet;
    }

    unittest {
      UDP packet = new UDP(8000, 7000);
      assert(packet.toJson().src_port == 8000);
      assert(packet.toJson().dest_port == 7000);
    }

    unittest {
      import netload.protocols.raw;
      UDP packet = new UDP(8000, 7000);

      packet.data = new Raw([42, 21, 84]);

      Json json = packet.toJson;
      assert(json.name == "UDP");
      assert(json.src_port == 8000);
      assert(json.dest_port == 7000);

      json = json.data;
      assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[8];
      packet.write!ushort(_srcPort, 0);
      packet.write!ushort(_destPort, 2);
      packet.write!ushort(_length, 4);
      packet.write!ushort(_checksum, 6);
      if (_data !is null)
        packet ~= _data.toBytes;
      return packet;
    }

    unittest {
      auto packet = new UDP(8000, 7000);
      auto bytes = packet.toBytes;
      assert(bytes == [31, 64, 27, 88, 0, 0, 0, 0]);
    }

    unittest {
      import netload.protocols.raw;

      auto packet = new UDP(8000, 7000);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [31, 64, 27, 88, 0, 0, 0, 0] ~ [42, 21, 84]);
    }

    override string toString() const { return toJson().toPrettyString; }

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

unittest {
  Json json = Json.emptyObject;
  json.src_port = 8000;
  json.dest_port = 7000;
  json.len = 0;
  json.checksum = 0;
  UDP packet = cast(UDP)to!UDP(json);
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.length == 0);
  assert(packet.checksum == 0);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "UDP";
  json.src_port = 8000;
  json.dest_port = 7000;
  json.len = 0;
  json.checksum = 0;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  UDP packet = cast(UDP)to!UDP(json);
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.length == 0);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encoded = [31, 64, 27, 88, 0, 0, 0, 0];
  UDP packet = cast(UDP)encoded.to!UDP;
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.length == 0);
  assert(packet.checksum == 0);
}

unittest {
  ubyte[] encodedPacket = [2, 1, 6, 0, 0, 0, 0, 42, 0, 0, 0, 0, 127, 0, 0, 1, 127, 0, 1, 1, 10, 14, 19, 42, 10, 14, 59, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 56, 0];
  ubyte[] encoded = cast(ubyte[])[0, 68, 0, 67, 0, 247, 0, 0] ~ encodedPacket;
  UDP packet = cast(UDP)encoded.to!UDP;
  assert(packet.srcPort == 68);
  assert(packet.destPort == 67);
  assert(packet.length == 247);
  assert(packet.checksum == 0);
  assert((cast(DHCP)packet.data).op == 2);
  assert((cast(DHCP)packet.data).htype == 1);
  assert((cast(DHCP)packet.data).hlen == 6);
  assert((cast(DHCP)packet.data).hops == 0);
  assert((cast(DHCP)packet.data).xid == 42);
  assert((cast(DHCP)packet.data).secs == 0);
  assert((cast(DHCP)packet.data).broadcast == false);
  assert((cast(DHCP)packet.data).ciaddr == [127, 0, 0, 1]);
  assert((cast(DHCP)packet.data).yiaddr == [127, 0, 1, 1]);
  assert((cast(DHCP)packet.data).siaddr == [10, 14, 19, 42]);
  assert((cast(DHCP)packet.data).giaddr == [10, 14, 59, 255]);
  assert((cast(DHCP)packet.data).options == [42, 56, 0]);
}
