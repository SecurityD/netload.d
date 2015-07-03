module netload.protocols.dot11.dot11;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

union Bitfields {
  ubyte[2] raw;
  mixin(bitfields!(
    ubyte, "subtype", 4,
    ubyte, "type", 2,
    ubyte, "vers", 2,
    bool, "rsvd", 1,
    bool, "wep", 1,
    bool, "moreData", 1,
    bool, "power", 1,
    bool, "retry", 1,
    bool, "moreFrag", 1,
    bool, "fromDS", 1,
    bool, "toDS", 1
    ));
};

enum Dot11Type {
  MANAGEMENT = 0,
  CONTROL = 1,
  DATA = 2
};

class Dot11 : Protocol {
  public:
    this() {
      _frameControl.raw[0] = 0;
      _frameControl.raw[1] = 0;
    }

    this(ubyte type, ubyte subtype, ubyte[6] addr1, ubyte[6] addr2, ubyte[6] addr3, ubyte[6] addr4 = [0, 0, 0, 0, 0, 0]) {
      _frameControl.raw[0] = 0;
      _frameControl.raw[1] = 0;
      _frameControl.type = type;
      _frameControl.subtype = subtype;
      _addr[0] = addr1;
      _addr[1] = addr2;
      _addr[2] = addr3;
      _addr[3] = addr4;
    }

    override @property Protocol data() { return _data; }
    override @property void data(Protocol p) { _data = p; }
    override @property int osiLayer() const { return 2; }
    override @property inout string name() { return "Dot11"; }

    override Json toJson() const {
      Json packet = Json.emptyObject;
      packet.duration = _duration;
      packet.seq = _seq;
      packet.fcs = _fcs;
      packet.addr1 = serializeToJson(_addr[0]);
      packet.addr2 = serializeToJson(_addr[1]);
      packet.addr3 = serializeToJson(_addr[2]);
      packet.addr4 = serializeToJson(_addr[3]);
      packet.subtype = _frameControl.subtype;
      packet.packet_type = _frameControl.type;
      packet.vers = _frameControl.vers;
      packet.rsvd = _frameControl.rsvd;
      packet.wep = _frameControl.wep;
      packet.more_data = _frameControl.moreData;
      packet.power = _frameControl.power;
      packet.retry = _frameControl.retry;
      packet.more_frag = _frameControl.moreFrag;
      packet.from_DS = _frameControl.fromDS;
      packet.to_DS = _frameControl.toDS;
      packet.name = name;
      if (_data is null)
        packet.data = null;
      else
        packet.data = _data.toJson;
      return packet;
    }

    unittest {
      Dot11 packet = new Dot11(0, 8, [255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0], [1, 2, 3, 4, 5, 6]);
      assert(packet.toJson.packet_type == 0);
      assert(packet.toJson.subtype == 8);
      assert(deserializeJson!(ubyte[6])(packet.toJson.addr1) == [255,255,255,255,255,255]);
      assert(deserializeJson!(ubyte[6])(packet.toJson.addr2) == [0,0,0,0,0,0]);
      assert(deserializeJson!(ubyte[6])(packet.toJson.addr3) == [1,2,3,4,5,6]);
      assert(deserializeJson!(ubyte[6])(packet.toJson.addr4) == [0,0,0,0,0,0]);
      assert(packet.duration == 0);
      assert(packet.seq == 0);
      assert(packet.fcs == 0);
      assert(packet.vers == 0);
      assert(packet.rsvd == 0);
      assert(packet.wep == 0);
      assert(packet.moreData == 0);
      assert(packet.power == 0);
      assert(packet.retry == 0);
      assert(packet.moreFrag == 0);
      assert(packet.fromDS == 0);
      assert(packet.toDS == 0);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[34];
      packet.write!ubyte(_frameControl.raw[0], 0);
      packet.write!ubyte(_frameControl.raw[1], 1);
      packet.write!ushort(_duration, 2);
      for (ubyte i = 0; i < 4; i++) {
        for (ubyte j = 0; j < 6; j++) {
          packet.write!ubyte(_addr[i][j], 4 + i * 6 + j);
        }
      }
      packet.write!ushort(_seq, 28);
      packet.write!uint(_fcs, 30);
      return packet;
    }

