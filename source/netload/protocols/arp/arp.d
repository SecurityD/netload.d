module netload.protocols.arp.arp;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

class ARP : Protocol {
  public:
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

    override string toString() const {
      return toJson.toString;
    }

    unittest {
      ARP packet = new ARP(1, 1, 6, 4);
      packet.senderHwAddr = [128, 128, 128, 128, 128, 128];
      packet.targetHwAddr = [0, 0, 0, 0, 0, 0];
      packet.senderProtocolAddr = [127, 0, 0, 1];
      packet.targetProtocolAddr = [10, 14, 255, 255];
      assert(packet.toString == `{"protocolAddrLen":4,"senderHwAddr":[128,128,128,128,128,128],"hwAddrLen":6,"targetHwAddr":[0,0,0,0,0,0],"hwType":1,"protocolType":1,"opcode":0,"targetProtocolAddr":[10,14,255,255],"senderProtocolAddr":[127,0,0,1]}`);
    }

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

ARP toARP(Json json) {
  ARP packet = new ARP(json.hwType.to!ushort, json.protocolType.to!ushort, json.hwAddrLen.to!ubyte, json.protocolAddrLen.to!ubyte, json.opcode.to!ushort);
  packet.senderHwAddr = deserializeJson!(ubyte[])(json.senderHwAddr);
  packet.targetHwAddr = deserializeJson!(ubyte[])(json.targetHwAddr);
  packet.senderProtocolAddr = deserializeJson!(ubyte[])(json.senderProtocolAddr);
  packet.targetProtocolAddr = deserializeJson!(ubyte[])(json.targetProtocolAddr);
  return packet;
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
  ARP packet = toARP(json);
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

ARP toARP(ubyte[] encoded) {
  ushort hwType = encoded.read!ushort();
  ushort protocolType = encoded.read!ushort();
  ubyte hwAddrLen = encoded.read!ubyte();
  ubyte protocolAddrLen = encoded.read!ubyte();
  ushort opcode = encoded.read!ushort();

  ubyte[] senderHwAddr = new ubyte[hwAddrLen];
  ubyte[] targetHwAddr = new ubyte[hwAddrLen];
  ubyte[] senderProtocolAddr = new ubyte[protocolAddrLen];
  ubyte[] targetProtocolAddr = new ubyte[protocolAddrLen];
  ubyte pos1 = hwAddrLen;
  ubyte pos2 = cast(ubyte)(pos1 + protocolAddrLen);
  ubyte pos3 = cast(ubyte)(pos2 + hwAddrLen);
  ubyte pos4 = cast(ubyte)(pos3 + protocolAddrLen);
  senderHwAddr[0..(hwAddrLen)] = encoded[0..(pos1)];
  senderProtocolAddr[0..(protocolAddrLen)] = encoded[(pos1)..(pos2)];
  targetHwAddr[0..(hwAddrLen)] = encoded[(pos2)..(pos3)];
  targetProtocolAddr[0..(protocolAddrLen)] = encoded[(pos3)..(pos4)];

  ARP packet = new ARP(hwType, protocolType, hwAddrLen, protocolAddrLen, opcode);
  packet.senderHwAddr = senderHwAddr;
  packet.targetHwAddr = targetHwAddr;
  packet.senderProtocolAddr = senderProtocolAddr;
  packet.targetProtocolAddr = targetProtocolAddr;
  return packet;
}

unittest {
  ubyte[] encodedPacket = [0, 1, 0, 1, 6, 4, 0, 0, 128, 128, 128, 128, 128, 128, 127, 0, 0, 1, 0, 0, 0, 0, 0, 0, 10, 14, 255, 255];
  ARP packet = encodedPacket.toARP;
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
