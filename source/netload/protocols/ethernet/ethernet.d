module netload.protocols.ethernet.ethernet;

import netload.core.protocol;
import netload.core.addr;
import netload.protocols;
import netload.core.conversion.json_array;
import std.conv;
import stdx.data.json;
import std.bitmanip;

private Protocol delegate(ubyte[])[ushort] etherType;

static this() {
  etherType[0x0800] = delegate(ubyte[] encoded){ return (cast(Protocol)encoded.to!IP); };
  etherType[0x0806] = delegate(ubyte[] encoded){ return (cast(Protocol)encoded.to!ARP); };
  etherType[0x8035] = delegate(ubyte[] encoded){ return (cast(Protocol)encoded.to!ARP); };
  etherType[0x814C] = delegate(ubyte[] encoded){ return (cast(Protocol)to!SNMPv3(encoded)); };
}

/++
 + Layer 2 Protocol to transmit data between two linked computers.
 +/
class Ethernet : Protocol {
  public:
    static Ethernet opCall(inout JSONValue val) {
  		return new Ethernet(val);
  	}

    this() {

    }

    this(ubyte[6] srcMac, ubyte[6] destMac) {
      _srcMacAddress = srcMac;
      _destMacAddress = destMac;
    }

    this(JSONValue json) {
      _prelude = json["prelude"].toArrayOf!ubyte;
      _srcMacAddress = stringToMac(json["src_mac_address"].get!string);
      _destMacAddress = stringToMac(json["dest_mac_address"].get!string);
      _protocolType = json["protocol_type"].to!ushort;
      _fcs = json["fcs"].to!uint;
      if ("data" in json && json["data"] != null)
  			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
    }

    this(ubyte[] encoded) {
      encoded = cast(ubyte[])[1, 0, 1, 0, 1, 0, 1] ~ encoded;
      _prelude[0..7] = encoded[0..7];
      _destMacAddress[0..6] = encoded[7..13];
      _srcMacAddress[0..6] = encoded[13..19];
      _protocolType = encoded.peek!(ushort)(19);
      _fcs = encoded.peek!(uint)(encoded.length - 4);
      if (encoded[21..$].length > 4) {
        auto func = (_protocolType in etherType);
        if (func !is null)
          _data = etherType[_protocolType](encoded[21..($ - 4)]);
        else
          _data = to!Raw(encoded[21..($ - 4)]);
      }
    }

    override @property inout string name() { return "Ethernet"; };
    override @property Protocol data() { return _data; }
    override @property void data(Protocol p) { _data = p; }
    override @property int osiLayer() const { return 2; }

    override JSONValue toJson() const {
      JSONValue json = [
        "prelude": (prelude.toJsonArray),
        "src_mac_address": JSONValue(macToString(srcMacAddress)),
        "dest_mac_address": JSONValue(macToString(destMacAddress)),
        "protocol_type": JSONValue(protocolType),
        "fcs": JSONValue(fcs),
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
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);
      JSONValue json = packet.toJson;
      assert(json["dest_mac_address"] == "00:00:00:00:00:00");
      assert(json["src_mac_address"] == "ff:ff:ff:ff:ff:ff");
    }

    ///
    unittest {
      import netload.protocols.udp;
      import netload.protocols.raw;
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);

      UDP udp = new UDP(8000, 7000);
      packet.data = udp;

      packet.data.data = new Raw([42, 21, 84]);

      JSONValue json = packet.toJson;
      assert(json["name"] == "Ethernet");
      assert(json["dest_mac_address"] == "00:00:00:00:00:00");
      assert(json["src_mac_address"] == "ff:ff:ff:ff:ff:ff");

      json = json["data"];
      assert(json["name"] == "UDP");
      assert(json["src_port"] == 8000);
      assert(json["dest_port"] == 7000);

      json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
    }

    override ubyte[] toBytes() const {
      ubyte[] encoded = new ubyte[21];
      encoded[0..7] = prelude;
      encoded[7..13] = destMacAddress;
      encoded[13..19] = srcMacAddress;
      encoded.write!ushort(protocolType, 19);
      if (_data !is null)
        encoded ~= _data.toBytes;
      ubyte[] packetFcs = new ubyte[4];
      packetFcs.write!uint(fcs, 0);
      encoded ~= packetFcs;
      return encoded;
    }

    ///
    unittest {
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);
      assert(packet.toBytes == [1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 8, 0, 0, 0, 0, 0]);
    }

    ///
    unittest {
      import netload.protocols.raw;

      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 8, 0] ~ [42, 21, 84] ~ [0, 0, 0, 0]);
    }

    override string toString() const { return toJson.toJSON; }

    /++
     + Prelude, Sequence to synchronize clocks : 0b1010101
     +/
    @property ref inout(ubyte[7]) prelude() inout { return _prelude; }
    /++
     + Destination Mac Address
     +/
    @property ref inout(ubyte[6]) srcMacAddress() inout { return _srcMacAddress; }
    /++
     + Source Mac Address
     +/
    @property ref inout(ubyte[6]) destMacAddress() inout { return _destMacAddress; }
    /++
     + Protocol type, Encapsulated Protocol type
     +/
    @property ushort protocolType() const { return _protocolType; }
    ///ditto
    @property void protocolType(ushort value) { _protocolType = value; }
    /++
     + FCS, Frame Check Sequence, calculated with crc
     +/
    @property uint fcs() const { return _fcs; }
    ///ditto
    @property void fcs(uint value) { _fcs = value; }

  private:
    ubyte[7] _prelude = [1, 0, 1, 0, 1, 0, 1];
    ubyte[6] _srcMacAddress = [0, 0, 0, 0, 0, 0];
    ubyte[6] _destMacAddress = [0, 0, 0, 0, 0, 0];
    ushort _protocolType = 0x0800;
    Protocol _data = null;
    uint _fcs = 0;
}

///
unittest {
  JSONValue json = [
    "prelude": JSONValue([1, 0, 1, 0, 1, 0, 1].toJsonArray),
    "src_mac_address": JSONValue(macToString([255, 255, 255, 255, 255, 255])),
    "dest_mac_address": JSONValue(macToString([0, 0, 0, 0, 0, 0])),
    "protocol_type": JSONValue(0x0800),
    "fcs": JSONValue(0)
  ];
  Ethernet packet = cast(Ethernet)to!Ethernet(json);
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.protocolType == 0x0800);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("Ethernet"),
    "prelude": JSONValue([1, 0, 1, 0, 1, 0, 1].toJsonArray),
    "src_mac_address": JSONValue(macToString([255, 255, 255, 255, 255, 255])),
    "dest_mac_address": JSONValue(macToString([0, 0, 0, 0, 0, 0])),
    "protocol_type": JSONValue(0x0800),
    "fcs": JSONValue(0)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": JSONValue((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  Ethernet packet = cast(Ethernet)to!Ethernet(json);
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.protocolType == 0x0800);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encoded = [0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 8, 0, 0, 0, 0, 0];
  Ethernet packet = cast(Ethernet)encoded.to!Ethernet();
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.destMacAddress == [0, 0, 0, 0, 0, 0]);
}

///
unittest {
  ubyte[] encoded = [0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 8, 0] ~ [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1] ~ [0, 0, 0, 0];
  Ethernet packet = cast(Ethernet)encoded.to!Ethernet();
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.destMacAddress == [0, 0, 0, 0, 0, 0]);
  assert((cast(IP)packet.data).destIpAddress == [0, 0, 0, 1]);
}
