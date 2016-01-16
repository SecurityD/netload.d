module netload.protocols.dns.dns;

import netload.core.protocol;
import netload.protocols;
import netload.core.addr;
import vibe.data.json;
import std.bitmanip;
import std.string;

alias DNS = DNSBase!(DNSType.ANY);
alias DNSQuery = DNSBase!(DNSType.QUERY);
alias DNSResource = DNSBase!(DNSType.RESOURCE);

enum OpCode {
  QUERY = 0,
  IQUERY = 1,
  STATUS = 2,
  NOTIFY = 4,
  UPDATE = 5
};

enum RCode {
  NO_ERROR = 0,
  FORMAT_ERROR = 1,
  SERVER_FAILURE = 2,
  NAME_ERROR = 3,
  NOT_IMPLEMENTED = 4,
  REFUSED = 5,
  YX_DOMAIN = 6,
  XY_RR_SET = 7,
  NX_RR_SET = 8,
  NOT_AUTH = 9,
  NOT_ZONE = 10
};

union BitFields {
  ubyte[2] raw;
  mixin(bitfields!(
	bool, "rd", 1,
	bool, "tc", 1,
	bool, "aa", 1,
	ubyte, "opcode", 4,
	bool, "qr", 1,
	ubyte, "rcode", 4,
	ubyte, "z", 3,
	bool, "ra", 1
	));
  };

enum DNSType {
  ANY,
  QUERY,
  RESOURCE
};

class DNSBase(DNSType __type__) : Protocol {
  public:
	this() {
	  _bits.raw[0] = 0;
	  _bits.raw[1] = 0;
	}

	this(Json json) {
	  static if (__type__ == DNSType.ANY) {
		this(json.id.to!ushort, json.truncation.to!bool);
		_bits.opcode = json.opcode.to!ubyte;
		_bits.rd = json.record_desired.to!bool;
		_bits.qr = json.qr.to!bool;
		_bits.aa = json.auth_answer.to!bool;
		_bits.ra = json.record_available.to!bool;
		_bits.z = json.zero.to!ubyte;
		_bits.rcode = json.rcode.to!ubyte;
	  }
	  else static if (__type__ == DNSType.QUERY) {
		this(json.id.to!ushort, json.truncation.to!bool, json.opcode.to!ubyte, json.record_desired.to!bool);
	  }
	  else static if (__type__ == DNSType.RESOURCE) {
		this(json.id.to!ushort, json.truncation.to!bool, json.auth_answer.to!bool, json.record_available.to!bool, json.rcode.to!ubyte);
	  }
	  qdcount = json.qdcount.to!ushort;
	  ancount = json.ancount.to!ushort;
	  nscount = json.nscount.to!ushort;
	  arcount = json.arcount.to!ushort;
	  auto packetData = ("data" in json);
	  if (json.data.type != Json.Type.Null && packetData != null)
		_data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
	}

	this(ubyte[] encodedPacket) {
	  id = encodedPacket.read!ushort();
	  _bits.raw[0] = encodedPacket.read!ubyte();
	  _bits.raw[1] = encodedPacket.read!ubyte();
	  qdcount = encodedPacket.read!ushort();
	  ancount = encodedPacket.read!ushort();
	  nscount = encodedPacket.read!ushort();
	  arcount = encodedPacket.read!ushort();
	}

	static if (__type__ == DNSType.ANY) {
	  this(ushort id = 0, bool truncation = 0) {
		this();
		_id = id;
		_bits.tc = truncation;
	  }
	}
	else static if (__type__ == DNSType.QUERY) {
	  this(ushort id, bool truncation, ubyte opcode, bool recDesired) {
		this();
		_id = id;
		_bits.tc = truncation;
		_bits.opcode = opcode;
		_bits.rd = recDesired;
	  }
	}
	else static if (__type__ == DNSType.RESOURCE) {
	  this(ushort id, bool truncation, bool authAnswer, bool recAvail, ubyte rcode) {
		this();
		_id = id;
		_bits.tc = truncation;
		_bits.qr = 1;
		_bits.aa = authAnswer;
		_bits.ra = recAvail;
		_bits.rcode = rcode;
	  }
	}

	override @property Protocol data() { return _data; }
	override @property inout string name() { return "DNS"; };
	override @property void data(Protocol p) { _data = p; }
	override @property int osiLayer() const { return 7; }

	override Json toJson() const {
	  Json packet = Json.emptyObject;
	  packet.id = _id;
	  packet.qr = _bits.qr;
	  packet.opcode = _bits.opcode;
	  packet.auth_answer = _bits.aa;
	  packet.truncation = _bits.tc;
	  packet.record_desired = _bits.rd;
	  packet.record_available = _bits.ra;
	  packet.zero = _bits.z;
	  packet.rcode = _bits.rcode;
	  packet.qdcount = _qdcount;
	  packet.ancount = _ancount;
	  packet.nscount = _nscount;
	  packet.arcount = _arcount;
	  packet.name = name;
	  if (_data is null)
		packet.data = null;
	  else
		packet.data = _data.toJson;
	  return packet;
	}

	unittest {
	  DNS packet = new DNS(10, true);
	  assert(packet.toJson().id == 10);
	  assert(packet.toJson().truncation == true);
	}

	unittest {
	  import netload.protocols.raw;
	  DNS packet = new DNS(10, true);

	  packet.data = new Raw([42, 21, 84]);

	  Json json = packet.toJson;
	  assert(json.name == "DNS");
	  assert(json.id == 10);
	  assert(json.truncation == true);

	  json = json.data;
	  assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
	}

