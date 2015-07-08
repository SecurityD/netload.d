module netload.protocols.arp.arp;

import netload.core.protocol;
import std.conv;
import vibe.data.json;
import std.bitmanip;

class ARP : Protocol {
  public:
    this() {}

    this(ushort hwType, ushort protocolType, ubyte hwAddrLen, ubyte protocolAddrLen, ushort opcode = 0) {
      _hwType = hwType;
      _protocolType = protocolType;
      _hwAddrLen = hwAddrLen;
      _protocolAddrLen = protocolAddrLen;
      _opcode = opcode;
      _senderHwAddr = new ubyte[_hwAddrLen];
      _targetHwAddr = new ubyte[_hwAddrLen];
      _senderProtocolAddr = new ubyte[_protocolAddrLen];
      _targetProtocolAddr = new ubyte[_protocolAddrLen];
    }

    this(Json json) {
        this(json.hwType.to!ushort, json.protocolType.to!ushort, json.hwAddrLen.to!ubyte, json.protocolAddrLen.to!ubyte, json.opcode.to!ushort);
        senderHwAddr = deserializeJson!(ubyte[])(json.senderHwAddr);
        targetHwAddr = deserializeJson!(ubyte[])(json.targetHwAddr);
        senderProtocolAddr = deserializeJson!(ubyte[])(json.senderProtocolAddr);
        targetProtocolAddr = deserializeJson!(ubyte[])(json.targetProtocolAddr);
        auto packetData = ("data" in json);
        if (json.data.type != Json.Type.Null && packetData != null)
          data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
    }

    this(ubyte[] encoded) {
      this(encoded.read!ushort(), encoded.read!ushort(), encoded.read!ubyte(), encoded.read!ubyte(), encoded.read!ushort());
      ubyte pos1 = _hwAddrLen;
      ubyte pos2 = cast(ubyte)(pos1 + _protocolAddrLen);
      ubyte pos3 = cast(ubyte)(pos2 + _hwAddrLen);
      ubyte pos4 = cast(ubyte)(pos3 + _protocolAddrLen);
      _senderHwAddr[0..(_hwAddrLen)] = encoded[0..(pos1)];
      _senderProtocolAddr[0..(_protocolAddrLen)] = encoded[(pos1)..(pos2)];
      _targetHwAddr[0..(_hwAddrLen)] = encoded[(pos2)..(pos3)];
      _targetProtocolAddr[0..(_protocolAddrLen)] = encoded[(pos3)..(pos4)];
    }

    override @property Protocol data() { return _data; }
    override @property void data(Protocol p) { _data = p; }
    override @property inout string name() const { return "ARP"; }
    override @property int osiLayer() const { return 3; }

    override Json toJson() const {
      Json json = Json.emptyObject;
      json.hwType = _hwType;
      json.protocolType = _protocolType;
      json.hwAddrLen = _hwAddrLen;
      json.protocolAddrLen = _protocolAddrLen;
      json.opcode = _opcode;
      json.senderHwAddr = serializeToJson(_senderHwAddr);
      json.targetHwAddr = serializeToJson(_targetHwAddr);
      json.senderProtocolAddr = serializeToJson(_senderProtocolAddr);
      json.targetProtocolAddr = serializeToJson(_targetProtocolAddr);
      json.name = name;
      if (_data is null)
        json.data = null;
      else
        json.data = _data.toJson;
      return json;
    }

    unittest {
      ARP packet = new ARP(1, 1, 6, 4);
      packet.senderHwAddr = [128, 128, 128, 128, 128, 128];
      packet.targetHwAddr = [0, 0, 0, 0, 0, 0];
      packet.senderProtocolAddr = [127, 0, 0, 1];
      packet.targetProtocolAddr = [10, 14, 255, 255];
      assert(packet.toJson.hwType == 1);
      assert(packet.toJson.protocolType == 1);
      assert(packet.toJson.hwAddrLen == 6);
      assert(packet.toJson.protocolAddrLen == 4);
      assert(packet.toJson.opcode == 0);
      assert(deserializeJson!(ubyte[])(packet.toJson.senderHwAddr) == [128, 128, 128, 128, 128, 128]);
      assert(deserializeJson!(ubyte[])(packet.toJson.targetHwAddr) == [0, 0, 0, 0, 0, 0]);
      assert(deserializeJson!(ubyte[])(packet.toJson.senderProtocolAddr) == [127, 0, 0, 1]);
      assert(deserializeJson!(ubyte[])(packet.toJson.targetProtocolAddr) == [10, 14, 255, 255]);
    }

