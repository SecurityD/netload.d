module netload.protocols.dns;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;
import std.string;

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
    uint, "opcode", 4,
    bool, "qr", 1,
    uint, "rcode", 4,
    uint, "z", 3,
    bool, "ra", 1
    ));
  };

class DNS : Protocol {
  public:

    this(ushort id = 0, bool truncation = 0) {
      _id = id;
      _bits.qr = 0;
      _bits.opcode = 0;
      _bits.aa = 0;
      _bits.tc = truncation;
      _bits.rd = 0;
      _bits.ra = 0;
      _bits.z = 0;
      _bits.rcode = 0;
    }

    @property Protocol data() { return _data; }

    void prepare() {

    }

    Json toJson() {
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
      return packet;
    }

    unittest {
      DNS packet = new DNS(10, true);
      assert(packet.toJson().id == 10);
      assert(packet.toJson().truncation == true);
    }

    ubyte[] toBytes() {
      ubyte[] packet = new ubyte[12];
      packet.write!ushort(_id, 0);
      packet.write!ubyte(_bits.raw[0], 2);
      packet.write!ubyte(_bits.raw[1], 3);
      packet.write!ushort(_qdcount, 4);
      packet.write!ushort(_ancount, 6);
      packet.write!ushort(_nscount, 8);
      packet.write!ushort(_arcount, 10);
      return packet;
    }

    unittest {
      import std.stdio;
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

    override string toString() {
      return toJson().toString;
    }

    unittest {
      import std.stdio;
      DNS packet = new DNS(10, true);
      assert(packet.toString == `{"record_available":false,"zero":0,"id":10,"nscount":0,"opcode":0,"arcount":0,"auth_answer":false,"record_desired":false,"rcode":0,"qr":false,"truncation":true,"ancount":0,"qdcount":0}`);
    }

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

    @property bool qr() { return _bits.qr; }
    @property void qr(bool qr) { _bits.qr = qr; }
    @property uint opcode() { return _bits.opcode; }
    @property void opcode(uint opcode) { _bits.opcode = opcode; }
    @property bool aa() { return _bits.aa; }
    @property void aa(bool aa) { _bits.aa = aa; }
    @property bool tc() { return _bits.tc; }
    @property void tc(bool tc) { _bits.tc = tc; }
    @property bool rd() { return _bits.rd; }
    @property void rd(bool rd) { _bits.rd = rd; }
    @property bool ra() { return _bits.ra; }
    @property void ra(bool ra) { _bits.ra = ra; }
    @property uint z() { return _bits.z; }
    @property void z(uint z) { _bits.z = z; }
    @property uint rcode() { return _bits.rcode; }
    @property void rcode(uint rcode) { _bits.rcode = rcode; }

  private:
    Protocol _data;
    ushort _id = 0;
    BitFields _bits;
    ushort _qdcount = 0;
    ushort _ancount = 0;
    ushort _nscount = 0;
    ushort _arcount = 0;
}

class DNSQuery : DNS {
  public:
    this(ushort id, bool truncation, uint opcode, bool recDesired) {
      super(id, truncation);
      _bits.opcode = opcode;
      _bits.rd = recDesired;
    }

  @disable override @property bool qr() { return _bits.qr; }
  @disable override @property void qr(bool qr) { _bits.qr = qr; }
  @disable override @property bool aa() { return _bits.aa; }
  @disable override @property void aa(bool aa) { _bits.aa = aa; }
  @disable override @property bool ra() { return _bits.ra; }
  @disable override @property void ra(bool ra) { _bits.ra = ra; }
  @disable override @property uint z() { return _bits.z; }
  @disable override @property void z(uint z) { _bits.z = z; }
  @disable override @property uint rcode() { return _bits.rcode; }
  @disable override @property void rcode(uint rcode) { _bits.rcode = rcode; }
}

class DNSResponse : DNS {
  public:
    this(ushort id, bool truncation, bool authAnswer, bool recAvail, uint rcode) {
      super(id, truncation);
      _bits.qr = 1;
      _bits.aa = authAnswer;
      _bits.ra = recAvail;
      _bits.rcode = rcode;
    }