	override ubyte[] toBytes() const {
	  ubyte[] packet = new ubyte[12];
	  packet.write!ushort(_id, 0);
	  packet.write!ubyte(_bits.raw[0], 2);
	  packet.write!ubyte(_bits.raw[1], 3);
	  packet.write!ushort(_qdcount, 4);
	  packet.write!ushort(_ancount, 6);
	  packet.write!ushort(_nscount, 8);
	  packet.write!ushort(_arcount, 10);
	  if (_data !is null)
		packet ~= _data.toBytes;
	  return packet;
	}

	unittest {
	  auto packet = new DNS(10, 1);
	  packet.rd = 1;
	  packet.aa = 1;
	  packet.opcode = 3;
	  packet.qr = 1;
	  packet.rcode = 2;
	  packet.z = 0;
	  packet.ra = 1;
	  auto bytes = packet.toBytes;
	  assert(bytes == [0, 10, 159, 130, 0, 0, 0, 0, 0, 0, 0, 0]);
	}

	unittest {
	  import netload.protocols.raw;

	  auto packet = new DNS(10, 1);
	  packet.rd = 1;
	  packet.aa = 1;
	  packet.opcode = 3;
	  packet.qr = 1;
	  packet.rcode = 2;
	  packet.z = 0;
	  packet.ra = 1;

	  packet.data = new Raw([42, 21, 84]);

	  assert(packet.toBytes == [0, 10, 159, 130, 0, 0, 0, 0, 0, 0, 0, 0] ~ [42, 21, 84]);
	}

	override string toString() const { return toJson().toPrettyString; }

	@property ushort id() { return _id; }
	@property void id(ushort id) { _id = id; }
	@property ushort qdcount() { return _qdcount; }
	@property void qdcount(ushort qdcount) { _qdcount = qdcount; }
	@property ushort ancount() { return _ancount; }
	@property void ancount(ushort port) { _ancount = ancount; }
	@property ushort nscount() { return _nscount; }
	@property void nscount(ushort nscount) { _nscount = nscount; }
	@property ushort arcount() { return _arcount; }
	@property void arcount(ushort arcount) { _arcount = arcount; }

	@property bool tc() { return _bits.tc; }
	@property void tc(bool tc) { _bits.tc = tc; }
	@property ubyte z() { return _bits.z; }
	@property void z(ubyte z) { _bits.z = z; }

	static if (__type__ != DNSType.RESOURCE) {
	  @property ubyte opcode() { return _bits.opcode; }
	  @property void opcode(ubyte opcode) { _bits.opcode = opcode; }
	  @property bool rd() { return _bits.rd; }
	  @property void rd(bool rd) { _bits.rd = rd; }
	}
	static if (__type__ != DNSType.QUERY) {
	  @property bool qr() { return _bits.qr; }
	  @property void qr(bool qr) { _bits.qr = qr; }
	  @property bool aa() { return _bits.aa; }
	  @property void aa(bool aa) { _bits.aa = aa; }
	  @property bool ra() { return _bits.ra; }
	  @property void ra(bool ra) { _bits.ra = ra; }
	  @property ubyte rcode() { return _bits.rcode; }
	  @property void rcode(ubyte rcode) { _bits.rcode = rcode; }
	}

  private:
	Protocol _data = null;
	ushort _id = 0;
	BitFields _bits;
	ushort _qdcount = 0;
	ushort _ancount = 0;
	ushort _nscount = 0;
	ushort _arcount = 0;
}

unittest {
  Json json = Json.emptyObject;
  json.qdcount = 0;
  json.ancount = 0;
  json.nscount = 0;
  json.arcount = 0;
  json.qr = false;
  json.opcode = 0;
  json.auth_answer = false;
  json.truncation = false;
  json.record_desired = true;
  json.record_available = false;
  json.zero = 0;
  json.rcode = 0;
  json.id = 0;
  DNS packet = cast(DNS)to!DNS(json);
  assert(packet.id == 0);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.qr == false);
  assert(packet.opcode == 0);
  assert(packet.aa == false);
  assert(packet.rd == true);
  assert(packet.tc == false);
  assert(packet.ra == false);
  assert(packet.z == 0);
  assert(packet.rcode == 0);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "DNS";
  json.qdcount = 0;
  json.ancount = 0;
  json.nscount = 0;
  json.arcount = 0;
  json.qr = false;
  json.opcode = 0;
  json.auth_answer = false;
  json.truncation = false;
  json.record_desired = true;
  json.record_available = false;
  json.zero = 0;
  json.rcode = 0;
  json.id = 0;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  DNS packet = cast(DNS)to!DNS(json);
  assert(packet.id == 0);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.qr == false);
  assert(packet.opcode == 0);
  assert(packet.aa == false);
  assert(packet.rd == true);
  assert(packet.tc == false);
  assert(packet.ra == false);
  assert(packet.z == 0);
  assert(packet.rcode == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encoded = [0, 10, 159, 130, 0, 0, 0, 0, 0, 0, 0, 0];
  DNS packet = cast(DNS)encoded.to!DNS;
  assert(packet.id == 10);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.qr == true);
  assert(packet.opcode == 3);
  assert(packet.aa == true);
  assert(packet.rd == true);
  assert(packet.tc == true);
  assert(packet.ra == true);
  assert(packet.z == 0);
  assert(packet.rcode == 2);
}