    unittest {
      import netload.protocols.raw;

      ARP packet = new ARP(1, 1, 6, 4);
      packet.senderHwAddr = [128, 128, 128, 128, 128, 128];
      packet.targetHwAddr = [0, 0, 0, 0, 0, 0];
      packet.senderProtocolAddr = [127, 0, 0, 1];
      packet.targetProtocolAddr = [10, 14, 255, 255];

      packet.data = new Raw([42, 21, 84]);

      Json json = packet.toJson;
      assert(json.name == "ARP");
      assert(json.hwType == 1);
      assert(json.protocolType == 1);
      assert(json.hwAddrLen == 6);
      assert(json.protocolAddrLen == 4);
      assert(json.opcode == 0);
      assert(deserializeJson!(ubyte[])(json.senderHwAddr) == [128, 128, 128, 128, 128, 128]);
      assert(deserializeJson!(ubyte[])(json.targetHwAddr) == [0, 0, 0, 0, 0, 0]);
      assert(deserializeJson!(ubyte[])(json.senderProtocolAddr) == [127, 0, 0, 1]);
      assert(deserializeJson!(ubyte[])(json.targetProtocolAddr) == [10, 14, 255, 255]);

      json = json.data;
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[8];
      packet.write!ushort(_hwType, 0);
      packet.write!ushort(_protocolType, 2);
      packet.write!ubyte(_hwAddrLen, 4);
      packet.write!ubyte(_protocolAddrLen, 5);
      packet.write!ushort(_opcode, 6);
      packet ~= _senderHwAddr;
      packet ~= _senderProtocolAddr;
      packet ~= _targetHwAddr;
      packet ~= _targetProtocolAddr;
      if (_data !is null)
        packet ~= _data.toBytes;
      return packet;
    }

    unittest {
      ARP packet = new ARP(1, 1, 6, 4);
      packet.senderHwAddr = [128, 128, 128, 128, 128, 128];
      packet.targetHwAddr = [0, 0, 0, 0, 0, 0];
      packet.senderProtocolAddr = [127, 0, 0, 1];
      packet.targetProtocolAddr = [10, 14, 255, 255];
      assert(packet.toBytes == [0, 1, 0, 1, 6, 4, 0, 0, 128, 128, 128, 128, 128, 128, 127, 0, 0, 1, 0, 0, 0, 0, 0, 0, 10, 14, 255, 255]);
    }

    unittest {
      import netload.protocols.raw;

      ARP packet = new ARP(1, 1, 6, 4);
      packet.senderHwAddr = [128, 128, 128, 128, 128, 128];
      packet.targetHwAddr = [0, 0, 0, 0, 0, 0];
      packet.senderProtocolAddr = [127, 0, 0, 1];
      packet.targetProtocolAddr = [10, 14, 255, 255];

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [0, 1, 0, 1, 6, 4, 0, 0, 128, 128, 128, 128, 128, 128, 127, 0, 0, 1, 0, 0, 0, 0, 0, 0, 10, 14, 255, 255] ~ [42, 21, 84]);
    }

    override string toString() const { return toJson.toPrettyString; }

    @property ushort hwType() const { return _hwType; }
    @property void hwType(ushort hwType) { _hwType = hwType; }
    @property ushort protocolType() const { return _protocolType; }
    @property void protocolType(ushort protocolType) { _protocolType = protocolType; }
    @property ubyte hwAddrLen() const { return _hwAddrLen; }
    @property void hwAddrLen(ubyte hwAddrLen) { _hwAddrLen = hwAddrLen; }
    @property ubyte protocolAddrLen() const { return _protocolAddrLen; }
    @property void protocolAddrLen(ubyte protocolAddrLen) { _protocolAddrLen = protocolAddrLen; }
    @property ushort opcode() const { return _opcode; }
    @property void opcode(ushort opcode) { _opcode = opcode; }
    @property const(ubyte[]) senderHwAddr() const { return _senderHwAddr; }
    @property void senderHwAddr(ubyte[] senderHwAddr) { _senderHwAddr = senderHwAddr; }
    @property const(ubyte[]) targetHwAddr() const { return _targetHwAddr; }
    @property void targetHwAddr(ubyte[] targetHwAddr) { _targetHwAddr = targetHwAddr; }
    @property const(ubyte[]) senderProtocolAddr() const { return _senderProtocolAddr; }
    @property void senderProtocolAddr(ubyte[] senderProtocolAddr) { _senderProtocolAddr = senderProtocolAddr; }
    @property const(ubyte[]) targetProtocolAddr() const { return _targetProtocolAddr; }
    @property void targetProtocolAddr(ubyte[] targetProtocolAddr) { _targetProtocolAddr = targetProtocolAddr; }

  private:
    Protocol _data = null;
    ushort _hwType = 0;
    ushort _protocolType = 0;
    ubyte _hwAddrLen = 0;
    ubyte _protocolAddrLen = 0;
    ushort _opcode = 0;
    ubyte[] _senderHwAddr;
    ubyte[] _senderProtocolAddr;
    ubyte[] _targetHwAddr;
    ubyte[] _targetProtocolAddr;
}