    @disable override @property bool qr() { return _bits.qr; }
    @disable override @property void qr(bool qr) { _bits.qr = qr; }
    @disable override @property uint opcode() { return _bits.opcode; }
    @disable override @property void opcode(uint opcode) { _bits.opcode = opcode; }
    @disable override @property bool rd() { return _bits.rd; }
    @disable override @property void rd(bool rd) { _bits.rd = rd; }
    @disable override @property uint z() { return _bits.z; }
    @disable override @property void z(uint z) { _bits.z = z; }
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
  QTYPE_ANY =	255,
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
  QCLASS_ANY = 255
}

class DNSQR : Protocol {
  public:
    this () {}

    this (string qname, ushort qtype, ushort qclass) {
      _qname = qname;
      _qtype = qtype;
      _qclass = qclass;
    }

    @property Protocol data() { return _data; }

    void prepare() {

    }

    Json toJson() {
      Json packet = Json.emptyObject;
      packet.qname = _qname;
      packet.qtype = _qtype;
      packet.qclass = _qclass;
      return packet;
    }

    unittest {
      DNSQR packet = new DNSQR("google.fr", QType.A, QClass.IN);
      assert(packet.toJson().qname == "google.fr");
      assert(packet.toJson().qtype == 1);
      assert(packet.toJson().qclass == 1);
    }

    ubyte[] toBytes() {
      ubyte[] packet = new ubyte[6 + _qname.length];

      ubyte[] b = cast(ubyte[])_qname;
      ubyte len = 0;
      ubyte idx;
      for (idx = 1; idx <= _qname.length; idx++) {
        if (b[idx - 1] != '.') {
          packet.write!ubyte(b[idx - 1], idx);
          ++len;
        }
        else {
          packet.write!ubyte(len, idx - len - 1);
          len = 0;
        }
      }
      if (idx != 1)
        packet.write!ubyte(len, idx - len - 1);
      packet.write!ubyte(0, idx);
      packet.write!ushort(_qtype, (2 + _qname.length));
      packet.write!ushort(_qclass, (4 + _qname.length));
      return packet;
    }

    unittest {
      auto packet = new DNSQR("google.fr", QType.A, QClass.IN);
      auto bytes = packet.toBytes;
      assert(bytes == [6, 103, 111, 111, 103, 108, 101, 2, 102, 114, 0, 0, 01, 00, 01]);
    }

    override string toString() {
      return toJson().toString;
    }

    unittest {
      auto packet = new DNSQR("google.fr", QType.A, QClass.IN);
      assert(packet.toString == `{"qname":"google.fr","qtype":1,"qclass":1}`);
    }