unittest {
  Json json = Json.emptyObject;
  json.qdcount = 0;
  json.ancount = 0;
  json.nscount = 0;
  json.arcount = 0;
  json.qr = false;
  json.opcode = 1;
  json.auth_answer = false;
  json.truncation = false;
  json.record_desired = true;
  json.record_available = true;
  json.zero = 0;
  json.rcode = 0;
  json.id = 0;
  DNSQuery packet = cast(DNSQuery)to!DNSQuery(json);
  assert(packet.id == 0);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.opcode == 1);
  assert(packet.rd == true);
  assert(packet.tc == false);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "DNS";
  json.qdcount = 0;
  json.ancount = 0;
  json.nscount = 0;
  json.arcount = 0;
  json.qr = false;
  json.opcode = 1;
  json.auth_answer = false;
  json.truncation = false;
  json.record_desired = true;
  json.record_available = true;
  json.zero = 0;
  json.rcode = 0;
  json.id = 0;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  DNSQuery packet = cast(DNSQuery)to!DNSQuery(json);
  assert(packet.id == 0);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.opcode == 1);
  assert(packet.rd == true);
  assert(packet.tc == false);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encoded = [0, 10, 159, 130, 0, 0, 0, 0, 0, 0, 0, 0];
  DNSQuery packet = cast(DNSQuery)encoded.to!DNSQuery;
  assert(packet.id == 10);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.opcode == 3);
  assert(packet.rd == true);
  assert(packet.tc == true);
}

unittest {
  Json json = Json.emptyObject;
  json.qdcount = 0;
  json.ancount = 0;
  json.nscount = 0;
  json.arcount = 0;
  json.qr = false;
  json.opcode = 0;
  json.auth_answer = false;
  json.truncation = false;
  json.record_desired = true;
  json.record_available = false;
  json.zero = 0;
  json.rcode = 0;
  json.id = 0;
  DNSResource packet = cast(DNSResource)to!DNSResource(json);
  assert(packet.id == 0);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.aa == false);
  assert(packet.tc == false);
  assert(packet.ra == false);
  assert(packet.rcode == 0);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "DNS";
  json.qdcount = 0;
  json.ancount = 0;
  json.nscount = 0;
  json.arcount = 0;
  json.qr = false;
  json.opcode = 0;
  json.auth_answer = false;
  json.truncation = false;
  json.record_desired = true;
  json.record_available = false;
  json.zero = 0;
  json.rcode = 0;
  json.id = 0;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  DNSResource packet = cast(DNSResource)to!DNSResource(json);
  assert(packet.id == 0);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.aa == false);
  assert(packet.tc == false);
  assert(packet.ra == false);
  assert(packet.rcode == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encoded = [0, 10, 159, 130, 0, 0, 0, 0, 0, 0, 0, 0];
  DNSResource packet = cast(DNSResource)encoded.to!DNSResource;
  assert(packet.id == 10);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.aa == true);
  assert(packet.tc == true);
  assert(packet.ra == true);
  assert(packet.rcode == 2);
}

enum QType {
  A	= 1,
  NS = 2,
  MD = 3,
  MF = 4,
  CNAME = 5,
  SOA = 6,
  MB = 7,
  MG = 8,
  MR = 9,
  NULL = 10,
  WKS = 11,
  PTR = 12,
  HINFO = 13,
  MINFO = 14,
  MX = 15,
  TXT = 16,
  RP = 17,
  AFSDB = 18,
  X25 = 19,
  ISDN = 20,
  RT = 21,
  NSAP = 22,
  NSAP_PTR = 23,
  SIG = 24,
  KEY = 25,
  PX = 26,
  GPOS = 27,
  AAAA = 28,
  LOC = 29,
  NXT = 30,
  EID = 31,
  NIMLOC = 32,
  SRV = 33,
  ATMA = 34,
  NAPTR = 35,
  KX = 36,
  CERT = 37,
  A6 = 38,
  DNAME = 39,
  SINK = 40,
  OPT = 41,
  APL = 42,
  DS = 43,
  SSHFP = 44,
  IPSECKEY = 45,
  RRSIG = 46,
  NSEC = 47,
  DNSKEY = 48,
  DHCID = 49,
  NSEC3 = 50,
  NSEC3PARAM = 51,
  TLSA = 52,
  HIP = 55,
  NINFO = 56,
  RKEY = 57,
  TALINK = 58,
  CDS = 59,
  CDNSKEY = 60,
  OPENPGPKEY = 61,
  CSYNC = 62,
  SPF = 99,
  UINFO = 100,
  UID = 101,
  GID = 102,
  UNSPEC = 103,
  NID = 104,
  L32 = 105,
  L64 = 106,
  LP = 107,
  EUI48 =108,
  EUI64 = 109,
  TKEY = 249,
  TSIG = 250,
  IXFR = 251,
  AXFR = 252,
  MAILB	= 253,
  MAILA	 =254,
  ANY =	255,
  URI = 256,
  CAA = 257,
  TA = 32768,
  DLV = 32769
}

enum QClass {
  IN = 1,
  CH = 3,
  HS = 4,
  NONE = 254,
  ANY = 255
}

private uint writeLabels(in uint pos, in string src, ref ubyte[] dest) {
  ubyte[] b = cast(ubyte[])src;
  ubyte len = 0;
  uint idx = 0;
  for (; idx < src.length; idx++) {
	if (b[idx] != '.') {
	  dest.write!ubyte(b[idx], idx + pos + 1);
	  ++len;
	}
	else {
	  dest.write!ubyte(len, idx + pos - len);
	  len = 0;
	}
  }
  if (len != 0)
	dest.write!ubyte(len, idx + pos - len);
  return (idx + 1);
}

private string readLabels(ref ubyte[] encodedPacket) {
  ubyte[] buffer;
  ubyte len = encodedPacket.read!ubyte();
  while (len != 0) {
	buffer ~= encodedPacket.read!ubyte();
	len--;
	if (len == 0) {
	  len = encodedPacket.read!ubyte();
	  if (len != 0)
		buffer ~= '.';
	}
  }
  return (cast(string)buffer);
}

class DNSQR : Protocol {
  public:
	this () {}

	this (string qname, ushort qtype, ushort qclass) {
	  _qname = qname;
	  _qtype = qtype;
	  _qclass = qclass;
	}

