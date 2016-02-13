module netload.protocols.conversion;

import stdx.data.json;
import std.conv;
import netload.core.protocol;
import netload.core.addr;
import netload.core.conversion.json_array;

import netload.protocols.arp;
import netload.protocols.dhcp;
import netload.protocols.dns;
import netload.protocols.dot11;
import netload.protocols.ethernet;
import netload.protocols.http;
import netload.protocols.icmp;
import netload.protocols.imap;
import netload.protocols.ip;
import netload.protocols.ntp.v0;
import netload.protocols.ntp.v4;
import netload.protocols.pop3;
import netload.protocols.raw;
import netload.protocols.smtp;
import netload.protocols.snmp;
import netload.protocols.tcp;
import netload.protocols.udp;

/++
 + Converts the given `JSONValue` to the right `Protocol`.
 + The json must have a "name" field that contains the name of the protocol
 + and, of course, all the data that are necessary in its conversion.
 +/
Protocol toProtocol(JSONValue json) {
  if ("name" in json && json["name"] !is null)
    return protocolConversion[json["name"].get!string](json);
  throw new Exception("Invalid Json.");
}

/++
 + Map taking a string of the protocol name as key and a delegate as value
 + taking a `JSONValue` as parameter and that converts it
 + to the right `Protocol`.
 +/
Protocol delegate(JSONValue)[string] protocolConversion;

shared static this() {
  protocolConversion["ARP"] = delegate(JSONValue json){ return (cast(Protocol)ARP(json)); };
  protocolConversion["UDP"] = delegate(JSONValue json){ return (cast(Protocol)to!UDP(json)); };
  protocolConversion["TCP"] = delegate(JSONValue json){ return (cast(Protocol)to!TCP(json)); };
  protocolConversion["SNMPv1"] = delegate(JSONValue json){ return (cast(Protocol)to!SNMPv1(json)); };
  protocolConversion["SNMPv3"] = delegate(JSONValue json){ return (cast(Protocol)to!SNMPv3(json)); };
  protocolConversion["SMTP"] = delegate(JSONValue json){ return (cast(Protocol)to!SMTP(json)); };
  protocolConversion["Raw"] = delegate(JSONValue json){ return (cast(Protocol)to!Raw(json)); };
  protocolConversion["POP3"] = delegate(JSONValue json){ return (cast(Protocol)to!POP3(json)); };
  protocolConversion["NTPv0"] = delegate(JSONValue json){ return (cast(Protocol)to!NTPv0(json)); };
  protocolConversion["NTPv4"] = delegate(JSONValue json){ return (cast(Protocol)to!NTPv4(json)); };
  protocolConversion["IP"] = delegate(JSONValue json){ return (cast(Protocol)to!IP(json)); };
  protocolConversion["IMAP"] = delegate(JSONValue json){ return (cast(Protocol)to!IMAP(json)); };
  protocolConversion["ICMP"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMP(json)); };
  protocolConversion["ICMPv4Communication"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4Communication(json)); };
  protocolConversion["ICMPv4EchoRequest"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4EchoRequest(json)); };
  protocolConversion["ICMPv4EchoReply"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4EchoReply(json)); };
  protocolConversion["ICMPv4Timestamp"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4Timestamp(json)); };
  protocolConversion["ICMPv4TimestampRequest"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4TimestampRequest(json)); };
  protocolConversion["ICMPv4TimestampReply"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4TimestampReply(json)); };
  protocolConversion["ICMPv4InformationRequest"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4InformationRequest(json)); };
  protocolConversion["ICMPv4InformationReply"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4InformationReply(json)); };
  protocolConversion["ICMPv4Error"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4Error(json)); };
  protocolConversion["ICMPv4DestUnreach"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4DestUnreach(json)); };
  protocolConversion["ICMPv4TimeExceed"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4TimeExceed(json)); };
  protocolConversion["ICMPv4ParamProblem"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4ParamProblem(json)); };
  protocolConversion["ICMPv4SourceQuench"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4SourceQuench(json)); };
  protocolConversion["ICMPv4Redirect"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4Redirect(json)); };
  protocolConversion["ICMPv4RouterAdvert"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4RouterAdvert(json)); };
  protocolConversion["ICMPv4RouterSollicitation"] = delegate(JSONValue json){ return (cast(Protocol)to!ICMPv4RouterSollicitation(json)); };
  protocolConversion["HTTP"] = delegate(JSONValue json){ return (cast(Protocol)to!HTTP(json)); };
  protocolConversion["Ethernet"] = delegate(JSONValue json){ return (cast(Protocol)to!Ethernet(json)); };
  protocolConversion["Dot11"] = delegate(JSONValue json){ return (cast(Protocol)to!Dot11(json)); };
  protocolConversion["DHCP"] = delegate(JSONValue json){ return (cast(Protocol)to!DHCP(json)); };
  protocolConversion["DNS"] = delegate(JSONValue json){ return (cast(Protocol)DNS(json)); };
  protocolConversion["DNSQuery"] = delegate(JSONValue json){ return (cast(Protocol)DNSQuery(json)); };
  protocolConversion["DNSResource"] = delegate(JSONValue json){ return (cast(Protocol)DNSResource(json)); };
  protocolConversion["DNSQR"] = delegate(JSONValue json){ return (cast(Protocol)to!DNSQR(json)); };
  protocolConversion["DNSRR"] = delegate(JSONValue json){ return (cast(Protocol)to!DNSRR(json)); };
  protocolConversion["DNSSOAResource"] = delegate(JSONValue json){ return (cast(Protocol)to!DNSSOAResource(json)); };
  protocolConversion["DNSMXResource"] = delegate(JSONValue json){ return (cast(Protocol)to!DNSMXResource(json)); };
  protocolConversion["DNSAResource"] = delegate(JSONValue json){ return (cast(Protocol)to!DNSAResource(json)); };
  protocolConversion["DNSPTRResource"] = delegate(JSONValue json){ return (cast(Protocol)to!DNSPTRResource(json)); };
}