unittest  {
  Json json = Json.emptyObject;
  json.hwType = 1;
  json.protocolType = 1;
  json.hwAddrLen = 6;
  json.protocolAddrLen = 4;
  json.opcode = 0;
  json.senderHwAddr = serializeToJson([128, 128, 128, 128, 128, 128]);
  json.targetHwAddr = serializeToJson([0, 0, 0, 0, 0, 0]);
  json.senderProtocolAddr = serializeToJson([127, 0, 0, 1]);
  json.targetProtocolAddr = serializeToJson([10, 14, 255, 255]);
  ARP packet = cast(ARP)to!ARP(json);
  assert(packet.hwType == 1);
  assert(packet.protocolType == 1);
  assert(packet.hwAddrLen == 6);
  assert(packet.protocolAddrLen == 4);
  assert(packet.opcode == 0);
  assert(packet.senderHwAddr == [128, 128, 128, 128, 128, 128]);
  assert(packet.targetHwAddr == [0, 0, 0, 0, 0, 0]);
  assert(packet.senderProtocolAddr == [127, 0, 0, 1]);
  assert(packet.targetProtocolAddr == [10, 14, 255, 255]);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "ARP";
  json.hwType = 1;
  json.protocolType = 1;
  json.hwAddrLen = 6;
  json.protocolAddrLen = 4;
  json.opcode = 0;
  json.senderHwAddr = serializeToJson([128, 128, 128, 128, 128, 128]);
  json.targetHwAddr = serializeToJson([0, 0, 0, 0, 0, 0]);
  json.senderProtocolAddr = serializeToJson([127, 0, 0, 1]);
  json.targetProtocolAddr = serializeToJson([10, 14, 255, 255]);

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  ARP packet = cast(ARP)to!ARP(json);
  assert(packet.senderHwAddr == [128, 128, 128, 128, 128, 128]);
  assert(packet.targetHwAddr == [0, 0, 0, 0, 0, 0]);
  assert(packet.senderProtocolAddr == [127, 0, 0, 1]);
  assert(packet.targetProtocolAddr == [10, 14, 255, 255]);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [0, 1, 0, 1, 6, 4, 0, 0, 128, 128, 128, 128, 128, 128, 127, 0, 0, 1, 0, 0, 0, 0, 0, 0, 10, 14, 255, 255];
  ARP packet = cast(ARP)encodedPacket.to!ARP;
  assert(packet.hwType == 1);
  assert(packet.protocolType == 1);
  assert(packet.hwAddrLen == 6);
  assert(packet.protocolAddrLen == 4);
  assert(packet.opcode == 0);
  assert(packet.senderHwAddr == [128, 128, 128, 128, 128, 128]);
  assert(packet.targetHwAddr == [0, 0, 0, 0, 0, 0]);
  assert(packet.senderProtocolAddr == [127, 0, 0, 1]);
  assert(packet.targetProtocolAddr == [10, 14, 255, 255]);
}