	this(Json json) {
	  this(json.qname.to!string, json.qtype.to!ushort, json.qclass.to!ushort);
	  auto packetData = ("data" in json);
	  if (json.data.type != Json.Type.Null && packetData != null)
		data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
	}

	this(ubyte[] encodedPacket) {
	  qname = readLabels(encodedPacket);
	  qtype = encodedPacket.read!ushort();
	  qclass = encodedPacket.read!ushort();
	}

	override @property inout string name() { return "DNSQR"; };
	override @property Protocol data() { return _data; }
	override @property void data(Protocol p) { _data = p; }
	override @property int osiLayer() const { return 7; }

	override Json toJson() const {
	  Json packet = Json.emptyObject;
	  packet.qname = _qname;
	  packet.qtype = _qtype;
	  packet.qclass = _qclass;
	  packet.name = name;
	  if (_data is null)
		packet.data = null;
	  else
		packet.data = _data.toJson;
	  return packet;
	}

	unittest {
	  DNSQR packet = new DNSQR("google.fr", QType.A, QClass.IN);
	  assert(packet.toJson().qname == "google.fr");
	  assert(packet.toJson().qtype == 1);
	  assert(packet.toJson().qclass == 1);
	}

	unittest {
	  import netload.protocols.raw;
	  DNSQR packet = new DNSQR("google.fr", QType.A, QClass.IN);

	  packet.data = new Raw([42, 21, 84]);

	  Json json = packet.toJson;
	  assert(json.name == "DNSQR");
	  assert(json.qname == "google.fr");
	  assert(json.qtype == 1);
	  assert(json.qclass == 1);

	  json = json.data;
	  assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
	}

	override ubyte[] toBytes() const {
	  ulong inc = (_qname.length > 1 ? _qname.length + 1 : 0);
	  ubyte[] packet = new ubyte[5 + inc];

	  writeLabels(0, _qname, packet);
	  packet.write!ushort(_qtype, (1 + inc));
	  packet.write!ushort(_qclass, (3 + inc));
	  if (_data !is null)
		packet ~= _data.toBytes;
	  return packet;
	}

	unittest {
	  auto packet = new DNSQR("google.fr", QType.A, QClass.IN);
	  auto bytes = packet.toBytes;
	  assert(bytes == [6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0, 0, 1, 0, 1]);
	}

	unittest {
	  import netload.protocols.raw;

	  auto packet = new DNSQR("google.fr", QType.A, QClass.IN);

	  packet.data = new Raw([42, 21, 84]);

	  assert(packet.toBytes == [6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0, 0, 1, 0, 1] ~ [42, 21, 84]);
	}

	override string toString() const {
	  return toJson().toString;
	}

	unittest {
	  auto packet = new DNSQR("google.fr", QType.A, QClass.IN);
	  assert(packet.toString == `{"qtype":1,"qname":"google.fr","name":"DNSQR","data":null,"qclass":1}`);
	}

	@property string qname() const { return _qname; }
	@property void qname(string qname) { _qname = qname; }
	@property ushort qtype() const { return _qtype; }
	@property void qtype(ushort qtype) { _qtype = qtype; }
	@property ushort qclass() const { return _qclass; }
	@property void qclass(ushort qclass) { _qclass = qclass; }

  private:
	Protocol _data = null;
	string _qname = ".";
	ushort _qtype = 1;
	ushort _qclass = 1;
}

unittest {
  Json json = Json.emptyObject;
  json.qname = "google.fr";
  json.qtype = QType.A;
  json.qclass = QClass.IN;
  DNSQR packet = cast(DNSQR)to!DNSQR(json);
  assert(packet.qname == "google.fr");
  assert(packet.qtype == 1);
  assert(packet.qclass == 1);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "DNSQR";
  json.qname = "google.fr";
  json.qtype = QType.A;
  json.qclass = QClass.IN;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  DNSQR packet = cast(DNSQR)to!DNSQR(json);
  assert(packet.qname == "google.fr");
  assert(packet.qtype == 1);
  assert(packet.qclass == 1);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] arr = [6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0, 0, 1, 00, 1];
  DNSQR packet = cast(DNSQR)arr.to!DNSQR;
  assert(packet.qname == "google.fr");
  assert(packet.qtype == 1);
  assert(packet.qclass == 1);
}

class DNSRR : Protocol {
  public:
	this() {}

	this(string rname, ushort rtype, ushort rclass, uint ttl) {
	  _rname = rname;
	  _rtype = rtype;
	  _rclass = rclass;
	  _ttl = ttl;
	}

	this(Json json) {
	  this(json.rname.to!string, json.rtype.to!ushort, json.rclass.to!ushort, json.ttl.to!uint);
	  rdlength = json.rdlength.to!ushort;
	  auto packetData = ("data" in json);
	  if (json.data.type != Json.Type.Null && packetData != null)
		data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
	}

	this(ubyte[] encodedPacket) {
	  rname = readLabels(encodedPacket);
	  rtype = encodedPacket.read!ushort();
	  rclass = encodedPacket.read!ushort();
	  ttl = encodedPacket.read!uint();
	  rdlength = encodedPacket.read!ushort();
	}

	override @property inout string name() { return "DNSRR"; };
	override @property Protocol data() { return _data; }
	override @property void data(Protocol p) { _data = p; }
	override @property int osiLayer() const { return 7; }

	override Json toJson() const {
	  Json packet = Json.emptyObject;
	  packet.rname = _rname;
	  packet.rtype = _rtype;
	  packet.rclass = _rclass;
	  packet.ttl = _ttl;
	  packet.rdlength = _rdlength;
	  packet.name = name;
	  if (_data is null)
		packet.data = null;
	  else
		packet.data = _data.toJson;
	  return packet;
	}

