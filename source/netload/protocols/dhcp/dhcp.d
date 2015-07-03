module netload.protocols.dhcp.dhcp;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;
import std.exception;

union Bitfields {
  ushort raw;
  mixin(bitfields!(
    ubyte, "", 15,
    bool, "broadcast", 1
    ));
};

class DHCP : Protocol {
  public:
    this() {
      _flags.raw = 0;
    }

    this(ubyte op, uint xid, ubyte[4] ciaddr, ubyte[4] yiaddr, ubyte[4] siaddr, ubyte[4] giaddr, ubyte htype = 1, ubyte hlen = 6, string file = null) {
      if (_file.length > 128)
        throw new Exception("DHCP: Boot file name too long.");
      _flags.raw = 0;
      _file[0..(file.length)] = cast(ubyte[])(file);
      _op = op;
      _xid = xid;
      _htype = htype;
      _hlen = hlen;
      _ciaddr = ciaddr;
      _yiaddr = yiaddr;
      _siaddr = siaddr;
      _giaddr = giaddr;
    }

    override @property Protocol data() { return _data; }
    override @property void data(Protocol p) { _data = p; }
    override @property inout string name() const { return "DHCP"; }
    override @property int osiLayer() const { return 3; }

    override Json toJson() const {
      Json packet = Json.emptyObject;
      packet.op = _op;
      packet.htype = _htype;
      packet.hlen = _hlen;
      packet.hops = _hops;
      packet.xid = _xid;
      packet.secs = _secs;
      packet.broadcast = _flags.broadcast;
      packet.ciaddr = serializeToJson(_ciaddr);
      packet.yiaddr = serializeToJson(_yiaddr);
      packet.siaddr = serializeToJson(_siaddr);
      packet.giaddr = serializeToJson(_giaddr);
      packet.chaddr = serializeToJson(_chaddr);
      packet.sname = serializeToJson(_sname);
      packet.file = serializeToJson(_file);
      packet.options = serializeToJson(_options);
      packet.name = name;
      if (_data is null)
        packet.data = null;
      else
        packet.data = _data.toJson;
      return packet;
    }

    unittest {
      DHCP packet = new DHCP(2, 42, [127, 0, 0, 1], [127, 0, 1, 1], [10, 14, 19, 42], [10, 14, 59, 255]);
      assert(packet.toJson.op == 2);
      assert(packet.toJson.htype == 1);
      assert(packet.toJson.hlen == 6);
      assert(packet.toJson.hops == 0);
      assert(packet.toJson.xid == 42);
      assert(packet.toJson.secs == 0);
      assert(packet.toJson.broadcast == false);
      assert(deserializeJson!(ubyte[4])(packet.toJson.ciaddr) == [127, 0, 0, 1]);
      assert(deserializeJson!(ubyte[4])(packet.toJson.yiaddr) == [127, 0, 1, 1]);
      assert(deserializeJson!(ubyte[4])(packet.toJson.siaddr) == [10, 14, 19, 42]);
      assert(deserializeJson!(ubyte[4])(packet.toJson.giaddr) == [10, 14, 59, 255]);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[12];
      packet.write!ubyte(_op, 0);
      packet.write!ubyte(_htype, 1);
      packet.write!ubyte(_hlen, 2);
      packet.write!ubyte(_hops, 3);
      packet.write!uint(_xid, 4);
      packet.write!ushort(_secs, 8);
      packet.write!ushort(_flags.raw, 10);
      packet ~= _ciaddr ~ _yiaddr ~ _siaddr ~ _giaddr ~ _chaddr ~ _sname ~ _file ~ _options;
      if (_data !is null)
        packet ~= _data.toBytes;
      return packet;
    }

