module netload.protocols.tcp.tcp;

import netload.core.protocol;
import netload.protocols;
import netload.core.conversion.json_array;
import stdx.data.json;
import std.bitmanip;
import std.conv;

private Protocol delegate(ubyte[])[ushort] tcpType;

shared static this() {
  tcpType[80] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!HTTP; };
  tcpType[110] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!POP3; };
  tcpType[995] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!POP3; };
  tcpType[143] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!IMAP; };
  tcpType[993] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!IMAP; };
  tcpType[25] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!SMTP; };
  tcpType[2525] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!SMTP; };
  tcpType[465] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!SMTP; };
  tcpType[67] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!DHCP; };
  tcpType[68] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!DHCP; };
  tcpType[53] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!DNS; };
  tcpType[123] = delegate(ubyte[] encoded) { return cast(Protocol)encoded.to!NTPv4; };
};

private union FlagsAndOffset {
  mixin(bitfields!(
    bool, "fin", 1,
    bool, "syn", 1,
    bool, "rst", 1,
    bool, "psh", 1,
    bool, "ack", 1,
    bool, "urg", 1,
    ubyte, "reserved", 6,
    ubyte, "offset", 4,
    ));
  ushort flagsAndOffset;
}

/++
 + The Transmision Control Protocol (TCP) of transport layer is used to have
 + a synchronized connection without any packet loss.
 +/
class TCP : Protocol {
  public:
    static TCP opCall(inout JSONValue val) {
  		return new TCP(val);
  	}

    this() {

    }

    this(ushort sourcePort, ushort destinationPort) {
      _srcPort = sourcePort;
      _destPort = destinationPort;
    }

    this(ubyte[] encoded) {
      _srcPort = encoded.read!ushort();
      _destPort = encoded.read!ushort();
      _sequenceNumber = encoded.read!uint();
      _ackNumber = encoded.read!uint();
      _flagsAndOffset.flagsAndOffset = encoded.read!ushort();
      _window = encoded.read!ushort();
      _checksum = encoded.read!ushort();
      _urgPtr = encoded.read!ushort();
      auto func = (_destPort in tcpType);
      if (func !is null)
        _data = tcpType[_destPort](encoded);
    }

    this(JSONValue json) {
      _srcPort = json["src_port"].to!ushort;
      _destPort = json["dest_port"].to!ushort;
      _sequenceNumber = json["sequence_number"].to!uint;
      _ackNumber = json["ack_number"].to!uint;
      _flagsAndOffset.fin = json["fin"].get!bool;
      _flagsAndOffset.syn = json["syn"].get!bool;
      _flagsAndOffset.rst = json["rst"].get!bool;
      _flagsAndOffset.psh = json["psh"].get!bool;
      _flagsAndOffset.ack = json["ack"].get!bool;
      _flagsAndOffset.urg = json["urg"].get!bool;
      _flagsAndOffset.reserved = json["reserved"].to!ubyte;
      _flagsAndOffset.offset = json["offset"].to!ubyte;
      _window = json["window"].to!ushort;
      _checksum = json["checksum"].to!ushort;
      _urgPtr = json["urgent_ptr"].to!ushort;
      if ("data" in json && json["data"] != null)
  			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
    }

    override @property inout string name() { return "TCP"; };
    override @property Protocol data() { return _data; }
    override @property void data(Protocol p) { _data = p; }
    override @property int osiLayer() const { return 4; }

    override JSONValue toJson() const {
      JSONValue json = [
        "src_port": JSONValue(srcPort),
        "dest_port": JSONValue(destPort),
        "sequence_number": JSONValue(sequenceNumber),
        "ack_number": JSONValue(ackNumber),
        "fin": JSONValue(fin),
        "syn": JSONValue(syn),
        "rst": JSONValue(rst),
        "psh": JSONValue(psh),
        "ack": JSONValue(ack),
        "urg": JSONValue(urg),
        "reserved": JSONValue(reserved),
        "offset": JSONValue(offset),
        "window": JSONValue(window),
        "checksum": JSONValue(checksum),
        "urgent_ptr": JSONValue(urgPtr),
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
      TCP packet = new TCP(8000, 7000);
      assert(packet.toJson["src_port"] == 8000);
      assert(packet.toJson["dest_port"] == 7000);
    }

    ///
    unittest {
      import netload.protocols.raw;
      TCP packet = new TCP(8000, 7000);

      packet.data = new Raw([42, 21, 84]);

      JSONValue json = packet.toJson;
      assert(json["name"] == "TCP");
      assert(json["src_port"] == 8000);
      assert(json["dest_port"] == 7000);

      json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[20];
      packet.write!ushort(srcPort, 0);
      packet.write!ushort(destPort, 2);
      packet.write!uint(sequenceNumber, 4);
      packet.write!uint(ackNumber, 8);
      packet.write!ushort(_flagsAndOffset.flagsAndOffset, 12);
      packet.write!ushort(window, 14);
      packet.write!ushort(checksum, 16);
      packet.write!ushort(urgPtr, 18);
      if (_data !is null)
        packet ~= _data.toBytes;
      return packet;
    }

    ///
    unittest {
      TCP packet = new TCP(8000, 7000);
      assert(packet.toBytes == [31, 64, 27, 88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0]);
    }

    ///
    unittest {
      import netload.protocols.raw;

      TCP packet = new TCP(8000, 7000);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [31, 64, 27, 88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0] ~ [42, 21, 84]);
    }