///
unittest {
  JSONValue json = [
    "hwType": JSONValue(1),
    "protocolType": JSONValue(1),
    "hwAddrLen": JSONValue(6),
    "protocolAddrLen": JSONValue(4),
    "opcode": JSONValue(0),
    "senderHwAddr": [128, 128, 128, 128, 128, 128].toJsonArray,
    "targetHwAddr": [0, 0, 0, 0, 0, 0].toJsonArray,
    "senderProtocolAddr": [127, 0, 0, 1].toJsonArray,
    "targetProtocolAddr": [10, 14, 255, 255].toJsonArray
  ];
  ARP packet = cast(ARP)(protocolConversion["ARP"](json));
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

///
unittest {
  JSONValue json = [
    "src_port": JSONValue(8000),
    "dest_port": JSONValue(7000),
    "len": JSONValue(0),
    "checksum": JSONValue(0)
  ];
  UDP packet = cast(UDP)(protocolConversion["UDP"](json));
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.length == 0);
  assert(packet.checksum == 0);
}

unittest {
  JSONValue json = [
    "src_port": JSONValue(8000),
    "dest_port": JSONValue(7000),
    "sequence_number": JSONValue(0),
    "ack_number": JSONValue(0),
    "fin": JSONValue(false),
    "syn": JSONValue(true),
    "rst": JSONValue(false),
    "psh": JSONValue(false),
    "ack": JSONValue(true),
    "urg": JSONValue(false),
    "reserved": JSONValue(0),
    "offset": JSONValue(0),
    "window": JSONValue(0),
    "checksum": JSONValue(0),
    "urgent_ptr": JSONValue(0)
  ];
  TCP packet = cast(TCP)(protocolConversion["TCP"](json));
  assert(packet.srcPort == json["src_port"].to!ushort);
  assert(packet.destPort == json["dest_port"].to!ushort);
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

  JSONValue json = [
    "ver": JSONValue(1),
    "community_string": JSONValue("public"),
    "pdu": pdu.toJSONValue
  ];

  auto snmp = cast(SNMPv1)(protocolConversion["SNMPv1"](json));
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

unittest {
  JSONValue json = [
    "ver": JSONValue(3),
    "identifier": JSONValue(1169574667),
    "max_size": JSONValue(65507),
    "flags": JSONValue(5),
    "security_model": JSONValue(3)
  ];

  ubyte[] rawSecurityParameters = [
    0x30, 0x2e, 0x04, 0x0d, 0x80, 0x00, 0x1f, 0x88,
    0x80, 0x59, 0xdc, 0x48, 0x61, 0x45, 0xa2, 0x63,
    0x22, 0x02, 0x01, 0x08, 0x02, 0x02, 0x0a, 0xba,
    0x04, 0x06, 0x70, 0x69, 0x70, 0x70, 0x6f, 0x33,
    0x04, 0x0c, 0xac, 0x46, 0x07, 0x0b, 0x60, 0x74,
    0xb1, 0x6f, 0xcd, 0x6d, 0xba, 0x06, 0x04, 0x00
  ];
  auto securityParameters = rawSecurityParameters.toASN1;
  json["security_parameters"] = securityParameters.toJSONValue;

  ASN1 pdu;
  pdu.type = ASN1.Type.SEQUENCE;
  pdu.data = [
    0x04, 0x0d, 0x80, 0x00, 0x1f, 0x88, 0x80, 0x59,
    0xdc, 0x48, 0x61, 0x45, 0xa2, 0x63, 0x22, 0x04,
    0x00, 0xa1, 0x5e, 0x02, 0x04, 0x6d, 0xb7, 0x20,
    0x58, 0x02, 0x01, 0x00, 0x02, 0x01, 0x00, 0x30,
    0x50, 0x30, 0x0e, 0x06, 0x0a, 0x2b, 0x06, 0x01,
    0x02, 0x01, 0x02, 0x02, 0x01, 0x08, 0x02, 0x05,
    0x00, 0x30, 0x0e, 0x06, 0x0a, 0x2b, 0x06, 0x01,
    0x02, 0x01, 0x02, 0x02, 0x01, 0x0b, 0x02, 0x05,
    0x00, 0x30, 0x0e, 0x06, 0x0a, 0x2b, 0x06, 0x01,
    0x02, 0x01, 0x02, 0x02, 0x01, 0x0c, 0x02, 0x05,
    0x00, 0x30, 0x0e, 0x06, 0x0a, 0x2b, 0x06, 0x01,
    0x02, 0x01, 0x02, 0x02, 0x01, 0x11, 0x02, 0x05,
    0x00, 0x30, 0x0e, 0x06, 0x0a, 0x2b, 0x06, 0x01,
    0x02, 0x01, 0x02, 0x02, 0x01, 0x12, 0x02, 0x05,
    0x00
  ];
  json["pdu"] = pdu.toJSONValue;

  auto snmp = cast(SNMPv3)(protocolConversion["SNMPv3"](json));
  assert(snmp.ver == 3);
  assert(snmp.identifier == 1169574667);
  assert(snmp.maxSize == 65507);
  assert(snmp.flags == 5);
  assert(snmp.securityModel == 3);
  assert(snmp.securityParameters.data.toASN1Seq.length == 6);
  assert(snmp.pdu.type == ASN1.Type.SEQUENCE);
  assert(snmp.pdu.length == 113);
  assert(snmp.pdu.data == [
    0x04, 0x0d, 0x80, 0x00, 0x1f, 0x88, 0x80, 0x59,
    0xdc, 0x48, 0x61, 0x45, 0xa2, 0x63, 0x22, 0x04,
    0x00, 0xa1, 0x5e, 0x02, 0x04, 0x6d, 0xb7, 0x20,
    0x58, 0x02, 0x01, 0x00, 0x02, 0x01, 0x00, 0x30,
    0x50, 0x30, 0x0e, 0x06, 0x0a, 0x2b, 0x06, 0x01,
    0x02, 0x01, 0x02, 0x02, 0x01, 0x08, 0x02, 0x05,
    0x00, 0x30, 0x0e, 0x06, 0x0a, 0x2b, 0x06, 0x01,
    0x02, 0x01, 0x02, 0x02, 0x01, 0x0b, 0x02, 0x05,
    0x00, 0x30, 0x0e, 0x06, 0x0a, 0x2b, 0x06, 0x01,
    0x02, 0x01, 0x02, 0x02, 0x01, 0x0c, 0x02, 0x05,
    0x00, 0x30, 0x0e, 0x06, 0x0a, 0x2b, 0x06, 0x01,
    0x02, 0x01, 0x02, 0x02, 0x01, 0x11, 0x02, 0x05,
    0x00, 0x30, 0x0e, 0x06, 0x0a, 0x2b, 0x06, 0x01,
    0x02, 0x01, 0x02, 0x02, 0x01, 0x12, 0x02, 0x05,
    0x00
  ]);
}

unittest {
  JSONValue json = [
    "body_": JSONValue("test")
  ];
  SMTP packet = cast(SMTP)(protocolConversion["SMTP"](json));
  assert(packet.str == "test");
}

unittest {
  JSONValue json = [
    "bytes": [0, 1, 2].toJsonArray
  ];
  Raw packet = cast(Raw)(protocolConversion["Raw"](json));
  assert(packet.bytes == [0, 1, 2]);
}

unittest {
  JSONValue json = [
    "body_": JSONValue("test")
  ];
  POP3 packet = cast(POP3)(protocolConversion["POP3"](json));
  assert(packet.str == "test");
}

unittest {
  JSONValue json = [
    "leap_indicator": JSONValue(2u),
    "status": JSONValue(4u),
    "type_": JSONValue(50u),
    "precision": JSONValue(100u),
    "estimated_error": JSONValue(150u),
    "estimated_drift_rate": JSONValue(200u),
    "reference_clock_identifier": JSONValue(250u),
    "reference_timestamp": JSONValue(300u),
    "originate_timestamp": JSONValue(350u),
    "receive_timestamp": JSONValue(400u),
    "transmit_timestamp": JSONValue(450u)
  ];

  auto packet = cast(NTPv0)(protocolConversion["NTPv0"](json));

  assert(packet.leapIndicator == 2u);
  assert(packet.status == 4u);
  assert(packet.type == 50u);
  assert(packet.precision == 100u);
  assert(packet.estimatedError == 150u);
  assert(packet.estimatedDriftRate == 200u);
  assert(packet.referenceClockIdentifier == 250u);
  assert(packet.referenceTimestamp == 300u);
  assert(packet.originateTimestamp == 350u);
  assert(packet.receiveTimestamp == 400u);
  assert(packet.transmitTimestamp == 450u);
}

unittest {
  JSONValue json = [
    "leap_indicator": JSONValue(0x00),
    "version_number": JSONValue(0x03),
    "mode": JSONValue(0x03),
    "stratum": JSONValue(0x03),
    "poll": JSONValue(0x06),
    "precision": JSONValue(0xec),
    "root_delay": JSONValue(0x03_53),
    "root_dispersion": JSONValue(0x03_6c),
    "reference_clock_identifier": JSONValue(0x5f_51_ad_08),
    "reference_timestamp": JSONValue(0xd9_39_0d_b2_a4_63_7a_91),
    "originate_timestamp": JSONValue(0xd9_39_0d_73_37_64_28_6d),
    "receive_timestamp": JSONValue(0xd9_39_0d_73_39_4d_93_98),
    "transmit_timestamp": JSONValue(0xd9_39_0d_b3_58_3e_91_e8)
  ];
  auto packet = cast(NTPv4)(protocolConversion["NTPv4"](json));
}

unittest {
  JSONValue json = [
    "leap_indicator": JSONValue(0x00),
    "version_number": JSONValue(0x03),
    "mode": JSONValue(0x03),
    "stratum": JSONValue(0x03),
    "poll": JSONValue(0x06),
    "precision": JSONValue(0xec),
    "root_delay": JSONValue(0x03_53),
    "root_dispersion": JSONValue(0x03_6c),
    "reference_clock_identifier": JSONValue(0x5f_51_ad_08),
    "reference_timestamp": JSONValue(0xd9_39_0d_b2_a4_63_7a_91),
    "originate_timestamp": JSONValue(0xd9_39_0d_73_37_64_28_6d),
    "receive_timestamp": JSONValue(0xd9_39_0d_73_39_4d_93_98),
    "transmit_timestamp": JSONValue(0xd9_39_0d_b3_58_3e_91_e8)
  ];
  JSONValue[] fields = [];
  json["extension_fields"] = fields;
  json["key_identifier"] = 0x00;
  JSONValue[] digest = [];
  for (int i = 0 ; i < 16 ; ++i) {
    digest ~= JSONValue(0x00);
  }
  json["digest"] = JSONValue(digest);

  auto packet = cast(NTPv4)(protocolConversion["NTPv4"](json));
  assert(packet.leapIndicator == 0x00);
  assert(packet.versionNumber == 0x03);
  assert(packet.mode == 0x03);
  assert(packet.stratum == 0x03);
  assert(packet.poll == 0x06);
  assert(packet.precision == 0xec);
  assert(packet.rootDelay == 0x03_53);
  assert(packet.rootDispersion == 0x03_6c);
  assert(packet.referenceClockIdentifier == 0x5f_51_ad_08);
  assert(packet.referenceTimestamp == 0xd9_39_0d_b2_a4_63_7a_91);
  assert(packet.originateTimestamp == 0xd9_39_0d_73_37_64_28_6d);
  assert(packet.receiveTimestamp == 0xd9_39_0d_73_39_4d_93_98);
  assert(packet.transmitTimestamp == 0xd9_39_0d_b3_58_3e_91_e8);
}

unittest {
  JSONValue json = [
    "ip_version": JSONValue(0),
    "ihl": JSONValue(0),
    "tos": JSONValue(0),
    "header_length": JSONValue(0),
    "id": JSONValue(0),
    "offset": JSONValue(0),
    "reserved": JSONValue(false),
    "df": JSONValue(false),
    "mf": JSONValue(false),
    "ttl": JSONValue(0),
    "protocol": JSONValue(0),
    "checksum": JSONValue(0),
    "src_ip_address": JSONValue(ipToString([127, 0, 0, 1])),
    "dest_ip_address": JSONValue(ipToString([0, 0, 0, 0]))
  ];
  IP packet = cast(IP)(protocolConversion["IP"](json));
  assert(packet.srcIpAddress == [127, 0, 0, 1]);
}

unittest {
  JSONValue json = [
    "body_": JSONValue("test")
  ];
  IMAP packet = cast(IMAP)(protocolConversion["IMAP"](json));
  assert(packet.str == "test");
}

unittest {
  JSONValue json = [
    "packetType": JSONValue(3),
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];
  ICMP packet = cast(ICMP)(protocolConversion["ICMP"](json));
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest {
  JSONValue json = [
    "packetType": JSONValue(8),
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];
  ICMPv4Communication packet = cast(ICMPv4Communication)(protocolConversion["ICMPv4Communication"](json));
  assert(packet.type == 8);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

unittest {
  JSONValue json = [
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];
  ICMPv4EchoRequest packet = cast(ICMPv4EchoRequest)(protocolConversion["ICMPv4EchoRequest"](json));
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

unittest {
  JSONValue json = [
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];
  ICMPv4EchoReply packet = cast(ICMPv4EchoReply)(protocolConversion["ICMPv4EchoReply"](json));
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

unittest {
  JSONValue json = [
    "packetType": JSONValue(14),
    "id": JSONValue(1),
    "seq": JSONValue(2),
    "originTime": JSONValue(21),
    "receiveTime": JSONValue(42),
    "transmitTime": JSONValue(84)
  ];
  ICMPv4Timestamp packet = cast(ICMPv4Timestamp)(protocolConversion["ICMPv4Timestamp"](json));
  assert(packet.type == 14);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
}

unittest {
  JSONValue json = [
    "packetType": JSONValue(14),
    "id": JSONValue(1),
    "seq": JSONValue(2),
    "originTime": JSONValue(21),
    "receiveTime": JSONValue(42),
    "transmitTime": JSONValue(84)
  ];
  ICMPv4TimestampRequest packet = cast(ICMPv4TimestampRequest)(protocolConversion["ICMPv4TimestampRequest"](json));
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
}

unittest {
  JSONValue json = [
    "packetType": JSONValue(14),
    "id": JSONValue(1),
    "seq": JSONValue(2),
    "originTime": JSONValue(21),
    "receiveTime": JSONValue(42),
    "transmitTime": JSONValue(84)
  ];
  ICMPv4TimestampReply packet = cast(ICMPv4TimestampReply)(protocolConversion["ICMPv4TimestampReply"](json));
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
}

unittest {
  JSONValue json = [
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];
  ICMPv4InformationRequest packet = cast(ICMPv4InformationRequest)(protocolConversion["ICMPv4InformationRequest"](json));
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

unittest {
  JSONValue json = [
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];
  ICMPv4InformationReply packet = cast(ICMPv4InformationReply)(protocolConversion["ICMPv4InformationReply"](json));
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

unittest {
  JSONValue json = [
    "packetType": JSONValue(3),
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];
  ICMPv4Error packet = cast(ICMPv4Error)(protocolConversion["ICMPv4Error"](json));
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest {
  JSONValue json = [
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];
  ICMPv4DestUnreach packet = cast(ICMPv4DestUnreach)(protocolConversion["ICMPv4DestUnreach"](json));
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest {
  JSONValue json = [
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];
  ICMPv4TimeExceed packet = cast(ICMPv4TimeExceed)(protocolConversion["ICMPv4TimeExceed"](json));
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest {
  JSONValue json = [
    "code": JSONValue(2),
    "checksum": JSONValue(0),
    "ptr": JSONValue(1)
  ];
  ICMPv4ParamProblem packet = cast(ICMPv4ParamProblem)(protocolConversion["ICMPv4ParamProblem"](json));
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.ptr == 1);
}

unittest {
  JSONValue json = [
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];
  ICMPv4SourceQuench packet = cast(ICMPv4SourceQuench)(protocolConversion["ICMPv4SourceQuench"](json));
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest {
  JSONValue json = [
    "code": JSONValue(2),
    "checksum": JSONValue(0),
    "gateway": JSONValue(42)
  ];
  ICMPv4Redirect packet = cast(ICMPv4Redirect)(protocolConversion["ICMPv4Redirect"](json));
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.gateway == 42);
}

unittest {
  JSONValue json = [
    "checksum": JSONValue(0),
    "numAddr": JSONValue(3),
    "addrEntrySize": JSONValue(2),
    "life": JSONValue(1),
    "routerAddr": ["1.1.1.1", "2.2.2.2", "3.3.3.3"].toJsonArray,
    "prefAddr": ["1.1.1.1", "2.2.2.2", "3.3.3.3"].toJsonArray
  ];
  ICMPv4RouterAdvert packet = cast(ICMPv4RouterAdvert)(protocolConversion["ICMPv4RouterAdvert"](json));
  assert(packet.checksum == 0);
  assert(packet.life == 1);
  assert(packet.numAddr == 3);
  assert(packet.addrEntrySize == 2);
  assert(packet.routerAddr == [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
  assert(packet.prefAddr == [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
}

unittest {
  JSONValue json = [
    "checksum": JSONValue(0)
  ];
  ICMPv4RouterSollicitation packet = cast(ICMPv4RouterSollicitation)(protocolConversion["ICMPv4RouterSollicitation"](json));
  assert(packet.checksum == 0);
}

unittest {
  JSONValue json = [
    "body_": JSONValue("test")
  ];
  HTTP packet = cast(HTTP)(protocolConversion["HTTP"](json));
  assert(packet.str == "test");
}

unittest {
  JSONValue json = [
    "prelude": (([1, 0, 1, 0, 1, 0, 1]).toJsonArray),
    "src_mac_address": JSONValue(macToString([255, 255, 255, 255, 255, 255])),
    "dest_mac_address": JSONValue(macToString([0, 0, 0, 0, 0, 0])),
    "protocol_type": JSONValue(0x0800),
    "fcs": JSONValue(0)
  ];
  Ethernet packet = cast(Ethernet)(protocolConversion["Ethernet"](json));
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.protocolType == 0x0800);
}

unittest {
  JSONValue json = [
    "subtype": JSONValue(8),
    "packet_type": JSONValue(0),
    "vers": JSONValue(0),
    "rsvd": JSONValue(0),
    "wep": JSONValue(0),
    "more_data": JSONValue(0),
    "power": JSONValue(0),
    "retry": JSONValue(0),
    "more_frag": JSONValue(0),
    "from_DS": JSONValue(0),
    "to_DS": JSONValue(0),
    "duration": JSONValue(0),
    "addr1": JSONValue(macToString([255, 255, 255, 255, 255, 255])),
    "addr2": JSONValue(macToString([0, 0, 0, 0, 0, 0])),
    "addr3": JSONValue(macToString([1, 2, 3, 4, 5, 6])),
    "addr4": JSONValue(macToString([0, 0, 0, 0, 0, 0])),
    "seq": JSONValue(0),
    "fcs": JSONValue(0)
  ];
  Dot11 packet = cast(Dot11)(protocolConversion["Dot11"](json));
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
    "chaddr": ((new ubyte[16]).toJsonArray),
    "sname": ((new ubyte[64]).toJsonArray),
    "file": ((new ubyte[128]).toJsonArray),
    "options": ((options).toJsonArray)
  ];
  DHCP packet = cast(DHCP)(protocolConversion["DHCP"](json));
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
}

unittest {
  JSONValue json = [
    "qdcount": JSONValue(0),
    "ancount": JSONValue(0),
    "nscount": JSONValue(0),
    "arcount": JSONValue(0),
    "qr": JSONValue(false),
    "opcode": JSONValue(0),
    "auth_answer": JSONValue(false),
    "truncation": JSONValue(false),
    "record_desired": JSONValue(true),
    "record_available": JSONValue(false),
    "zero": JSONValue(0),
    "rcode": JSONValue(0),
    "id": JSONValue(0)
  ];
  DNS packet = cast(DNS)(protocolConversion["DNS"](json));
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

unittest {
  JSONValue json = [
    "qdcount": JSONValue(0),
    "ancount": JSONValue(0),
    "nscount": JSONValue(0),
    "arcount": JSONValue(0),
    "qr": JSONValue(false),
    "opcode": JSONValue(1),
    "auth_answer": JSONValue(false),
    "truncation": JSONValue(false),
    "record_desired": JSONValue(true),
    "record_available": JSONValue(true),
    "zero": JSONValue(0),
    "rcode": JSONValue(0),
    "id": JSONValue(0)
  ];
  DNSQuery packet = cast(DNSQuery)(protocolConversion["DNSQuery"](json));
  assert(packet.id == 0);
  assert(packet.qdcount == 0);
  assert(packet.ancount == 0);
  assert(packet.nscount == 0);
  assert(packet.arcount == 0);
  assert(packet.opcode == 1);
  assert(packet.rd == true);
  assert(packet.tc == false);
}

unittest {
  JSONValue json = [
    "qdcount": JSONValue(0),
    "ancount": JSONValue(0),
    "nscount": JSONValue(0),
    "arcount": JSONValue(0),
    "qr": JSONValue(false),
    "opcode": JSONValue(0),
    "auth_answer": JSONValue(false),
    "truncation": JSONValue(false),
    "record_desired": JSONValue(true),
    "record_available": JSONValue(false),
    "zero": JSONValue(0),
    "rcode": JSONValue(0),
    "id": JSONValue(0)
  ];
  DNSResource packet = cast(DNSResource)(protocolConversion["DNSResource"](json));
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

unittest {
  JSONValue json = [
    "qname": JSONValue("google.fr"),
    "qtype": JSONValue(QType.A),
    "qclass": JSONValue(QClass.IN)
  ];
  DNSQR packet = cast(DNSQR)(protocolConversion["DNSQR"](json));
  assert(packet.qname == "google.fr");
  assert(packet.qtype == 1);
  assert(packet.qclass == 1);
}

unittest {
  JSONValue json = [
    "rname": JSONValue("google.fr"),
    "rtype": JSONValue(QType.A),
    "rclass": JSONValue(QClass.IN),
    "ttl": JSONValue(600),
    "rdlength": JSONValue(10)
  ];
  DNSRR packet = cast(DNSRR)(protocolConversion["DNSRR"](json));
  assert(packet.rname == "google.fr");
  assert(packet.rtype == 1);
  assert(packet.rclass == 1);
  assert(packet.ttl == 600);
  assert(packet.rdlength == 10);
}

unittest {
  JSONValue json = [
    "primary": JSONValue("google.fr"),
    "admin": JSONValue("admin.google.fr"),
    "serial": JSONValue(8000),
    "refresh": JSONValue(2500),
    "retry": JSONValue(2500),
    "expirationLimit": JSONValue(400),
    "minTtl": JSONValue(10)
  ];
  DNSSOAResource packet = cast(DNSSOAResource)(protocolConversion["DNSSOAResource"](json));
  assert(packet.primary == "google.fr");
  assert(packet.admin == "admin.google.fr");
  assert(packet.serial == 8000);
  assert(packet.refresh == 2500);
  assert(packet.retry == 2500);
  assert(packet.expirationLimit == 400);
  assert(packet.minTtl == 10);
}

unittest {
  JSONValue json = [
    "pref": JSONValue(1),
    "mxname": JSONValue("google.fr")
  ];
  DNSMXResource packet = cast(DNSMXResource)(protocolConversion["DNSMXResource"](json));
  assert(packet.pref == 1);
  assert(packet.mxname == "google.fr");
}

unittest {
  JSONValue json = [
    "ip": JSONValue(ipToString([127, 0, 0, 1]))
  ];
  DNSAResource packet = cast(DNSAResource)(protocolConversion["DNSAResource"](json));
  assert(packet.ip == [127, 0, 0, 1]);
}

unittest {
  JSONValue json = [
    "ptrname": JSONValue("google.fr")
  ];
  DNSPTRResource packet = cast(DNSPTRResource)(protocolConversion["DNSPTRResource"](json));
  assert(packet.ptrname == "google.fr");
}