	unittest {
	  DNSRR packet = new DNSRR("google.fr", QType.A, QClass.IN, 2500);
	  assert(packet.toJson.rname == "google.fr");
	  assert(packet.toJson.rtype == 1);
	  assert(packet.toJson.rclass == 1);
	  assert(packet.toJson.ttl == 2500);
	  assert(packet.toJson.rdlength == 0);
	}

	unittest {
	  import netload.protocols.raw;
	  DNSRR packet = new DNSRR("google.fr", QType.A, QClass.IN, 2500);

	  packet.data = new Raw([42, 21, 84]);

	  Json json = packet.toJson;
	  assert(json.name == "DNSRR");
	  assert(json.rname == "google.fr");
	  assert(json.rtype == 1);
	  assert(json.rclass == 1);
	  assert(json.ttl == 2500);
	  assert(json.rdlength == 0);

	  json = json.data;
	  assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
	}

	override ubyte[] toBytes() const {
	  ulong inc = (_rname.length > 1 ? _rname.length + 1 : 0);
	  ubyte[] packet = new ubyte[11 + inc];
	  writeLabels(0, _rname, packet);
	  packet.write!ushort(_rtype, (1 + inc));
	  packet.write!ushort(_rclass, (3 + inc));
	  packet.write!uint(_ttl, (5 + inc));
	  packet.write!ushort(_rdlength, (9 + inc));
	  if (_data !is null)
		packet ~= _data.toBytes;
	  return packet;
	}

	unittest {
	  DNSRR packet = new DNSRR("google.fr", QType.A, QClass.IN, 2500);
	  assert(packet.toBytes == [6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0, 0, 1, 0, 1, 0, 0, 9, 196, 0, 0]);
	}

	unittest {
	  import netload.protocols.raw;

	  DNSRR packet = new DNSRR("google.fr", QType.A, QClass.IN, 2500);

	  packet.data = new Raw([42, 21, 84]);

	  assert(packet.toBytes == [6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0, 0, 1, 0, 1, 0, 0, 9, 196, 0, 0] ~ [42, 21, 84]);
	}

	override string toString() const {
	  return toJson().toString;
	}

	unittest {
	  DNSRR packet = new DNSRR("google.fr", QType.A, QClass.IN, 2500);
	  assert(packet.toString == `{"ttl":2500,"rname":"google.fr","name":"DNSRR","rtype":1,"rdlength":0,"data":null,"rclass":1}`);
	}

	@property string rname() { return _rname; }
	@property void rname(string rname) { _rname = rname; }
	@property ushort rtype() { return _rtype; }
	@property void rtype(ushort rtype) { _rtype = rtype; }
	@property ushort rclass() const { return _rclass; }
	@property void rclass(ushort rclass) { _rclass = rclass; }
	@property uint ttl() const { return _ttl; }
	@property void ttl(uint ttl) { _ttl = ttl; }
	@property ushort rdlength() const { return _rdlength; }
	@property void rdlength(ushort rdlength) { _rdlength = rdlength; }

  private:
	Protocol _data = null;
	string _rname = ".";
	ushort _rtype = 1;
	ushort _rclass = 1;
	uint _ttl = 0;
	ushort _rdlength = 0;
}

unittest {
  Json json = Json.emptyObject;
  json.rname = "google.fr";
  json.rtype = QType.A;
  json.rclass = QClass.IN;
  json.ttl = 600;
  json.rdlength = 10;
  DNSRR packet = cast(DNSRR)to!DNSRR(json);
  assert(packet.rname == "google.fr");
  assert(packet.rtype == 1);
  assert(packet.rclass == 1);
  assert(packet.ttl == 600);
  assert(packet.rdlength == 10);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "DNSRR";
  json.rname = "google.fr";
  json.rtype = QType.A;
  json.rclass = QClass.IN;
  json.ttl = 600;
  json.rdlength = 10;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  DNSRR packet = cast(DNSRR)to!DNSRR(json);
  assert(packet.rname == "google.fr");
  assert(packet.rtype == 1);
  assert(packet.rclass == 1);
  assert(packet.ttl == 600);
  assert(packet.rdlength == 10);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0, 0, 1, 0, 1, 0, 0, 9, 196, 0, 0];
  DNSRR packet = cast(DNSRR)encodedPacket.to!DNSRR;
  assert(packet.rname == "google.fr");
  assert(packet.rtype == 1);
  assert(packet.rclass == 1);
  assert(packet.ttl == 2500);
  assert(packet.rdlength == 0);
}

class DNSSOAResource  : Protocol {
  public:
	this() {}

	this(string primary, string admin, uint serial, uint refresh, uint retry, uint expirationLimit, uint minTtl) {
	  _primary = primary;
	  _admin = admin;
	  _serial = serial;
	  _refresh = refresh;
	  _retry = retry;
	  _expirationLimit = expirationLimit;
	  _minTtl = minTtl;
	}

	this(Json json) {
	  primary = json.primary.to!string;
	  admin = json.admin.to!string;
	  serial = json.serial.to!uint;
	  refresh = json.refresh.to!uint;
	  retry = json.retry.to!uint;
	  expirationLimit = json.expirationLimit.to!uint;
	  minTtl = json.minTtl.to!uint;
	  auto packetData = ("data" in json);
	  if (json.data.type != Json.Type.Null && packetData != null)
		data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
	}

	this(ubyte[] encodedPacket) {
	  primary = readLabels(encodedPacket);
	  admin = readLabels(encodedPacket);
	  serial = encodedPacket.read!uint();
	  refresh = encodedPacket.read!uint();
	  retry = encodedPacket.read!uint();
	  expirationLimit = encodedPacket.read!uint();
	  minTtl = encodedPacket.read!uint();
	}

	override @property inout string name() { return "DNSSOAResource"; };
	override @property Protocol data() { return _data; }
	override @property void data(Protocol p) { _data = p; }
	override @property int osiLayer() const { return 7; }

