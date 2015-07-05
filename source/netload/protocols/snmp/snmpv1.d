module netload.protocols.snmp.v1;

import std.string;

import vibe.data.json;

import netload.core.protocol;
import netload.protocols.snmp.asn_1;

class SNMPv1 : Protocol {
  public:
    this() {}

    override Json toJson() const {
      auto json = Json.emptyObject;
      json.ver = ver;
      json.community_string = communityString;
      json.pdu = serializeToJson(_pdu);
      json.name = name;
      return json;
    }

    unittest {
      SNMPv1 snmp = new SNMPv1;
      snmp.ver = 1;
      snmp.communityString = "public";
      snmp.pdu.type = ASN1.Type.SET_REQUEST_PDU;
      snmp.pdu.data = [
        0x02, 0x01, 0x3a, 0x02, 0x01, 0x00, 0x02, 0x01,
        0x00, 0x30, 0x6d, 0x30, 0x13, 0x06, 0x0e, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x04,
        0x30, 0x21, 0x06, 0x0e, 0x2b, 0x06, 0x01, 0x04,
        0x01, 0x81, 0x7d, 0x08, 0x33, 0x08, 0x02, 0x01,
        0x03, 0x01, 0x04, 0x0f, 0x46, 0x75, 0x6a, 0x69,
        0x58, 0x65, 0x72, 0x6f, 0x78, 0x45, 0x78, 0x6f,
        0x64, 0x75, 0x73, 0x30, 0x1d, 0x06, 0x0e, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x01, 0x04, 0x01, 0x06, 0x0b, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x30, 0x14, 0x06, 0x0e, 0x2b, 0x06,
        0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33, 0x08,
        0x02, 0x01, 0x05, 0x01, 0x02, 0x02, 0x01, 0x2c
      ];

      auto json = snmp.toJson;
      assert(json.ver.to!int == 1);
      assert(json.community_string.to!string == "public");
      assert(json.pdu["type"].get!ubyte == ASN1.Type.SET_REQUEST_PDU);
      assert(deserializeJson!(ubyte[])(json.pdu.data) == [
        0x02, 0x01, 0x3a, 0x02, 0x01, 0x00, 0x02, 0x01,
        0x00, 0x30, 0x6d, 0x30, 0x13, 0x06, 0x0e, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x04,
        0x30, 0x21, 0x06, 0x0e, 0x2b, 0x06, 0x01, 0x04,
        0x01, 0x81, 0x7d, 0x08, 0x33, 0x08, 0x02, 0x01,
        0x03, 0x01, 0x04, 0x0f, 0x46, 0x75, 0x6a, 0x69,
        0x58, 0x65, 0x72, 0x6f, 0x78, 0x45, 0x78, 0x6f,
        0x64, 0x75, 0x73, 0x30, 0x1d, 0x06, 0x0e, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x01, 0x04, 0x01, 0x06, 0x0b, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x30, 0x14, 0x06, 0x0e, 0x2b, 0x06,
        0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33, 0x08,
        0x02, 0x01, 0x05, 0x01, 0x02, 0x02, 0x01, 0x2c
      ]);
    }

    override ubyte[] toBytes() const {
      ASN1 seq;
      seq.type = ASN1.Type.SEQUENCE;

      ASN1 ver;
      ver.type = ASN1.Type.INTEGER;
      ver.data = [ cast(ubyte)(this.ver - 1) ];
      seq.data = ver.toBytes;

      ASN1 communityString;
      communityString.type = ASN1.Type.OCTET_STRING;
      communityString.data = cast(ubyte[])(this.communityString);
      seq.data ~= communityString.toBytes;

      seq.data ~= this._pdu.toBytes;

      return seq.toBytes;
    }