    unittest {
      DHCP packet = new DHCP(2, 42, [127, 0, 0, 1], [127, 0, 1, 1], [10, 14, 19, 42], [10, 14, 59, 255]);
      assert(packet.toBytes == [2, 1, 6, 0, 0, 0, 0, 42, 0, 0, 0, 0, 127, 0, 0, 1, 127, 0, 1, 1, 10, 14, 19, 42, 10, 14, 59, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    }

    override string toString() const {
      return toJson().toString;
    }

    unittest {
      DHCP packet = new DHCP(2, 42, [127, 0, 0, 1], [127, 0, 1, 1], [10, 14, 19, 42], [10, 14, 59, 255]);
      assert(packet.toString == `{"op":2,"htype":1,"hops":0,"yiaddr":[127,0,1,1],"hlen":6,"name":"DHCP","data":null,"chaddr":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"secs":0,"giaddr":[10,14,59,255],"broadcast":false,"sname":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"file":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"xid":42,"ciaddr":[127,0,0,1],"options":[],"siaddr":[10,14,19,42]}`);
    }

    @property ubyte op() const { return _op; };
    @property void op(ubyte op) { _op = op; };
    @property ubyte htype() const { return _htype; };
    @property void htype(ubyte htype) { _htype = htype; };
    @property ubyte hlen() const { return _hlen; };
    @property void hlen(ubyte hlen) { _hlen = hlen; };
    @property ubyte hops() const { return _hops; };
    @property void hops(ubyte hops) { _hops = hops; };
    @property uint xid() const { return _xid; };
    @property void xid(uint xid) { _xid = xid; };
    @property ushort secs() const { return _secs; };
    @property void secs(ushort secs) { _secs = secs; };
    @property bool broadcast() const { return _flags.broadcast; };
    @property void broadcast(bool broadcast) { _flags.broadcast = broadcast; };
    @property const(ubyte[4]) ciaddr() const { return _ciaddr; };
    @property void ciaddr(ubyte[4] ciaddr) { _ciaddr = ciaddr; };
    @property const(ubyte[4]) yiaddr() const { return _yiaddr; };
    @property void yiaddr(ubyte[4] yiaddr) { _yiaddr = yiaddr; };
    @property const(ubyte[4]) siaddr() const { return _siaddr; };
    @property void siaddr(ubyte[4] siaddr) { _siaddr = siaddr; };
    @property const(ubyte[4]) giaddr() const { return _giaddr; };
    @property void giaddr(ubyte[4] giaddr) { _giaddr = giaddr; };
    @property const(ubyte[16]) chaddr() const { return _chaddr; };
    @property void chaddr(ubyte[16] chaddr) { _chaddr = chaddr; };
    @property const(ubyte[64]) sname() const { return _sname; };
    @property void sname(ubyte[64] sname) { _sname = sname; };
    @property const(ubyte[128]) file() const { return _file; };
    @property void file(ubyte[128] file) { _file = file; };
    @property const(ubyte[]) options() const { return _options; };
    @property void options(ubyte[] options) { _options = options; };

  private:
    Protocol _data = null;
    ubyte _op = 1;
    ubyte _htype = 1;
    ubyte _hlen = 6;
    ubyte _hops = 0;
    uint _xid = 0;
    ushort _secs = 0;
    Bitfields _flags;
    ubyte[4] _ciaddr = [0, 0, 0, 0];
    ubyte[4] _yiaddr = [0, 0, 0, 0];
    ubyte[4] _siaddr = [0, 0, 0, 0];
    ubyte[4] _giaddr = [0, 0, 0, 0];
    ubyte[16] _chaddr = new ubyte[16];
    ubyte[64] _sname = new ubyte[64];
    ubyte[128] _file = new ubyte[128];
    ubyte[] _options;
}

Protocol toDHCP(Json json) {
  DHCP packet = new DHCP();
  packet.op = json.op.to!ubyte;
  packet.htype = json.htype.to!ubyte;
  packet.hlen = json.hlen.to!ubyte;
  packet.hops = json.hops.to!ubyte;
  packet.xid = json.xid.to!uint;
  packet.secs = json.secs.to!ushort;
  packet.broadcast = json.broadcast.to!bool;
  packet.ciaddr = deserializeJson!(ubyte[4])(json.ciaddr);
  packet.yiaddr = deserializeJson!(ubyte[4])(json.yiaddr);
  packet.siaddr = deserializeJson!(ubyte[4])(json.siaddr);
  packet.giaddr = deserializeJson!(ubyte[4])(json.giaddr);
  packet.chaddr = deserializeJson!(ubyte[16])(json.chaddr);
  packet.sname = deserializeJson!(ubyte[64])(json.sname);
  packet.file = deserializeJson!(ubyte[128])(json.file);
  packet.options = deserializeJson!(ubyte[])(json.options);
  auto data = ("data" in json);
  if (data != null)
    packet.data = netload.protocols.conversion.protocolConversion[deserializeJson!string(data.name)](*data);
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  ubyte[] options;
  json.op = 2;
  json.htype = 1;
  json.hlen = 6;
  json.hops = 0;
  json.xid = 42;
  json.secs = 0;
  json.broadcast = false;
  json.ciaddr = serializeToJson([127, 0, 0, 1]);
  json.yiaddr = serializeToJson([127, 0, 1, 1]);
  json.siaddr = serializeToJson([10, 14, 19, 42]);
  json.giaddr = serializeToJson([10, 14, 59, 255]);
  json.chaddr = serializeToJson(new ubyte[16]);
  json.sname = serializeToJson(new ubyte[64]);
  json.file = serializeToJson(new ubyte[128]);
  json.options = serializeToJson(options);
  DHCP packet = cast(DHCP)toDHCP(json);
  assert(packet.toJson.op == 2);
  assert(packet.toJson.htype == 1);
  assert(packet.toJson.hlen == 6);
  assert(packet.toJson.hops == 0);
  assert(packet.toJson.xid == 42);
  assert(packet.toJson.secs == 0);
  assert(packet.toJson.broadcast == false);
  assert(deserializeJson!(ubyte[4])(packet.toJson.ciaddr) == [127, 0, 0, 1]);
  assert(deserializeJson!(ubyte[4])(packet.toJson.yiaddr) == [127, 0, 1, 1]);
  assert(deserializeJson!(ubyte[4])(packet.toJson.siaddr) == [10, 14, 19, 42]);
  assert(deserializeJson!(ubyte[4])(packet.toJson.giaddr) == [10, 14, 59, 255]);
}

Protocol toDHCP(ubyte[] encodedPacket) {
  DHCP packet = new DHCP();
  Bitfields flags;
  packet.op = encodedPacket.read!ubyte();
  packet.htype = encodedPacket.read!ubyte;
  packet.hlen = encodedPacket.read!ubyte;
  packet.hops = encodedPacket.read!ubyte;
  packet.xid = encodedPacket.read!uint;
  packet.secs = encodedPacket.read!ushort;
  flags.raw = encodedPacket.read!ushort;
  packet.broadcast = flags.broadcast;
  packet.ciaddr = encodedPacket[0..4];
  packet.yiaddr = encodedPacket[4..8];
  packet.siaddr = encodedPacket[8..12];
  packet.giaddr = encodedPacket[12..16];
  packet.chaddr = encodedPacket[16..32];
  packet.sname = encodedPacket[32..96];
  packet.file = encodedPacket[96..224];
  packet.options = encodedPacket[224..(encodedPacket.length)];
  return packet;
}

unittest {
  ubyte[] encodedPacket = [2, 1, 6, 0, 0, 0, 0, 42, 0, 0, 0, 0, 127, 0, 0, 1, 127, 0, 1, 1, 10, 14, 19, 42, 10, 14, 59, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 56, 0];
  DHCP packet = cast(DHCP)encodedPacket.toDHCP;
  assert(packet.op == 2);
  assert(packet.htype == 1);
  assert(packet.hlen == 6);
  assert(packet.hops == 0);
  assert(packet.xid == 42);
  assert(packet.secs == 0);
  assert(packet.broadcast == false);
  assert(packet.ciaddr == [127, 0, 0, 1]);
  assert(packet.yiaddr == [127, 0, 1, 1]);
  assert(packet.siaddr == [10, 14, 19, 42]);
  assert(packet.giaddr == [10, 14, 59, 255]);
  assert(packet.options == [42, 56, 0]);
}