	override Json toJson() const {
	  Json packet = Json.emptyObject;
	  packet.primary = _primary;
	  packet.admin = _admin;
	  packet.serial = _serial;
	  packet.refresh = _refresh;
	  packet.retry = _retry;
	  packet.expirationLimit = _expirationLimit;
	  packet.minTtl = _minTtl;
	  packet.name = name;
	  if (_data is null)
		packet.data = null;
	  else
		packet.data = _data.toJson;
	  return packet;
	}

	unittest {
	  DNSSOAResource packet = new DNSSOAResource();
	  assert(packet.toJson.primary == ".");
	  assert(packet.toJson.admin == ".");
	  assert(packet.toJson.serial == 0);
	  assert(packet.toJson.refresh == 0);
	  assert(packet.toJson.retry == 0);
	  assert(packet.toJson.expirationLimit == 0);
	  assert(packet.toJson.minTtl == 0);
	}

	unittest {
	  import netload.protocols.raw;
	  DNSSOAResource packet = new DNSSOAResource();

	  packet.data = new Raw([42, 21, 84]);

	  Json json = packet.toJson;
	  assert(json.name == "DNSSOAResource");
	  assert(json.primary == ".");
	  assert(json.admin == ".");
	  assert(json.serial == 0);
	  assert(json.refresh == 0);
	  assert(json.retry == 0);
	  assert(json.expirationLimit == 0);
	  assert(json.minTtl == 0);

	  json = json.data;
	  assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
	}

	override ubyte[] toBytes() const {
	  ulong inc = (_primary.length > 1 ? _primary.length + 1 : 0) + (_admin.length > 1 ? _admin.length + 1 : 0);
	  ubyte[] packet = new ubyte[22 + inc];
	  uint pos = 0;

	  pos += writeLabels(pos, _primary, packet) + 1;
	  writeLabels(pos, _admin, packet);
	  packet.write!uint(_serial, (2 + inc));
	  packet.write!uint(_refresh, (6 + inc));
	  packet.write!uint(_retry, (10 + inc));
	  packet.write!uint(_expirationLimit, (14 + inc));
	  packet.write!uint(_minTtl, (18 + inc));
	  if (_data !is null)
		packet ~= _data.toBytes;
	  return packet;
	}

	unittest {
	  DNSSOAResource packet = new DNSSOAResource("ch1mgt0101dc120.prdmgt01.prod.exchangelabs", "msnhst.microsoft", 1500, 600, 600, 3500, 86420);
	  assert(packet.toBytes == [15, 99, 104, 49, 109, 103, 116, 48, 49, 48, 49, 100, 99, 49, 50, 48, 8, 112, 114, 100, 109, 103, 116, 48, 49, 4, 112, 114, 111, 100, 12, 101, 120, 99, 104, 97, 110, 103, 101, 108, 97, 98, 115, 0, 6, 109, 115, 110, 104, 115, 116, 9, 109, 105, 99, 114, 111, 115, 111, 102, 116, 0, 0, 0, 5, 220, 0, 0, 2, 88, 0, 0, 2, 88, 0, 0, 13, 172, 0, 1, 81, 148]);
	}

	unittest {
	  import netload.protocols.raw;

	  DNSSOAResource packet = new DNSSOAResource("ch1mgt0101dc120.prdmgt01.prod.exchangelabs", "msnhst.microsoft", 1500, 600, 600, 3500, 86420);

	  packet.data = new Raw([42, 21, 84]);

	  assert(packet.toBytes == [15, 99, 104, 49, 109, 103, 116, 48, 49, 48, 49, 100, 99, 49, 50, 48, 8, 112, 114, 100, 109, 103, 116, 48, 49, 4, 112, 114, 111, 100, 12, 101, 120, 99, 104, 97, 110, 103, 101, 108, 97, 98, 115, 0, 6, 109, 115, 110, 104, 115, 116, 9, 109, 105, 99, 114, 111, 115, 111, 102, 116, 0, 0, 0, 5, 220, 0, 0, 2, 88, 0, 0, 2, 88, 0, 0, 13, 172, 0, 1, 81, 148] ~ [42, 21, 84]);
	}

	override string toString() const { return toJson.toPrettyString; }

	unittest {
	  DNSSOAResource packet = new DNSSOAResource("ch1mgt0101dc120.prdmgt01.prod.exchangelabs", "msnhst.microsoft", 1500, 600, 600, 3500, 86420);
	}

	@property string primary() const { return _primary; }
	@property void primary(string primary) { _primary = primary; }
	@property string admin() const { return _admin; }
	@property void admin(string admin) { _admin = admin; }
	@property uint serial() const { return _serial; }
	@property void serial(uint serial) { _serial = serial; }
	@property uint refresh() const { return _refresh; }
	@property void refresh(uint refresh) { _refresh = refresh; }
	@property uint retry() const { return _retry; }
	@property void retry(uint retry) { _retry = retry; }
	@property uint expirationLimit() const { return _expirationLimit; }
	@property void expirationLimit(uint expirationLimit) { _expirationLimit = expirationLimit; }
	@property uint minTtl() const { return _minTtl; }
	@property void minTtl(uint minTtl) { _minTtl = minTtl; }

  private:
	Protocol _data = null;
	string _primary = ".";
	string _admin = ".";
	uint _serial = 0;
	uint _refresh = 0;
	uint _retry = 0;
	uint _expirationLimit = 0;
	uint _minTtl = 0;
}