    unittest {
      Dot11 packet = new Dot11(0, 8, [255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0], [1, 2, 3, 4, 5, 6]);
      assert(packet.toBytes == [8, 0, 0, 0, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    }

    override string toString() const {
      return toJson().toString;
    }

    unittest {
      Dot11 packet = new Dot11(0, 8, [255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0], [1, 2, 3, 4, 5, 6]);
      assert(packet.toString == `{"from_DS":false,"addr1":[255,255,255,255,255,255],"addr2":[0,0,0,0,0,0],"addr3":[1,2,3,4,5,6],"to_DS":false,"addr4":[0,0,0,0,0,0],"more_frag":false,"seq":0,"power":false,"packet_type":0,"name":"Dot11","data":null,"duration":0,"rsvd":false,"more_data":false,"retry":false,"subtype":8,"vers":0,"wep":false,"fcs":0}`);
    }

    @property ushort duration() const { return _duration; }
    @property void duration(ushort duration) { _duration = duration; }
    @property ubyte[6] addr1() const { return _addr[0]; }
    @property void addr1(ubyte[6] addr1) { _addr[0] = addr1; }
    @property ubyte[6] addr2() const { return _addr[1]; }
    @property void addr2(ubyte[6] addr2) { _addr[1] = addr2; }
    @property ubyte[6] addr3() const { return _addr[2]; }
    @property void addr3(ubyte[6] addr3) { _addr[2] = addr3; }
    @property ubyte[6] addr4() const { return _addr[3]; }
    @property void addr4(ubyte[6] addr4) { _addr[3] = addr4; }
    @property ushort seq() const { return _seq; }
    @property void seq(ushort seq) { _seq = seq; }
    @property uint fcs() const { return _fcs; }
    @property void fcs(uint fcs) { _fcs = fcs; }

    @property ubyte subtype() const { return _frameControl.subtype; }
    @property void subtype(ubyte subtype) { _frameControl.subtype = subtype; }
    @property ubyte type() const { return _frameControl.type; }
    @property void type(ubyte type) { _frameControl.type = type; }
    @property ubyte vers() const { return _frameControl.vers; }
    @property void vers(ubyte vers) { _frameControl.vers = vers; }
    @property bool rsvd() const { return _frameControl.rsvd; }
    @property void rsvd(bool rsvd) { _frameControl.rsvd = rsvd; }
    @property bool wep() const { return _frameControl.wep; }
    @property void wep(bool wep) { _frameControl.wep = wep; }
    @property bool moreData() const { return _frameControl.moreData; }
    @property void moreData(bool moreData) { _frameControl.moreData = moreData; }
    @property bool power() const { return _frameControl.power; }
    @property void power(bool power) { _frameControl.power = power; }
    @property bool retry() const { return _frameControl.retry; }
    @property void retry(bool retry) { _frameControl.retry = retry; }
    @property bool moreFrag() const { return _frameControl.moreFrag; }
    @property void moreFrag(bool moreFrag) { _frameControl.moreFrag = moreFrag; }
    @property bool fromDS() const { return _frameControl.fromDS; }
    @property void fromDS(bool fromDS) { _frameControl.fromDS = fromDS; }
    @property bool toDS() const { return _frameControl.toDS; }
    @property void toDS(bool toDS) { _frameControl.toDS = toDS; }

  private:
      Protocol _data = null;
      Bitfields _frameControl;
      ushort _duration = 0;
      ubyte[6][4] _addr = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
      ushort _seq = 0;
      uint _fcs = 0;
}

Protocol toDot11(Json json) {
  Dot11 packet = new Dot11();
  packet.subtype = json.subtype.to!ubyte;
  packet.type = json.packet_type.to!ubyte;
  packet.vers = json.vers.to!ubyte;
  packet.rsvd = json.rsvd.to!bool;
  packet.wep = json.wep.to!bool;
  packet.moreData = json.more_data.to!bool;
  packet.power = json.power.to!bool;
  packet.retry = json.retry.to!bool;
  packet.moreFrag = json.more_frag.to!bool;
  packet.fromDS = json.from_DS.to!bool;
  packet.toDS = json.to_DS.to!bool;
  packet.duration = json.duration.to!ushort;
  packet.addr1 = deserializeJson!(ubyte[6])(json.addr1);
  packet.addr2 = deserializeJson!(ubyte[6])(json.addr2);
  packet.addr3 = deserializeJson!(ubyte[6])(json.addr3);
  packet.addr4 = deserializeJson!(ubyte[6])(json.addr4);
  packet.seq = json.seq.to!ushort;
  packet.fcs = json.fcs.to!uint;
  auto data = ("data" in json);
  if (data != null)
    packet.data = netload.protocols.conversion.protocolConversion[deserializeJson!string(data.name)](*data);
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.subtype = 8;
  json.packet_type = 0;
  json.vers = 0;
  json.rsvd = 0;
  json.wep = 0;
  json.more_data = 0;
  json.power = 0;
  json.retry = 0;
  json.more_frag = 0;
  json.from_DS = 0;
  json.to_DS = 0;
  json.duration = 0;
  json.addr1 = serializeToJson([255, 255, 255, 255, 255, 255]);
  json.addr2 = serializeToJson([0, 0, 0, 0, 0, 0]);
  json.addr3 = serializeToJson([1, 2, 3, 4, 5, 6]);
  json.addr4 = serializeToJson([0, 0, 0, 0, 0, 0]);
  json.seq = 0;
  json.fcs = 0;
  Dot11 packet = cast(Dot11)toDot11(json);
  assert(packet.type == 0);
  assert(packet.subtype == 8);
  assert(packet.addr1 == [255,255,255,255,255,255]);
  assert(packet.addr2 == [0,0,0,0,0,0]);
  assert(packet.addr3 == [1,2,3,4,5,6]);
  assert(packet.addr4 == [0,0,0,0,0,0]);
  assert(packet.duration == 0);
  assert(packet.seq == 0);
  assert(packet.fcs == 0);
  assert(packet.vers == 0);
  assert(packet.rsvd == 0);
  assert(packet.wep == 0);
  assert(packet.moreData == 0);
  assert(packet.power == 0);
  assert(packet.retry == 0);
  assert(packet.moreFrag == 0);
  assert(packet.fromDS == 0);
  assert(packet.toDS == 0);
}

Protocol toDot11(ubyte[] encodedPacket) {
  Dot11 packet = new Dot11();
  Bitfields frameControl;
  frameControl.raw[0] = encodedPacket.read!ubyte();
  frameControl.raw[1] = encodedPacket.read!ubyte();
  packet.subtype = frameControl.subtype;
  packet.type = frameControl.type;
  packet.vers = frameControl.vers;
  packet.rsvd = frameControl.rsvd;
  packet.wep = frameControl.wep;
  packet.moreData = frameControl.moreData;
  packet.power = frameControl.power;
  packet.retry = frameControl.retry;
  packet.moreFrag = frameControl.moreFrag;
  packet.fromDS = frameControl.fromDS;
  packet.toDS = frameControl.toDS;
  packet.duration = encodedPacket.read!ushort();
  ubyte[6][4] arr;
  for (ubyte i = 0; i < 4; i++) {
    for (ubyte j = 0; j < 6; j++) {
      arr[i][j] = encodedPacket.read!ubyte();
    }
  }
  packet.addr1 = arr[0];
  packet.addr2 = arr[1];
  packet.addr3 = arr[2];
  packet.addr4 = arr[3];
  packet.seq = encodedPacket.read!ushort();
  packet.fcs = encodedPacket.read!uint();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  Dot11 packet = cast(Dot11)encodedPacket.toDot11;
  assert(packet.type == 0);
  assert(packet.subtype == 8);
  assert(packet.addr1 == [255,255,255,255,255,255]);
  assert(packet.addr2 == [0,0,0,0,0,0]);
  assert(packet.addr3 == [1,2,3,4,5,6]);
  assert(packet.addr4 == [0,0,0,0,0,0]);
  assert(packet.duration == 0);
  assert(packet.seq == 0);
  assert(packet.fcs == 0);
  assert(packet.vers == 0);
  assert(packet.rsvd == 0);
  assert(packet.wep == 0);
  assert(packet.moreData == 0);
  assert(packet.power == 0);
  assert(packet.retry == 0);
  assert(packet.moreFrag == 0);
  assert(packet.fromDS == 0);
  assert(packet.toDS == 0);
}