    unittest {
      SNMPv1 snmp = new SNMPv1;
      snmp.ver = 1;
      snmp.communityString = "public";
      snmp.pdu.type = ASN1.Type.SET_REQUEST_PDU;
      snmp.pdu.data = [
        0x02, 0x01, 0x3a, 0x02, 0x01, 0x00, 0x02, 0x01,
        0x00, 0x30, 0x6d, 0x30, 0x13, 0x06, 0x0e, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x04,
        0x30, 0x21, 0x06, 0x0e, 0x2b, 0x06, 0x01, 0x04,
        0x01, 0x81, 0x7d, 0x08, 0x33, 0x08, 0x02, 0x01,
        0x03, 0x01, 0x04, 0x0f, 0x46, 0x75, 0x6a, 0x69,
        0x58, 0x65, 0x72, 0x6f, 0x78, 0x45, 0x78, 0x6f,
        0x64, 0x75, 0x73, 0x30, 0x1d, 0x06, 0x0e, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x01, 0x04, 0x01, 0x06, 0x0b, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x30, 0x14, 0x06, 0x0e, 0x2b, 0x06,
        0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33, 0x08,
        0x02, 0x01, 0x05, 0x01, 0x02, 0x02, 0x01, 0x2c
      ];

      assert(snmp.toBytes == [
        0x30, 0x81, 0x85, 0x02, 0x01, 0x00, 0x04, 0x06,
        0x70, 0x75, 0x62, 0x6c, 0x69, 0x63, 0xa3, 0x78,
        0x02, 0x01, 0x3a, 0x02, 0x01, 0x00, 0x02, 0x01,
        0x00, 0x30, 0x6d, 0x30, 0x13, 0x06, 0x0e, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x04,
        0x30, 0x21, 0x06, 0x0e, 0x2b, 0x06, 0x01, 0x04,
        0x01, 0x81, 0x7d, 0x08, 0x33, 0x08, 0x02, 0x01,
        0x03, 0x01, 0x04, 0x0f, 0x46, 0x75, 0x6a, 0x69,
        0x58, 0x65, 0x72, 0x6f, 0x78, 0x45, 0x78, 0x6f,
        0x64, 0x75, 0x73, 0x30, 0x1d, 0x06, 0x0e, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x01, 0x04, 0x01, 0x06, 0x0b, 0x2b,
        0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
        0x08, 0x02, 0x30, 0x14, 0x06, 0x0e, 0x2b, 0x06,
        0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33, 0x08,
        0x02, 0x01, 0x05, 0x01, 0x02, 0x02, 0x01, 0x2c
      ]);
    }

    override string toString() const {
      return toJson.toString;
    }

    @property {
      Protocol data() { return null; }
      void data(Protocol) {}

      inout string name() { return "SNMPv1"; }

      int osiLayer() const { return 7; }

      int ver() const { return _version; }
      void ver(int data) { _version = data; }

      string communityString() const { return _communityString; }
      void communityString(string data) { _communityString = data; }

      ref ASN1 pdu() { return _pdu; }
    }

  private:
    int _version;
    string _communityString;
    ASN1 _pdu;
}

Protocol toSNMPv1(Json json) {
  auto snmp = new SNMPv1;
  snmp.ver = json.ver.to!int;
  snmp.communityString = json.community_string.to!string;
  snmp.pdu = deserializeJson!ASN1(json.pdu);
  auto data = ("data" in json);
  if (json.data.type != Json.Type.Null && data != null)
    snmp.data = netload.protocols.conversion.protocolConversion[deserializeJson!string(data.name)](*data);
  return snmp;
}

unittest {
  ASN1 pdu;
  pdu.type = ASN1.Type.SET_REQUEST_PDU;
  pdu.data = [
    0x02, 0x01, 0x3a, 0x02, 0x01, 0x00, 0x02, 0x01,
    0x00, 0x30, 0x6d, 0x30, 0x13, 0x06, 0x0e, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x04,
    0x30, 0x21, 0x06, 0x0e, 0x2b, 0x06, 0x01, 0x04,
    0x01, 0x81, 0x7d, 0x08, 0x33, 0x08, 0x02, 0x01,
    0x03, 0x01, 0x04, 0x0f, 0x46, 0x75, 0x6a, 0x69,
    0x58, 0x65, 0x72, 0x6f, 0x78, 0x45, 0x78, 0x6f,
    0x64, 0x75, 0x73, 0x30, 0x1d, 0x06, 0x0e, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x01, 0x04, 0x01, 0x06, 0x0b, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x30, 0x14, 0x06, 0x0e, 0x2b, 0x06,
    0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33, 0x08,
    0x02, 0x01, 0x05, 0x01, 0x02, 0x02, 0x01, 0x2c
  ];

  Json json = Json.emptyObject;
  json.ver = 1;
  json.community_string = "public";
  json.pdu = serializeToJson(pdu);

  auto snmp = cast(SNMPv1)toSNMPv1(json);
  assert(snmp.ver == 1);
  assert(snmp.communityString == "public");
  assert(snmp.pdu.type == ASN1.Type.SET_REQUEST_PDU);
  assert(snmp.pdu.length == 120);
  assert(snmp.pdu.data == [
    0x02, 0x01, 0x3a, 0x02, 0x01, 0x00, 0x02, 0x01,
    0x00, 0x30, 0x6d, 0x30, 0x13, 0x06, 0x0e, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x04,
    0x30, 0x21, 0x06, 0x0e, 0x2b, 0x06, 0x01, 0x04,
    0x01, 0x81, 0x7d, 0x08, 0x33, 0x08, 0x02, 0x01,
    0x03, 0x01, 0x04, 0x0f, 0x46, 0x75, 0x6a, 0x69,
    0x58, 0x65, 0x72, 0x6f, 0x78, 0x45, 0x78, 0x6f,
    0x64, 0x75, 0x73, 0x30, 0x1d, 0x06, 0x0e, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x01, 0x04, 0x01, 0x06, 0x0b, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x30, 0x14, 0x06, 0x0e, 0x2b, 0x06,
    0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33, 0x08,
    0x02, 0x01, 0x05, 0x01, 0x02, 0x02, 0x01, 0x2c
  ]);
}

