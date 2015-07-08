module netload.protocols.ethernet.ethernet;

import netload.core.protocol;
import netload.core.addr;
import netload.protocols;
import std.conv;
import vibe.data.json;
import std.bitmanip;

private Protocol delegate(ubyte[])[ushort] etherType;

static this() {
  etherType[0x0800] = delegate(ubyte[] encoded){ return (cast(Protocol)to!IP(encoded)); };
  etherType[0x0806] = delegate(ubyte[] encoded){ return (cast(Protocol)to!ARP(encoded)); };
  etherType[0x8035] = delegate(ubyte[] encoded){ return (cast(Protocol)to!ARP(encoded)); };
  etherType[0x814C] = delegate(ubyte[] encoded){ return (cast(Protocol)to!SNMPv3(encoded)); };
}

class Ethernet : Protocol {
  public:
    this() {

    }

    this(ubyte[6] srcMac, ubyte[6] destMac) {
      _srcMacAddress = srcMac;
      _destMacAddress = destMac;
    }

    this(Json json) {
      _prelude = deserializeJson!(ubyte[7])(json.prelude);
      _srcMacAddress = stringToMac(json.src_mac_address.to!string);
      _destMacAddress = stringToMac(json.dest_mac_address.to!string);
      _protocolType = json.protocol_type.get!ushort;
      _fcs = json.fcs.get!uint;
      auto packetData = ("data" in json);
      if (json.data.type != Json.Type.Null && packetData != null)
        _data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
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

    override Json toJson() const {
      Json json = Json.emptyObject;
      json.prelude = serializeToJson(prelude);
      json.src_mac_address = macToString(srcMacAddress);
      json.dest_mac_address = macToString(destMacAddress);
      json.protocol_type = protocolType;
      json.fcs = fcs;
      json.name = name;
      if (_data is null)
        json.data = null;
      else
        json.data = _data.toJson;
      return json;
    }

    unittest {
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);
      Json json = packet.toJson;
      assert(json.dest_mac_address == "00:00:00:00:00:00");
      assert(json.src_mac_address == "ff:ff:ff:ff:ff:ff");
    }

    unittest {
      import netload.protocols.udp;
      import netload.protocols.raw;
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);

      UDP udp = new UDP(8000, 7000);
      packet.data = udp;

      packet.data.data = new Raw([42, 21, 84]);

      Json json = packet.toJson;
      assert(json.name == "Ethernet");
      assert(json.dest_mac_address == "00:00:00:00:00:00");
      assert(json.src_mac_address == "ff:ff:ff:ff:ff:ff");

      json = json.data;
      assert(json.name == "UDP");
      assert(json.src_port == 8000);
      assert(json.dest_port == 7000);

      json = json.data;
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

    unittest {
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);
      assert(packet.toBytes == [1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 8, 0, 0, 0, 0, 0]);
    }

    unittest {
      import netload.protocols.raw;

      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 8, 0] ~ [42, 21, 84] ~ [0, 0, 0, 0]);
    }

    override string toString() const { return toJson.toPrettyString; }

    @property ref inout(ubyte[7]) prelude() inout { return _prelude; }
    @property ref inout(ubyte[6]) srcMacAddress() inout { return _srcMacAddress; }
    @property ref inout(ubyte[6]) destMacAddress() inout { return _destMacAddress; }
    @property ushort protocolType() const { return _protocolType; }
    @property void protocolType(ushort value) { _protocolType = value; }
    @property uint fcs() const { return _fcs; }
    @property void fcs(uint value) { _fcs = value; }

  private:
    ubyte[7] _prelude = [1, 0, 1, 0, 1, 0, 1];
    ubyte[6] _srcMacAddress = [0, 0, 0, 0, 0, 0];
    ubyte[6] _destMacAddress = [0, 0, 0, 0, 0, 0];
    ushort _protocolType = 0x0800;
    Protocol _data = null;
    uint _fcs = 0;
}

unittest {
  Json json = Json.emptyObject;
  json.prelude = serializeToJson([1, 0, 1, 0, 1, 0, 1]);
  json.src_mac_address = macToString([255, 255, 255, 255, 255, 255]);
  json.dest_mac_address = macToString([0, 0, 0, 0, 0, 0]);
  json.protocol_type = 0x0800;
  json.fcs = 0;
  Ethernet packet = cast(Ethernet)to!Ethernet(json);
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.protocolType == 0x0800);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "Ethernet";
  json.prelude = serializeToJson([1, 0, 1, 0, 1, 0, 1]);
  json.src_mac_address = macToString([255, 255, 255, 255, 255, 255]);
  json.dest_mac_address = macToString([0, 0, 0, 0, 0, 0]);
  json.protocol_type = 0x0800;
  json.fcs = 0;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  Ethernet packet = cast(Ethernet)to!Ethernet(json);
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.protocolType == 0x0800);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encoded = [0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 8, 0, 0, 0, 0, 0];
  Ethernet packet = cast(Ethernet)encoded.to!Ethernet();
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.destMacAddress == [0, 0, 0, 0, 0, 0]);
}

unittest {
  ubyte[] encoded = [0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 8, 0] ~ [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1] ~ [0, 0, 0, 0];
  Ethernet packet = cast(Ethernet)encoded.to!Ethernet();
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.destMacAddress == [0, 0, 0, 0, 0, 0]);
  assert((cast(IP)packet.data).destIpAddress == [0, 0, 0, 1]);
}