    override string toString() const { return toJson.toJSON; }

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
     + Sequence Number of first segment's byte
     +/
    @property uint sequenceNumber() const { return _sequenceNumber; }
    ///ditto
    @property void sequenceNumber(uint number) { _sequenceNumber = number; }
    /++
     + Sequence Number of next waited segment
     +/
    @property uint ackNumber() const { return _ackNumber; }
    ///ditto
    @property void ackNumber(uint number) { _ackNumber = number; }

    /++
     + Indicates a end of connection request
     +/
    @property bool fin() const { return _flagsAndOffset.fin; }
    ///ditto
    @property void fin(bool value) { _flagsAndOffset.fin = value; }
    /++
     + Indicates a synchronization request
     +/
    @property bool syn() const { return _flagsAndOffset.syn; }
    ///ditto
    @property void syn(bool value) { _flagsAndOffset.syn = value; }
    /++
     + Indicates abnormal reset of connection
     +/
    @property bool rst() const { return _flagsAndOffset.rst; }
    ///ditto
    @property void rst(bool value) { _flagsAndOffset.rst = value; }
    /++
     + Indicates data that must be sent immediatly
     +/
    @property bool psh() const { return _flagsAndOffset.psh; }
    ///ditto
    @property void psh(bool value) { _flagsAndOffset.psh = value; }
    /++
     + Indicates packet is an acknowledgment
     +/
    @property bool ack() const { return _flagsAndOffset.ack; }
    ///ditto
    @property void ack(bool value) { _flagsAndOffset.ack = value; }
    /++
     + Indicates urgent data
     +/
    @property bool urg() const { return _flagsAndOffset.urg; }
    ///ditto
    @property void urg(bool value) { _flagsAndOffset.urg = value; }
    /++
     + Reserved field
     +/
    @property ubyte reserved() const { return _flagsAndOffset.reserved; }
    ///ditto
    @property void reserved(ubyte value) { _flagsAndOffset.reserved = value; }
    /++
     + Header size in 32 bits words
     +/
    @property ubyte offset() const { return _flagsAndOffset.offset; }
    ///ditto
    @property void offset(ubyte off) { _flagsAndOffset.offset = off; }

    /++
     + Size in byte the recepter request
     +/
    @property ushort window() const { return _window; }
    ///ditto
    @property void window(ushort size) { _window = size; }
    /++
     + Checksum of TCP header, data, and part of IP
     +/
    @property ushort checksum() const { return _checksum; }
    ///ditto
    @property void checksum(ushort hash) { _checksum = hash; }
    /++
     + Relative position of last urgent data
     +/
    @property ushort urgPtr() const { return _urgPtr; }
    ///ditto
    @property void urgPtr(ushort ptr) { _urgPtr = ptr; }

  private:
    Protocol _data = null;
    ushort _srcPort = 0;
    ushort _destPort = 0;
    uint _sequenceNumber = 0;
    uint _ackNumber = 0;
    FlagsAndOffset _flagsAndOffset;
    ushort _window = 8192;
    ushort _checksum = 0;
    ushort _urgPtr = 0;
}

///
unittest {
  ubyte[] encoded = [31, 64, 27, 88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0];
  TCP packet = cast(TCP)encoded.to!TCP;
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.window == 8192);
}

///
unittest {
  ubyte[] encoded = cast(ubyte[])[0, 80, 0, 80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0] ~ cast(ubyte[])"HTTP 1.1";
  TCP packet = cast(TCP)encoded.to!TCP;
  assert(packet.srcPort == 80);
  assert(packet.destPort == 80);
  assert(packet.window == 8192);
  assert((cast(HTTP)packet.data).str == "HTTP 1.1");
}

///
unittest {
  JSONValue json = [
    "src_port": JSONValue(8000),
    "dest_port": JSONValue(7000),
    "sequence_number": JSONValue(0),
    "ack_number": JSONValue(0),
    "fin": JSONValue(false),
    "syn": JSONValue(true),
    "rst": JSONValue(false),
    "psh": JSONValue(false),
    "ack": JSONValue(true),
    "urg": JSONValue(false),
    "reserved": JSONValue(0),
    "offset": JSONValue(0),
    "window": JSONValue(0),
    "checksum": JSONValue(0),
    "urgent_ptr": JSONValue(0)
  ];
  TCP packet = cast(TCP)to!TCP(json);
  assert(packet.srcPort == json["src_port"].to!ushort);
  assert(packet.destPort == json["dest_port"].to!ushort);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("TCP"),
    "src_port": JSONValue(8000),
    "dest_port": JSONValue(7000),
    "sequence_number": JSONValue(0),
    "ack_number": JSONValue(0),
    "fin": JSONValue(false),
    "syn": JSONValue(true),
    "rst": JSONValue(false),
    "psh": JSONValue(false),
    "ack": JSONValue(true),
    "urg": JSONValue(false),
    "reserved": JSONValue(0),
    "offset": JSONValue(0),
    "window": JSONValue(0),
    "checksum": JSONValue(0),
    "urgent_ptr": JSONValue(0)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  TCP packet = cast(TCP)to!TCP(json);
  assert(packet.srcPort == json["src_port"].to!ushort);
  assert(packet.destPort == json["dest_port"].to!ushort);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}