  private:
    Protocol _data;
    string _qname = ".";
    ushort _qtype = 1;
    ushort _qclass = 1;
}

DNS toDNS(Json json) {
  DNS packet = new DNS(json.id.to!ushort, json.truncation.to!bool);
  packet.qdcount = json.qdcount.to!ushort;
  packet.ancount = json.ancount.to!ushort;
  packet.nscount = json.nscount.to!ushort;
  packet.arcount = json.arcount.to!ushort;
  packet.qr = json.qr.to!bool;
  packet.opcode = json.opcode.to!uint;
  packet.aa = json.auth_answer.to!bool;
  packet.rd = json.record_desired.to!bool;
  packet.ra = json.record_available.to!bool;
  packet.z = json.zero.to!uint;
  packet.rcode = json.rcode.to!uint;
  return packet;
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
  DNS packet = toDNS(json);
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

DNS toDNS(ubyte[] encodedPacket) {
  BitFields bits;
  ushort id = encodedPacket.read!ushort();
  bits.raw[0] = encodedPacket.read!ubyte();
  bits.raw[1] = encodedPacket.read!ubyte();
  ushort qdcount = encodedPacket.read!ushort();
  ushort ancount = encodedPacket.read!ushort();
  ushort nscount = encodedPacket.read!ushort();
  ushort arcount = encodedPacket.read!ushort();
  DNS packet = new DNS(id, bits.tc);
  packet.qdcount = qdcount;
  packet.ancount = ancount;
  packet.nscount = nscount;
  packet.arcount = arcount;
  packet.qr = bits.qr;
  packet.opcode = bits.opcode;
  packet.aa = bits.aa;
  packet.rd = bits.rd;
  packet.ra = bits.ra;
  packet.z = bits.z;
  packet.rcode =  bits.rcode;
  return packet;
}

unittest {
  ubyte[] encoded = [0, 10, 159, 130, 0, 0, 0, 0, 0, 0, 0, 0];
  DNS packet = encoded.toDNS;
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

DNSQuery toDNSQuery(Json json) {
  DNSQuery packet = new DNSQuery(json.id.to!ushort, json.truncation.to!bool, json.opcode.to!uint, json.record_desired.to!bool);
  packet.qdcount = json.qdcount.to!ushort;
  packet.ancount = json.ancount.to!ushort;
  packet.nscount = json.nscount.to!ushort;
  packet.arcount = json.arcount.to!ushort;
  return packet;
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
  DNSQuery packet = toDNSQuery(json);
  assert(packet.id == 0);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.opcode == 1);
  assert(packet.rd == true);
  assert(packet.tc == false);
}

DNSQuery toDNSQuery(ubyte[] encodedPacket) {
  BitFields bits;
  ushort id = encodedPacket.read!ushort();
  bits.raw[0] = encodedPacket.read!ubyte();
  bits.raw[1] = encodedPacket.read!ubyte();
  ushort qdcount = encodedPacket.read!ushort();
  ushort ancount = encodedPacket.read!ushort();
  ushort nscount = encodedPacket.read!ushort();
  ushort arcount = encodedPacket.read!ushort();
  DNSQuery packet = new DNSQuery(id, bits.tc, bits.opcode, bits.rd);
  packet.qdcount = qdcount;
  packet.ancount = ancount;
  packet.nscount = nscount;
  packet.arcount = arcount;
  return packet;
}

unittest {
  ubyte[] encoded = [0, 10, 159, 130, 0, 0, 0, 0, 0, 0, 0, 0];
  DNSQuery packet = encoded.toDNSQuery;
  assert(packet.id == 10);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.opcode == 3);
  assert(packet.rd == true);
  assert(packet.tc == true);
}


DNSResponse toDNSResponse(Json json) {
  DNSResponse packet = new DNSResponse(json.id.to!ushort, json.truncation.to!bool, json.auth_answer.to!bool, json.record_available.to!bool, json.rcode.to!uint);
  packet.qdcount = json.qdcount.to!ushort;
  packet.ancount = json.ancount.to!ushort;
  packet.nscount = json.nscount.to!ushort;
  packet.arcount = json.arcount.to!ushort;
  return packet;
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
  DNSResponse packet = toDNSResponse(json);
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

DNSResponse toDNSResponse(ubyte[] encodedPacket) {
  BitFields bits;
  ushort id = encodedPacket.read!ushort();
  bits.raw[0] = encodedPacket.read!ubyte();
  bits.raw[1] = encodedPacket.read!ubyte();
  ushort qdcount = encodedPacket.read!ushort();
  ushort ancount = encodedPacket.read!ushort();
  ushort nscount = encodedPacket.read!ushort();
  ushort arcount = encodedPacket.read!ushort();
  DNSResponse packet = new DNSResponse(id, bits.tc, bits.aa, bits.ra, bits.rcode);
  packet.qdcount = qdcount;
  packet.ancount = ancount;
  packet.nscount = nscount;
  packet.arcount = arcount;
  return packet;
}

unittest {
  ubyte[] encoded = [0, 10, 159, 130, 0, 0, 0, 0, 0, 0, 0, 0];
  DNS packet = encoded.toDNS;
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
