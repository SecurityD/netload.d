module netload.protocols.dhcp.dhcp;

import netload.core.protocol;
import netload.core.conversion.array_conversion;
import netload.core.addr;
import stdx.data.json;
import std.bitmanip;
import std.exception;
import std.conv;

union Bitfields {
  ushort raw;
  mixin(bitfields!(
	ubyte, "", 15,
	bool, "broadcast", 1
	));
};

class DHCP : Protocol {
  public:
  static DHCP opCall(inout JSONValue val) {
		return new DHCP(val);
	}

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

	this(JSONValue json) {
	  _op = json["op"].to!ubyte;
	  _htype = json["htype"].to!ubyte;
	  _hlen = json["hlen"].to!ubyte;
	  _hops = json["hops"].to!ubyte;
	  _xid = json["xid"].to!uint;
	  _secs = json["secs"].to!ushort;
	  _flags.broadcast = json["broadcast"].to!bool;
	  _ciaddr = stringToIp(json["ciaddr"].get!string);
	  _yiaddr = stringToIp(json["yiaddr"].get!string);
	  _siaddr = stringToIp(json["siaddr"].get!string);
	  _giaddr = stringToIp(json["giaddr"].get!string);
	  _chaddr = json["chaddr"].toArrayOf!ubyte;
	  _sname = json["sname"].toArrayOf!ubyte;
	  _file = json["file"].toArrayOf!ubyte;
	  _options = json["options"].toArrayOf!ubyte;
    if ("data" in json && json["data"] != null)
			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
	}

	this(ubyte[] encodedPacket) {
	  _op = encodedPacket.read!ubyte();
	  _htype = encodedPacket.read!ubyte;
	  _hlen = encodedPacket.read!ubyte;
	  _hops = encodedPacket.read!ubyte;
	  _xid = encodedPacket.read!uint;
	  _secs = encodedPacket.read!ushort;
	  _flags.raw = encodedPacket.read!ushort;
	  _ciaddr = encodedPacket[0..4];
	  _yiaddr = encodedPacket[4..8];
	  _siaddr = encodedPacket[8..12];
	  _giaddr = encodedPacket[12..16];
	  _chaddr = encodedPacket[16..32];
	  _sname = encodedPacket[32..96];
	  _file = encodedPacket[96..224];
	  _options = encodedPacket[224..(encodedPacket.length)];
	}

	override @property Protocol data() { return _data; }
	override @property void data(Protocol p) { _data = p; }
	override @property inout string name() const { return "DHCP"; }
	override @property int osiLayer() const { return 3; }

	override JSONValue toJson() const {
	  JSONValue json = [
      "op": JSONValue(_op),
	    "htype": JSONValue(_htype),
	    "hlen": JSONValue(_hlen),
	    "hops": JSONValue(_hops),
	    "xid": JSONValue(_xid),
	    "secs": JSONValue(_secs),
	    "broadcast": JSONValue(_flags.broadcast),
	    "ciaddr": JSONValue(ipToString(_ciaddr)),
	    "yiaddr": JSONValue(ipToString(_yiaddr)),
	    "siaddr": JSONValue(ipToString(_siaddr)),
	    "giaddr": JSONValue(ipToString(_giaddr)),
	    "chaddr": JSONValue(_chaddr.toJsonArray),
	    "sname": JSONValue(_sname.toJsonArray),
	    "file": JSONValue(_file.toJsonArray),
	    "options": JSONValue(_options.toJsonArray),
	    "name": JSONValue(name)
    ];
    if (_data is null)
			json["data"] = JSONValue(null);
		else
			json["data"] = _data.toJson;
	  return json;
	}

	unittest {
	  DHCP packet = new DHCP(2, 42, [127, 0, 0, 1], [127, 0, 1, 1], [10, 14, 19, 42], [10, 14, 59, 255]);
	  assert(packet.toJson["op"] == 2);
	  assert(packet.toJson["htype"] == 1);
	  assert(packet.toJson["hlen"] == 6);
	  assert(packet.toJson["hops"] == 0);
	  assert(packet.toJson["xid"] == 42);
	  assert(packet.toJson["secs"] == 0);
	  assert(packet.toJson["broadcast"] == false);
	  assert(packet.toJson["ciaddr"] == "127.0.0.1");
	  assert(packet.toJson["yiaddr"] == "127.0.1.1");
	  assert(packet.toJson["siaddr"] == "10.14.19.42");
	  assert(packet.toJson["giaddr"] == "10.14.59.255");
	}

