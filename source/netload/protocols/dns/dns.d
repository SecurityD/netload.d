module netload.protocols.dns;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

union BitFields {
  ushort raw;
  mixin(bitfields!(
    bool, "qr", 1,
    uint, "opcode", 4,
    bool, "aa", 1,
    bool, "tc", 1,
    bool, "rd", 1,
    bool, "ra", 1,
    uint, "z", 3,
    uint, "rcode", 4
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
      packet.write!ushort(_bits.raw, 2);
      packet.write!ushort(_qdcount, 4);
      packet.write!ushort(_ancount, 6);
      packet.write!ushort(_nscount, 8);
      packet.write!ushort(_arcount, 10);
      return packet;
    }

    unittest {
      import std.stdio;
      auto packet = new DNS(10, 1);
      auto bytes = packet.toBytes;
      assert(bytes == [0, 10, 0, 64, 0, 0, 0, 0, 0, 0, 0, 0]);
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
  bits.raw = encodedPacket.read!ushort();
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
  ubyte[] encoded = [0, 10, 0, 64, 0, 0, 0, 0, 0, 0, 0, 0];
  DNS packet = encoded.toDNS;
  assert(packet.id == 10);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.qr == false);
  assert(packet.opcode == 0);
  assert(packet.aa == false);
  assert(packet.rd == false);
  assert(packet.tc == true);
  assert(packet.ra == false);
  assert(packet.z == 0);
  assert(packet.rcode == 0);
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
  bits.raw = encodedPacket.read!ushort();
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
  ubyte[] encoded = [0, 10, 0, 64, 0, 0, 0, 0, 0, 0, 0, 0];
  DNSQuery packet = encoded.toDNSQuery;
  assert(packet.id == 10);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.opcode == 0);
  assert(packet.rd == false);
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
  bits.raw = encodedPacket.read!ushort();
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
  ubyte[] encoded = [0, 10, 0, 64, 0, 0, 0, 0, 0, 0, 0, 0];
  DNS packet = encoded.toDNS;
  assert(packet.id == 10);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.aa == false);
  assert(packet.tc == true);
  assert(packet.ra == false);
  assert(packet.rcode == 0);
}