Protocol toSNMPv1(ubyte[] bytes) {
  auto snmp = new SNMPv1;
  auto seq = bytes.toASN1.data.toASN1Seq;
  snmp.ver = seq[0].data[0] + 1;
  snmp.communityString = seq[1].data.assumeUTF;
  snmp.pdu = seq[2];
  return snmp;
}

unittest {
  ubyte[] raw = [
    0x30, 0x81, 0x85, 0x02, 0x01, 0x00, 0x04, 0x06,
    0x70, 0x75, 0x62, 0x6c, 0x69, 0x63, 0xa3, 0x78,
    0x02, 0x01, 0x3a, 0x02, 0x01, 0x00, 0x02, 0x01,
    0x00, 0x30, 0x6d, 0x30, 0x13, 0x06, 0x0e, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x04,
    0x30, 0x21, 0x06, 0x0e, 0x2b, 0x06, 0x01, 0x04,
    0x01, 0x81, 0x7d, 0x08, 0x33, 0x08, 0x02, 0x01,
    0x03, 0x01, 0x04, 0x0f, 0x46, 0x75, 0x6a, 0x69,
    0x58, 0x65, 0x72, 0x6f, 0x78, 0x45, 0x78, 0x6f,
    0x64, 0x75, 0x73, 0x30, 0x1d, 0x06, 0x0e, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x01, 0x04, 0x01, 0x06, 0x0b, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x30, 0x14, 0x06, 0x0e, 0x2b, 0x06,
    0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33, 0x08,
    0x02, 0x01, 0x05, 0x01, 0x02, 0x02, 0x01, 0x2c
  ];
  auto snmp = cast(SNMPv1)raw.toSNMPv1;
  assert(snmp.ver == 1);
  assert(snmp.communityString == "public");
  assert(snmp.pdu.type == ASN1.Type.SET_REQUEST_PDU);
  assert(snmp.pdu.length == 120);
  assert(snmp.pdu.data == [
    0x02, 0x01, 0x3a, 0x02, 0x01, 0x00, 0x02, 0x01,
    0x00, 0x30, 0x6d, 0x30, 0x13, 0x06, 0x0e, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x04,
    0x30, 0x21, 0x06, 0x0e, 0x2b, 0x06, 0x01, 0x04,
    0x01, 0x81, 0x7d, 0x08, 0x33, 0x08, 0x02, 0x01,
    0x03, 0x01, 0x04, 0x0f, 0x46, 0x75, 0x6a, 0x69,
    0x58, 0x65, 0x72, 0x6f, 0x78, 0x45, 0x78, 0x6f,
    0x64, 0x75, 0x73, 0x30, 0x1d, 0x06, 0x0e, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x01, 0x04, 0x01, 0x06, 0x0b, 0x2b,
    0x06, 0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33,
    0x08, 0x02, 0x30, 0x14, 0x06, 0x0e, 0x2b, 0x06,
    0x01, 0x04, 0x01, 0x81, 0x7d, 0x08, 0x33, 0x08,
    0x02, 0x01, 0x05, 0x01, 0x02, 0x02, 0x01, 0x2c
  ]);
}