	unittest {
	  import netload.protocols.raw;
	  DHCP packet = new DHCP(2, 42, [127, 0, 0, 1], [127, 0, 1, 1], [10, 14, 19, 42], [10, 14, 59, 255]);

	  packet.data = new Raw([42, 21, 84]);

	  JSONValue json = packet.toJson;
	  assert(json["name"] == "DHCP");
	  assert(json["op"] == 2);
	  assert(json["htype"] == 1);
	  assert(json["hlen"] == 6);
	  assert(json["hops"] == 0);
	  assert(json["xid"] == 42);
	  assert(json["secs"] == 0);
	  assert(json["broadcast"] == false);
	  assert(json["ciaddr"] == "127.0.0.1");
	  assert(json["yiaddr"] == "127.0.1.1");
	  assert(json["siaddr"] == "10.14.19.42");
	  assert(json["giaddr"] == "10.14.59.255");

    json = json["data"];
		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
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

	unittest {
	  import netload.protocols.raw;

	  DHCP packet = new DHCP(2, 42, [127, 0, 0, 1], [127, 0, 1, 1], [10, 14, 19, 42], [10, 14, 59, 255]);

	  packet.data = new Raw([42, 21, 84]);

	  assert(packet.toBytes == [2, 1, 6, 0, 0, 0, 0, 42, 0, 0, 0, 0, 127, 0, 0, 1, 127, 0, 1, 1, 10, 14, 19, 42, 10, 14, 59, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ~ [42, 21, 84]);
	}

	override string toString() const { return toJson.toJSON; }

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

unittest {
  ubyte[] options;
  JSONValue json = [
    "op": JSONValue(2),
    "htype": JSONValue(1),
    "hlen": JSONValue(6),
    "hops": JSONValue(0),
    "xid": JSONValue(42),
    "secs": JSONValue(0),
    "broadcast": JSONValue(false),
    "ciaddr": JSONValue(ipToString([127, 0, 0, 1])),
    "yiaddr": JSONValue(ipToString([127, 0, 1, 1])),
    "siaddr": JSONValue(ipToString([10, 14, 19, 42])),
    "giaddr": JSONValue(ipToString([10, 14, 59, 255])),
    "chaddr": JSONValue((new ubyte[16]).toJsonArray),
    "sname": JSONValue((new ubyte[64]).toJsonArray),
    "file": JSONValue((new ubyte[128]).toJsonArray),
    "options": JSONValue((options).toJsonArray)
  ];
  DHCP packet = cast(DHCP)to!DHCP(json);
  assert(packet.toJson["op"] == 2);
  assert(packet.toJson["htype"] == 1);
  assert(packet.toJson["hlen"] == 6);
  assert(packet.toJson["hops"] == 0);
  assert(packet.toJson["xid"] == 42);
  assert(packet.toJson["secs"] == 0);
  assert(packet.toJson["broadcast"] == false);
  assert(packet.toJson["ciaddr"] == "127.0.0.1");
  assert(packet.toJson["yiaddr"] == "127.0.1.1");
  assert(packet.toJson["siaddr"] == "10.14.19.42");
  assert(packet.toJson["giaddr"] == "10.14.59.255");
}

unittest  {
  import netload.protocols.raw;

  ubyte[] options;
  JSONValue json = [
    "name": JSONValue("DHCP"),
    "op": JSONValue(2),
    "htype": JSONValue(1),
    "hlen": JSONValue(6),
    "hops": JSONValue(0),
    "xid": JSONValue(42),
    "secs": JSONValue(0),
    "broadcast": JSONValue(false),
    "ciaddr": JSONValue(ipToString([127, 0, 0, 1])),
    "yiaddr": JSONValue(ipToString([127, 0, 1, 1])),
    "siaddr": JSONValue(ipToString([10, 14, 19, 42])),
    "giaddr": JSONValue(ipToString([10, 14, 59, 255])),
    "chaddr": JSONValue((new ubyte[16]).toJsonArray),
    "sname": JSONValue((new ubyte[64]).toJsonArray),
    "file": JSONValue((new ubyte[128]).toJsonArray),
    "options": JSONValue((options).toJsonArray)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": JSONValue((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  DHCP packet = cast(DHCP)to!DHCP(json);
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
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [2, 1, 6, 0, 0, 0, 0, 42, 0, 0, 0, 0, 127, 0, 0, 1, 127, 0, 1, 1, 10, 14, 19, 42, 10, 14, 59, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 56, 0];
  DHCP packet = cast(DHCP)encodedPacket.to!DHCP;
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
