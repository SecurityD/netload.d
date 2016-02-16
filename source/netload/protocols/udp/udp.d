module netload.protocols.udp.udp;

import netload.core.protocol;
import netload.protocols;
import netload.core.conversion.json_array;
import stdx.data.json;
import std.conv;
import std.bitmanip;
import std.outbuffer;
import std.range;
import std.array;

private Protocol delegate(ubyte[])[ushort] udpType;

shared static this() {
  udpType[80] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!HTTP; };
  udpType[110] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!POP3; };
  udpType[995] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!POP3; };
  udpType[143] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!IMAP; };
  udpType[993] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!IMAP; };
  udpType[25] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!SMTP; };
  udpType[2525] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!SMTP; };
  udpType[465] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!SMTP; };
  udpType[67] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!DHCP; };
  udpType[68] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!DHCP; };
  udpType[53] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!DNS; };
  udpType[123] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!NTPv4; };
};

/++
 + The User Datagram Protocol (UDP) uses a simple connectionless transmission
 + model with a minimum of protocol mechanism. It has no handshaking dialogues,
 + and thus exposes the user's program to any unreliability of the underlying
 + network protocol. There is no guarantee of delivery, ordering,
 + or duplicate protection. UDP provides checksums for data integrity,
 + and port numbers for addressing different functions at the source
 + and destination of the datagram.
 +/
class UDP : Protocol {
  public:
    static UDP opCall(inout JSONValue val) {
  		return new UDP(val);
  	}

    this() {}

    this(ushort srcPort, ushort destPort) {
      _srcPort = srcPort;
      _destPort = destPort;
    }

    this(JSONValue json) {
      this(json["src_port"].to!ushort, json["dest_port"].to!ushort);
      _length = json["len"].to!ushort;
      _checksum = json["checksum"].to!ushort;
      if ("data" in json && json["data"] != null)
  			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
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

    override JSONValue toJson() const {
      JSONValue json = [
        "src_port": JSONValue(_srcPort),
        "dest_port": JSONValue(_destPort),
        "len": JSONValue(_length),
        "checksum": JSONValue(_checksum),
        "name": JSONValue(name)
      ];
      if (_data is null)
  			json["data"] = JSONValue(null);
  		else
  			json["data"] = _data.toJson;
  		return json;
    }

    ///
    unittest {
      UDP packet = new UDP(8000, 7000);
      assert(packet.toJson["src_port"] == 8000);
      assert(packet.toJson["dest_port"] == 7000);
    }

    ///
    unittest {
      import netload.protocols.raw;
      UDP packet = new UDP(8000, 7000);

      packet.data = new Raw([42, 21, 84]);

      JSONValue json = packet.toJson;
      assert(json["name"] == "UDP");
      assert(json["src_port"] == 8000);
      assert(json["dest_port"] == 7000);

      json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
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

    ///
    unittest {
      auto packet = new UDP(8000, 7000);
      auto bytes = packet.toBytes;
      assert(bytes == [31, 64, 27, 88, 0, 0, 0, 0]);
    }

    ///
    unittest {
      import netload.protocols.raw;

      auto packet = new UDP(8000, 7000);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [31, 64, 27, 88, 0, 0, 0, 0] ~ [42, 21, 84]);
    }

    override string toIndentedString(uint idt = 0) const {
  		OutBuffer buf = new OutBuffer();
  		string indent = join(repeat("\t", idt));
  		buf.writef("%s%s%s%s\n", indent, PROTOCOL_NAME, name, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "src_port", RESET_SEQ, FIELD_VALUE, _srcPort, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "dest_port", RESET_SEQ, FIELD_VALUE, _destPort, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "len", RESET_SEQ, FIELD_VALUE, _length, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "checksum", RESET_SEQ, FIELD_VALUE, _checksum, RESET_SEQ);
      if (_data is null)
  			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "data", RESET_SEQ, FIELD_VALUE, _data, RESET_SEQ);
  		else
  			buf.writef("%s", _data.toIndentedString(idt + 1));
      return buf.toString;
    }

    override string toString() const {
      return toIndentedString;
    }

    /++
     + Source Port Number
     +/
    @property ushort srcPort() const { return _srcPort; }
    ///ditto
    @property void srcPort(ushort port) { _srcPort = port; }
    /++
     + Destination Port Number
     +/
    @property ushort destPort() const { return _destPort; }
    ///ditto
    @property void destPort(ushort port) { _destPort = port; }
    /++
     + Length in octets of this user datagram including this header and the data
     +/
    @property ushort length() const { return _length; }
    ///ditto
    @property void length(ushort length) { _length = length; }
    /++
     + Checksum of UDP header, data, and part of IP
     +/
    @property ushort checksum() const { return _checksum; }
    ///ditto
    @property void checksum(ushort checksum) { _checksum = checksum; }


  private:
      Protocol _data = null;
      ushort _srcPort = 0;
      ushort _destPort = 0;
      ushort _length = 0;
      ushort _checksum = 0;
}

///
unittest {
  JSONValue json = [
    "src_port": JSONValue(8000),
    "dest_port": JSONValue(7000),
    "len": JSONValue(0),
    "checksum": JSONValue(0)
  ];
  UDP packet = cast(UDP)to!UDP(json);
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.length == 0);
  assert(packet.checksum == 0);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("UDP"),
    "src_port": JSONValue(8000),
    "dest_port": JSONValue(7000),
    "len": JSONValue(0),
    "checksum": JSONValue(0)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  UDP packet = cast(UDP)to!UDP(json);
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.length == 0);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encoded = [31, 64, 27, 88, 0, 0, 0, 0];
  UDP packet = cast(UDP)encoded.to!UDP;
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.length == 0);
  assert(packet.checksum == 0);
}

///
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
