module netload.protocols.ethernet.ethernet;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

class Ethernet : Protocol {
  public:
    this() {

    }

    this(ubyte[6] srcMac, ubyte[6] destMac) {
      _srcMacAddress = srcMac;
      _destMacAddress = destMac;
    }

    override @property inout string name() { return "Ethernet"; };
    override @property Protocol data() { return _data; }
    override @property void data(Protocol p) { _data = p; }
    override @property int osiLayer() const { return 2; }

    override Json toJson() const {
      Json json = Json.emptyObject;
      json.prelude = serializeToJson(prelude);
      json.src_mac_address = serializeToJson(srcMacAddress);
      json.dest_mac_address = serializeToJson(destMacAddress);
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
      assert(deserializeJson!(ubyte[6])(json.dest_mac_address) == [0, 0, 0, 0, 0, 0]);
      assert(deserializeJson!(ubyte[6])(json.src_mac_address) == [255, 255, 255, 255, 255, 255]);
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
      assert(deserializeJson!(ubyte[6])(json.dest_mac_address) == [0, 0, 0, 0, 0, 0]);
      assert(deserializeJson!(ubyte[6])(json.src_mac_address) == [255, 255, 255, 255, 255, 255]);

      json = json.data;
      assert(json.name == "UDP");
      assert(json.src_port == 8000);
      assert(json.dest_port == 7000);

      json = json.data;
      assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
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

    override string toString() const {
      return toJson.toString;
    }

    unittest {
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);
      assert(packet.toString == `{"dest_mac_address":[0,0,0,0,0,0],"src_mac_address":[255,255,255,255,255,255],"protocol_type":2048,"prelude":[1,0,1,0,1,0,1],"name":"Ethernet","data":null,"fcs":0}`);
    }

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

Protocol toEthernet(Json json) {
  Ethernet packet = new Ethernet();
  packet.prelude = deserializeJson!(ubyte[7])(json.prelude);
  packet.srcMacAddress = deserializeJson!(ubyte[6])(json.src_mac_address);
  packet.destMacAddress = deserializeJson!(ubyte[6])(json.dest_mac_address);
  packet.protocolType = json.protocol_type.get!ushort;
  packet.fcs = json.fcs.get!uint;
  auto data = ("data" in json);
  if (data != null)
    packet.data = netload.protocols.conversion.protocolConversion[deserializeJson!string(data.name)](*data);
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.prelude = serializeToJson([1, 0, 1, 0, 1, 0, 1]);
  json.src_mac_address = serializeToJson([255, 255, 255, 255, 255, 255]);
  json.dest_mac_address = serializeToJson([0, 0, 0, 0, 0, 0]);
  json.protocol_type = 0x0800;
  json.fcs = 0;
  Ethernet packet = cast(Ethernet)toEthernet(json);
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.protocolType == 0x0800);
}

Protocol toEthernet(ubyte[] encoded) {
  Ethernet packet = new Ethernet();
  packet.prelude[0..7] = encoded[0..7];
  packet.destMacAddress[0..6] = encoded[7..13];
  packet.srcMacAddress[0..6] = encoded[13..19];
  packet.protocolType = encoded.peek!(ushort)(19);
  packet.fcs = encoded.peek!(uint)(21);
  return packet;
}

unittest {
  ubyte[] encoded = [1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 8, 0, 0, 0, 0, 0];
  Ethernet packet = cast(Ethernet)encoded.toEthernet();
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.destMacAddress == [0, 0, 0, 0, 0, 0]);
}