unittest {
  Json json = Json.emptyObject;
  json.primary = "google.fr";
  json.admin = "admin.google.fr";
  json.serial = 8000;
  json.refresh = 2500;
  json.retry = 2500;
  json.expirationLimit = 400;
  json.minTtl = 10;
  DNSSOAResource packet = cast(DNSSOAResource)to!DNSSOAResource(json);
  assert(packet.primary == "google.fr");
  assert(packet.admin == "admin.google.fr");
  assert(packet.serial == 8000);
  assert(packet.refresh == 2500);
  assert(packet.retry == 2500);
  assert(packet.expirationLimit == 400);
  assert(packet.minTtl == 10);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "DNSSOAResource";
  json.primary = "google.fr";
  json.admin = "admin.google.fr";
  json.serial = 8000;
  json.refresh = 2500;
  json.retry = 2500;
  json.expirationLimit = 400;
  json.minTtl = 10;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  DNSSOAResource packet = cast(DNSSOAResource)to!DNSSOAResource(json);
  assert(packet.primary == "google.fr");
  assert(packet.admin == "admin.google.fr");
  assert(packet.serial == 8000);
  assert(packet.refresh == 2500);
  assert(packet.retry == 2500);
  assert(packet.expirationLimit == 400);
  assert(packet.minTtl == 10);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [15, 99, 104, 49, 109, 103, 116, 48, 49, 48, 49, 100, 99, 49, 50, 48, 8, 112, 114, 100, 109, 103, 116, 48, 49, 4, 112, 114, 111, 100, 12, 101, 120, 99, 104, 97, 110, 103, 101, 108, 97, 98, 115, 0, 6, 109, 115, 110, 104, 115, 116, 9, 109, 105, 99, 114, 111, 115, 111, 102, 116, 0, 0, 0, 5, 220, 0, 0, 2, 88, 0, 0, 2, 88, 0, 0, 13, 172, 0, 1, 81, 148];
  DNSSOAResource packet = cast(DNSSOAResource)encodedPacket.to!DNSSOAResource;
  assert(packet.primary == "ch1mgt0101dc120.prdmgt01.prod.exchangelabs");
  assert(packet.admin == "msnhst.microsoft");
  assert(packet.serial == 1500);
  assert(packet.refresh == 600);
  assert(packet.retry == 600);
  assert(packet.expirationLimit == 3500);
  assert(packet.minTtl == 86420);
}

class DNSMXResource : Protocol {
  public:
	this() {}

	this(ushort pref, string mxname) {
	  _pref = pref;
	  _mxname = mxname;
	}

	this(Json json) {
	  pref = json.pref.to!ushort;
	  mxname = json.mxname.to!string;
	  auto packetData = ("data" in json);
	  if (json.data.type != Json.Type.Null && packetData != null)
		data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
	}

	this(ubyte[] encodedPacket) {
	  pref = encodedPacket.read!ushort;
	  mxname = readLabels(encodedPacket);
	}

	override @property inout string name() { return "DNSMXResource"; };
	override @property Protocol data() { return _data; }
	override @property void data(Protocol p) { _data = p; }
	override @property int osiLayer() const { return 7; }

	override Json toJson() const {
	  Json packet = Json.emptyObject;
	  packet.mxname = _mxname;
	  packet.pref = _pref;
	  packet.name = name;
	  if (_data is null)
		packet.data = null;
	  else
		packet.data = _data.toJson;
	  return packet;
	}

	unittest {
	  DNSMXResource packet = new DNSMXResource(2, "google.fr");
	  assert(packet.toJson.mxname == "google.fr");
	  assert(packet.toJson.pref == 2);
	}

	unittest {
	  import netload.protocols.raw;
	  DNSMXResource packet = new DNSMXResource(2, "google.fr");

	  packet.data = new Raw([42, 21, 84]);

	  Json json = packet.toJson;
	  assert(json.name == "DNSMXResource");
	  assert(json.mxname == "google.fr");
	  assert(json.pref == 2);

	  json = json.data;
	  assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
	}

	override ubyte[] toBytes() const {
	  ulong inc = (_mxname.length > 1 ? _mxname.length + 1 : 0);
	  ubyte[] packet = new ubyte[3 + inc];
	  packet.write!ushort(_pref, 0);
	  writeLabels(2, _mxname, packet);
	  if (_data !is null)
		packet ~= _data.toBytes;
	  return packet;
	}

	unittest {
	  DNSMXResource packet = new DNSMXResource(2, "google.fr");
	  assert(packet.toBytes == [0, 2, 6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0]);
	}

	unittest {
	  import netload.protocols.raw;

	  DNSMXResource packet = new DNSMXResource(2, "google.fr");

	  packet.data = new Raw([42, 21, 84]);

	  assert(packet.toBytes == [0, 2, 6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0] ~ [42, 21, 84]);
	}

	override string toString() const { return toJson.toPrettyString; }

	@property ushort pref() const { return _pref; }
	@property void pref(ushort pref) { _pref = pref; }
	@property string mxname() { return _mxname; }
	@property void mxname(string mxname) { _mxname = mxname; }

  private:
	Protocol _data = null;
	ushort _pref = 0;
	string _mxname = ".";
}

unittest {
  Json json = Json.emptyObject;
  json.pref = 1;
  json.mxname = "google.fr";
  DNSMXResource packet = cast(DNSMXResource)to!DNSMXResource(json);
  assert(packet.pref == 1);
  assert(packet.mxname == "google.fr");
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "DNSMXResource";
  json.pref = 1;
  json.mxname = "google.fr";

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  DNSMXResource packet = cast(DNSMXResource)to!DNSMXResource(json);
  assert(packet.pref == 1);
  assert(packet.mxname == "google.fr");
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [0, 2, 6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0];
  DNSMXResource packet = cast(DNSMXResource)encodedPacket.to!DNSMXResource;
  assert(packet.pref == 2);
  assert(packet.mxname == "google.fr");
}

class DNSAResource : Protocol {
  public:
	this() {}

	this(ubyte[4] ip) {
	  _ip = ip;
	}

	this(Json json) {
	  ip = stringToIp(json.ip.to!string);
	  auto packetData = ("data" in json);
	  if (json.data.type != Json.Type.Null && packetData != null)
		data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
	}

	this(ubyte[] encodedPacket) {
	  ip[0..4] = encodedPacket[0..4];
	}

	override @property inout string name() { return "DNSAResource"; };
	override @property Protocol data() { return _data; }
	override @property void data(Protocol p) { _data = p; }
	override @property int osiLayer() const { return 7; }

	override Json toJson() const {
	  Json packet = Json.emptyObject;
	  packet.ip = ipToString(_ip);
	  packet.name = name;
	  if (_data is null)
		packet.data = null;
	  else
		packet.data = _data.toJson;
	  return packet;
	}

	unittest {
	  DNSAResource packet = new DNSAResource();
	  assert(packet.toJson.ip == "127.0.0.1");
	}

	unittest {
	  import netload.protocols.raw;
	  DNSAResource packet = new DNSAResource();

	  packet.data = new Raw([42, 21, 84]);

	  Json json = packet.toJson;
	  assert(json.name == "DNSAResource");
	  assert(json.ip == "127.0.0.1");

	  json = json.data;
	  assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
	}

	override ubyte[] toBytes() const {
	  ubyte[] packet;
	  packet ~= _ip;
	  if (_data !is null)
		packet ~= _data.toBytes;
	  return packet;
	}

	unittest {
	  DNSAResource packet = new DNSAResource();
	  assert(packet.toBytes == [127, 0, 0, 1]);
	}

	unittest {
	  import netload.protocols.raw;

	  DNSAResource packet = new DNSAResource();

	  packet.data = new Raw([42, 21, 84]);

	  assert(packet.toBytes == [127, 0, 0, 1] ~ [42, 21, 84]);
	}

	override string toString() const { return toJson.toPrettyString; }

	@property ubyte[4] ip() const { return _ip; }
	@property void ip(ubyte[4] ip) { _ip = ip; }

  private:
	Protocol _data = null;
	ubyte[4] _ip = [127, 0, 0, 1];
}

unittest {
  Json json = Json.emptyObject;
  json.ip = ipToString([127, 0, 0, 1]);
  DNSAResource packet = cast(DNSAResource)to!DNSAResource(json);
  assert(packet.ip == [127, 0, 0, 1]);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "DNSAResource";
  json.ip = ipToString([127, 0, 0, 1]);

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  DNSAResource packet = cast(DNSAResource)to!DNSAResource(json);
  assert(packet.ip == [127, 0, 0, 1]);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [127, 0, 0, 1];
  DNSAResource packet = cast(DNSAResource)encodedPacket.to!DNSAResource;
  assert(packet.ip == [127, 0, 0, 1]);
}

class DNSPTRResource : Protocol {
  public:
	this() {}

	this(string ptrname) {
	  _ptrname = ptrname;
	}

	this(Json json) {
	  ptrname = json.ptrname.to!string;
	  auto packetData = ("data" in json);
	  if (json.data.type != Json.Type.Null && packetData != null)
		data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
	}

	this(ubyte[] encodedPacket) {
	  ptrname = readLabels(encodedPacket);
	}

	override @property inout string name() { return "DNSPTRResource"; };
	override @property Protocol data() { return _data; }
	override @property void data(Protocol p) { _data = p; }
	override @property int osiLayer() const { return 7; }

	override Json toJson() const {
	  Json packet = Json.emptyObject;
	  packet.ptrname = _ptrname;
	  packet.name = name;
	  if (_data is null)
		packet.data = null;
	  else
		packet.data = _data.toJson;
	  return packet;
	}

	unittest {
	  DNSPTRResource packet = new DNSPTRResource("google.fr");
	  assert(packet.toJson.ptrname == "google.fr");
	}

	unittest {
	  import netload.protocols.raw;
	  DNSPTRResource packet = new DNSPTRResource("google.fr");

	  packet.data = new Raw([42, 21, 84]);

	  Json json = packet.toJson;
	  assert(json.name == "DNSPTRResource");
	  assert(json.ptrname == "google.fr");

	  json = json.data;
	  assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
	}

	override ubyte[] toBytes() const {
	  ulong inc = (_ptrname.length > 1 ? _ptrname.length + 1 : 0);
	  ubyte[] packet = new ubyte[1 + inc];
	  writeLabels(0, _ptrname, packet);
	  if (_data !is null)
		packet ~= _data.toBytes;
	  return packet;
	}

	unittest {
	  DNSPTRResource packet = new DNSPTRResource("google.fr");
	  assert(packet.toBytes == [6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0]);
	}

	unittest {
	  import netload.protocols.raw;

	  DNSPTRResource packet = new DNSPTRResource("google.fr");

	  packet.data = new Raw([42, 21, 84]);

	  assert(packet.toBytes == [6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0] ~ [42, 21, 84]);
	}

	override string toString() const { return toJson.toPrettyString; }

	@property string ptrname() { return _ptrname; }
	@property void ptrname(string ptrname) { _ptrname = ptrname; }

  private:
	Protocol _data = null;
	string _ptrname;
}

unittest {
  Json json = Json.emptyObject;
  json.ptrname = "google.fr";
  DNSPTRResource packet = cast(DNSPTRResource)to!DNSPTRResource(json);
  assert(packet.ptrname == "google.fr");
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "DNSAResource";
  json.ptrname = "google.fr";

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  DNSPTRResource packet = cast(DNSPTRResource)to!DNSPTRResource(json);
  assert(packet.ptrname == "google.fr");
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0];
  DNSPTRResource packet = cast(DNSPTRResource)encodedPacket.to!DNSPTRResource;
  assert(packet.ptrname == "google.fr");
}
