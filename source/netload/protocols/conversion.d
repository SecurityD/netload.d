module netload.protocols.conversion;

import vibe.data.json;
import netload.core.protocol;

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

Protocol toProtocol(Json json) {
  if (json.name.type != Json.Type.Null && json.name != null)
    return protocolConversion[json.name.to!string](json);
  throw new Exception("Invalid Json.");
}

Protocol function(Json)[string] protocolConversion;

shared static this() {
  protocolConversion["ARP"] = delegate(Json json){ return (cast(Protocol)to!ARP(json)); };
  protocolConversion["UDP"] = delegate(Json json){ return (cast(Protocol)to!UDP(json)); };
  protocolConversion["TCP"] = delegate(Json json){ return (cast(Protocol)to!TCP(json)); };
  protocolConversion["SNMPv1"] = delegate(Json json){ return (cast(Protocol)to!SNMPv1(json)); };
  protocolConversion["SNMPv3"] = delegate(Json json){ return (cast(Protocol)to!SNMPv3(json)); };
  protocolConversion["SMTP"] = delegate(Json json){ return (cast(Protocol)to!SMTP(json)); };
  protocolConversion["Raw"] = delegate(Json json){ return (cast(Protocol)to!Raw(json)); };
  protocolConversion["POP3"] = delegate(Json json){ return (cast(Protocol)to!POP3(json)); };
  protocolConversion["NTPv0"] = delegate(Json json){ return (cast(Protocol)to!NTPv0(json)); };
  protocolConversion["NTPv4"] = delegate(Json json){ return (cast(Protocol)to!NTPv4(json)); };
  protocolConversion["IP"] = delegate(Json json){ return (cast(Protocol)to!IP(json)); };
  protocolConversion["IMAP"] = delegate(Json json){ return (cast(Protocol)to!IMAP(json)); };
  // protocolConversion["ICMP"] = delegate(Json json){ return (cast(Protocol)to!ICMP(json)); };
  // protocolConversion["ICMPv4Communication"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4Communication(json)); };
  // protocolConversion["ICMPv4EchoRequest"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4EchoRequest(json)); };
  // protocolConversion["ICMPv4EchoReply"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4EchoReply(json)); };
  // protocolConversion["ICMPv4Timestamp"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4Timestamp(json)); };
  // protocolConversion["ICMPv4TimestampRequest"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4TimestampRequest(json)); };
  // protocolConversion["ICMPv4TimestampReply"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4TimestampReply(json)); };
  // protocolConversion["ICMPv4InformationRequest"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4InformationRequest(json)); };
  // protocolConversion["ICMPv4InformationReply"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4InformationReply(json)); };
  // protocolConversion["ICMPv4Error"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4Error(json)); };
  // protocolConversion["ICMPv4DestUnreach"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4DestUnreach(json)); };
  // protocolConversion["ICMPv4TimeExceed"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4TimeExceed(json)); };
  // protocolConversion["ICMPv4ParamProblem"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4ParamProblem(json)); };
  // protocolConversion["ICMPv4SourceQuench"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4SourceQuench(json)); };
  // protocolConversion["ICMPv4Redirect"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4Redirect(json)); };
  // protocolConversion["ICMPv4RouterAdvert"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4RouterAdvert(json)); };
  // protocolConversion["ICMPv4RouterSollicitation"] = delegate(Json json){ return (cast(Protocol)to!ICMPv4RouterSollicitation(json)); };
  protocolConversion["HTTP"] = delegate(Json json){ return (cast(Protocol)to!HTTP(json)); };
  protocolConversion["Ethernet"] = delegate(Json json){ return (cast(Protocol)to!Ethernet(json)); };
  protocolConversion["Dot11"] = delegate(Json json){ return (cast(Protocol)to!Dot11(json)); };
  protocolConversion["DHCP"] = delegate(Json json){ return (cast(Protocol)to!DHCP(json)); };
  // protocolConversion["DNS"] = delegate(Json json){ return (cast(Protocol)to!DNS(json)); };
  // protocolConversion["DNSQuery"] = delegate(Json json){ return (cast(Protocol)to!DNSQuery(json)); };
  // protocolConversion["DNSResource"] = delegate(Json json){ return (cast(Protocol)to!DNSResource(json)); };
  // protocolConversion["DNSQR"] = delegate(Json json){ return (cast(Protocol)to!DNSQR(json)); };
  // protocolConversion["DNSRR"] = delegate(Json json){ return (cast(Protocol)to!DNSRR(json)); };
  // protocolConversion["DNSSOAResource"] = delegate(Json json){ return (cast(Protocol)to!DNSSOAResource(json)); };
  // protocolConversion["DNSMXResource"] = delegate(Json json){ return (cast(Protocol)to!DNSMXResource(json)); };
  // protocolConversion["DNSAResource"] = delegate(Json json){ return (cast(Protocol)to!DNSAResource(json)); };
  // protocolConversion["DNSPTRResource"] = delegate(Json json){ return (cast(Protocol)to!DNSPTRResource(json)); };
}

// unittest {
//   Json json = Json.emptyObject;
//   json.hwType = 1;
//   json.protocolType = 1;
//   json.hwAddrLen = 6;
//   json.protocolAddrLen = 4;
//   json.opcode = 0;
//   json.senderHwAddr = serializeToJson([128, 128, 128, 128, 128, 128]);
//   json.targetHwAddr = serializeToJson([0, 0, 0, 0, 0, 0]);
//   json.senderProtocolAddr = serializeToJson([127, 0, 0, 1]);
//   json.targetProtocolAddr = serializeToJson([10, 14, 255, 255]);
//   ARP packet = cast(ARP)(protocolConversion["ARP"](json));
//   assert(packet.hwType == 1);
//   assert(packet.protocolType == 1);
//   assert(packet.hwAddrLen == 6);
//   assert(packet.protocolAddrLen == 4);
//   assert(packet.opcode == 0);
//   assert(packet.senderHwAddr == [128, 128, 128, 128, 128, 128]);
//   assert(packet.targetHwAddr == [0, 0, 0, 0, 0, 0]);
//   assert(packet.senderProtocolAddr == [127, 0, 0, 1]);
//   assert(packet.targetProtocolAddr == [10, 14, 255, 255]);
// }

unittest {
  Json json = Json.emptyObject;
  json.src_port = 8000;
  json.dest_port = 7000;
  json.len = 0;
  json.checksum = 0;
  UDP packet = cast(UDP)(protocolConversion["UDP"](json));
  assert(packet.srcPort == 8000);
  assert(packet.destPort == 7000);
  assert(packet.length == 0);
  assert(packet.checksum == 0);
}

unittest {
  Json json = Json.emptyObject;
  json.src_port = 8000;
  json.dest_port = 7000;
  json.sequence_number = 0;
  json.ack_number = 0;
  json.fin = false;
  json.syn = true;
  json.rst = false;
  json.psh = false;
  json.ack = true;
  json.urg = false;
  json.reserved = 0;
  json.offset = 0;
  json.window = 0;
  json.checksum = 0;
  json.urgent_ptr = 0;
  TCP packet = cast(TCP)(protocolConversion["TCP"](json));
  assert(packet.srcPort == json.src_port.get!ushort);
  assert(packet.destPort == json.dest_port.get!ushort);
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
  Json json = Json.emptyObject;
  json.ver = 3;
  json.identifier = 1169574667;
  json.max_size = 65507;
  json.flags = 5;
  json.security_model = 3;

  ubyte[] rawSecurityParameters = [
    0x30, 0x2e, 0x04, 0x0d, 0x80, 0x00, 0x1f, 0x88,
    0x80, 0x59, 0xdc, 0x48, 0x61, 0x45, 0xa2, 0x63,
    0x22, 0x02, 0x01, 0x08, 0x02, 0x02, 0x0a, 0xba,
    0x04, 0x06, 0x70, 0x69, 0x70, 0x70, 0x6f, 0x33,
    0x04, 0x0c, 0xac, 0x46, 0x07, 0x0b, 0x60, 0x74,
    0xb1, 0x6f, 0xcd, 0x6d, 0xba, 0x06, 0x04, 0x00
  ];
  auto securityParameters = rawSecurityParameters.toASN1;
  json.security_parameters = serializeToJson(securityParameters);

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
  json.pdu = serializeToJson(pdu);

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
  Json json = Json.emptyObject;
  json.body_ = "test";
  SMTP packet = cast(SMTP)(protocolConversion["SMTP"](json));
  assert(packet.str == "test");
}

unittest {
  Json json = Json.emptyObject;
  json.bytes = serializeToJson([0, 1, 2]);
  Raw packet = cast(Raw)(protocolConversion["Raw"](json));
  assert(packet.bytes == [0, 1, 2]);
}

unittest {
  Json json = Json.emptyObject;
  json.body_ = "test";
  POP3 packet = cast(POP3)(protocolConversion["POP3"](json));
  assert(packet.str == "test");
}

unittest {
  auto json = Json.emptyObject;
  json.leap_indicator = 2u;
  json.status = 4u;
  json.type_ = 50u;
  json.precision = 100u;
  json.estimated_error = 150u;
  json.estimated_drift_rate = 200u;
  json.reference_clock_identifier = 250u;
  json.reference_timestamp = 300u;
  json.originate_timestamp = 350u;
  json.receive_timestamp = 400u;
  json.transmit_timestamp = 450u;

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
  auto json = Json.emptyObject;
  json.leap_indicator = 0x00;
  json.version_number = 0x03;
  json.mode = 0x03;
  json.stratum = 0x03;
  json.poll = 0x06;
  json.precision = 0xec;
  json.root_delay = 0x03_53;
  json.root_dispersion = 0x03_6c;
  json.reference_clock_identifier = 0x5f_51_ad_08;
  json.reference_timestamp = 0xd9_39_0d_b2_a4_63_7a_91;
  json.originate_timestamp = 0xd9_39_0d_73_37_64_28_6d;
  json.receive_timestamp = 0xd9_39_0d_73_39_4d_93_98;
  json.transmit_timestamp = 0xd9_39_0d_b3_58_3e_91_e8;
  auto packet = cast(NTPv4)(protocolConversion["NTPv4"](json));
}

unittest {
  auto json = Json.emptyObject;
  json.leap_indicator = 0x00;
  json.version_number = 0x03;
  json.mode = 0x03;
  json.stratum = 0x03;
  json.poll = 0x06;
  json.precision = 0xec;
  json.root_delay = 0x03_53;
  json.root_dispersion = 0x03_6c;
  json.reference_clock_identifier = 0x5f_51_ad_08;
  json.reference_timestamp = 0xd9_39_0d_b2_a4_63_7a_91;
  json.originate_timestamp = 0xd9_39_0d_73_37_64_28_6d;
  json.receive_timestamp = 0xd9_39_0d_73_39_4d_93_98;
  json.transmit_timestamp = 0xd9_39_0d_b3_58_3e_91_e8;
  json.extension_fields = Json.emptyArray;
  json.key_identifier = 0x00;
  json.digest = Json.emptyArray;
  for (int i = 0 ; i < 16 ; ++i) {
    json.digest ~= 0x00;
  }

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
  Json json = Json.emptyObject;
  json.ip_version = 0;
  json.ihl = 0;
  json.tos = 0;
  json.header_length = 0;
  json.id = 0;
  json.offset = 0;
  json.reserved = false;
  json.df = false;
  json.mf = false;
  json.ttl = 0;
  json.protocol = 0;
  json.checksum = 0;
  json.src_ip_address = 20;
  json.dest_ip_address = 0;
  IP packet = cast(IP)(protocolConversion["IP"](json));
  assert(packet.srcIpAddress == 20);
}

unittest {
  Json json = Json.emptyObject;
  json.body_ = "test";
  IMAP packet = cast(IMAP)(protocolConversion["IMAP"](json));
  assert(packet.str == "test");
}

// unittest {
//   Json json = Json.emptyObject;
//   json.packetType = 3;
//   json.code = 2;
//   json.checksum = 0;
//   ICMP packet = cast(ICMP)(protocolConversion["ICMP"](json));
//   assert(packet.type == 3);
//   assert(packet.code == 2);
//   assert(packet.checksum == 0);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.packetType = 8;
//   json.checksum = 0;
//   json.id = 1;
//   json.seq = 2;
//   ICMPv4Communication packet = cast(ICMPv4Communication)(protocolConversion["ICMPv4Communication"](json));
//   assert(packet.type == 8);
//   assert(packet.checksum == 0);
//   assert(packet.id == 1);
//   assert(packet.seq == 2);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.checksum = 0;
//   json.id = 1;
//   json.seq = 2;
//   ICMPv4EchoRequest packet = cast(ICMPv4EchoRequest)(protocolConversion["ICMPv4EchoRequest"](json));
//   assert(packet.checksum == 0);
//   assert(packet.id == 1);
//   assert(packet.seq == 2);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.checksum = 0;
//   json.id = 1;
//   json.seq = 2;
//   ICMPv4EchoReply packet = cast(ICMPv4EchoReply)(protocolConversion["ICMPv4EchoReply"](json));
//   assert(packet.checksum == 0);
//   assert(packet.id == 1);
//   assert(packet.seq == 2);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.packetType = 14;
//   json.id = 1;
//   json.seq = 2;
//   json.originTime = 21;
//   json.receiveTime = 42;
//   json.transmitTime = 84;
//   ICMPv4Timestamp packet = cast(ICMPv4Timestamp)(protocolConversion["ICMPv4Timestamp"](json));
//   assert(packet.type == 14);
//   assert(packet.id == 1);
//   assert(packet.seq == 2);
//   assert(packet.originTime == 21);
//   assert(packet.receiveTime == 42);
//   assert(packet.transmitTime == 84);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.packetType = 14;
//   json.id = 1;
//   json.seq = 2;
//   json.originTime = 21;
//   json.receiveTime = 42;
//   json.transmitTime = 84;
//   ICMPv4TimestampRequest packet = cast(ICMPv4TimestampRequest)(protocolConversion["ICMPv4TimestampRequest"](json));
//   assert(packet.id == 1);
//   assert(packet.seq == 2);
//   assert(packet.originTime == 21);
//   assert(packet.receiveTime == 42);
//   assert(packet.transmitTime == 84);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.packetType = 14;
//   json.id = 1;
//   json.seq = 2;
//   json.originTime = 21;
//   json.receiveTime = 42;
//   json.transmitTime = 84;
//   ICMPv4TimestampReply packet = cast(ICMPv4TimestampReply)(protocolConversion["ICMPv4TimestampReply"](json));
//   assert(packet.id == 1);
//   assert(packet.seq == 2);
//   assert(packet.originTime == 21);
//   assert(packet.receiveTime == 42);
//   assert(packet.transmitTime == 84);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.checksum = 0;
//   json.id = 1;
//   json.seq = 2;
//   ICMPv4InformationRequest packet = cast(ICMPv4InformationRequest)(protocolConversion["ICMPv4InformationRequest"](json));
//   assert(packet.checksum == 0);
//   assert(packet.id == 1);
//   assert(packet.seq == 2);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.checksum = 0;
//   json.id = 1;
//   json.seq = 2;
//   ICMPv4InformationReply packet = cast(ICMPv4InformationReply)(protocolConversion["ICMPv4InformationReply"](json));
//   assert(packet.checksum == 0);
//   assert(packet.id == 1);
//   assert(packet.seq == 2);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.packetType = 3;
//   json.code = 2;
//   json.checksum = 0;
//   ICMPv4Error packet = cast(ICMPv4Error)(protocolConversion["ICMPv4Error"](json));
//   assert(packet.type == 3);
//   assert(packet.code == 2);
//   assert(packet.checksum == 0);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.code = 2;
//   json.checksum = 0;
//   ICMPv4DestUnreach packet = cast(ICMPv4DestUnreach)(protocolConversion["ICMPv4DestUnreach"](json));
//   assert(packet.code == 2);
//   assert(packet.checksum == 0);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.code = 2;
//   json.checksum = 0;
//   ICMPv4TimeExceed packet = cast(ICMPv4TimeExceed)(protocolConversion["ICMPv4TimeExceed"](json));
//   assert(packet.code == 2);
//   assert(packet.checksum == 0);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.code = 2;
//   json.checksum = 0;
//   json.ptr = 1;
//   ICMPv4ParamProblem packet = cast(ICMPv4ParamProblem)(protocolConversion["ICMPv4ParamProblem"](json));
//   assert(packet.code == 2);
//   assert(packet.checksum == 0);
//   assert(packet.ptr == 1);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.code = 2;
//   json.checksum = 0;
//   ICMPv4SourceQuench packet = cast(ICMPv4SourceQuench)(protocolConversion["ICMPv4SourceQuench"](json));
//   assert(packet.code == 2);
//   assert(packet.checksum == 0);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.code = 2;
//   json.checksum = 0;
//   json.gateway = 42;
//   ICMPv4Redirect packet = cast(ICMPv4Redirect)(protocolConversion["ICMPv4Redirect"](json));
//   assert(packet.code == 2);
//   assert(packet.checksum == 0);
//   assert(packet.gateway == 42);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.checksum = 0;
//   json.numAddr = 3;
//   json.addrEntrySize = 2;
//   json.life = 1;
//   json.routerAddr = serializeToJson([[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
//   json.prefAddr = serializeToJson([[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
//   ICMPv4RouterAdvert packet = cast(ICMPv4RouterAdvert)(protocolConversion["ICMPv4RouterAdvert"](json));
//   assert(packet.checksum == 0);
//   assert(packet.life == 1);
//   assert(packet.numAddr == 3);
//   assert(packet.addrEntrySize == 2);
//   assert(packet.routerAddr == [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
//   assert(packet.prefAddr == [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.checksum = 0;
//   ICMPv4RouterSollicitation packet = cast(ICMPv4RouterSollicitation)(protocolConversion["ICMPv4RouterSollicitation"](json));
//   assert(packet.checksum == 0);
// }
//
unittest {
  Json json = Json.emptyObject;
  json.body_ = "test";
  HTTP packet = cast(HTTP)(protocolConversion["HTTP"](json));
  assert(packet.str == "test");
}

unittest {
  Json json = Json.emptyObject;
  json.prelude = serializeToJson([1, 0, 1, 0, 1, 0, 1]);
  json.src_mac_address = serializeToJson([255, 255, 255, 255, 255, 255]);
  json.dest_mac_address = serializeToJson([0, 0, 0, 0, 0, 0]);
  json.protocol_type = 0x0800;
  json.fcs = 0;
  Ethernet packet = cast(Ethernet)(protocolConversion["Ethernet"](json));
  assert(packet.srcMacAddress == [255, 255, 255, 255, 255, 255]);
  assert(packet.protocolType == 0x0800);
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
  DHCP packet = cast(DHCP)(protocolConversion["DHCP"](json));
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

// unittest {
//   Json json = Json.emptyObject;
//   json.qdcount = 0;
//   json.ancount = 0;
//   json.nscount = 0;
//   json.arcount = 0;
//   json.qr = false;
//   json.opcode = 0;
//   json.auth_answer = false;
//   json.truncation = false;
//   json.record_desired = true;
//   json.record_available = false;
//   json.zero = 0;
//   json.rcode = 0;
//   json.id = 0;
//   DNS packet = cast(DNS)(protocolConversion["DNS"](json));
//   assert(packet.id == 0);
//   assert(packet.qdcount == 0);
//   assert(packet.ancount == 0);
//   assert(packet.nscount == 0);
//   assert(packet.arcount == 0);
//   assert(packet.qr == false);
//   assert(packet.opcode == 0);
//   assert(packet.aa == false);
//   assert(packet.rd == true);
//   assert(packet.tc == false);
//   assert(packet.ra == false);
//   assert(packet.z == 0);
//   assert(packet.rcode == 0);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.qdcount = 0;
//   json.ancount = 0;
//   json.nscount = 0;
//   json.arcount = 0;
//   json.qr = false;
//   json.opcode = 1;
//   json.auth_answer = false;
//   json.truncation = false;
//   json.record_desired = true;
//   json.record_available = true;
//   json.zero = 0;
//   json.rcode = 0;
//   json.id = 0;
//   DNSQuery packet = cast(DNSQuery)(protocolConversion["DNSQuery"](json));
//   assert(packet.id == 0);
//   assert(packet.qdcount == 0);
//   assert(packet.ancount == 0);
//   assert(packet.nscount == 0);
//   assert(packet.arcount == 0);
//   assert(packet.opcode == 1);
//   assert(packet.rd == true);
//   assert(packet.tc == false);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.qdcount = 0;
//   json.ancount = 0;
//   json.nscount = 0;
//   json.arcount = 0;
//   json.qr = false;
//   json.opcode = 0;
//   json.auth_answer = false;
//   json.truncation = false;
//   json.record_desired = true;
//   json.record_available = false;
//   json.zero = 0;
//   json.rcode = 0;
//   json.id = 0;
//   DNSResource packet = cast(DNSResource)(protocolConversion["DNSResource"](json));
//   assert(packet.id == 0);
//   assert(packet.qdcount == 0);
//   assert(packet.ancount == 0);
//   assert(packet.nscount == 0);
//   assert(packet.arcount == 0);
//   assert(packet.aa == false);
//   assert(packet.tc == false);
//   assert(packet.ra == false);
//   assert(packet.rcode == 0);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.qname = "google.fr";
//   json.qtype = QType.A;
//   json.qclass = QClass.IN;
//   DNSQR packet = cast(DNSQR)(protocolConversion["DNSQR"](json));
//   assert(packet.qname == "google.fr");
//   assert(packet.qtype == 1);
//   assert(packet.qclass == 1);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.rname = "google.fr";
//   json.rtype = QType.A;
//   json.rclass = QClass.IN;
//   json.ttl = 600;
//   json.rdlength = 10;
//   DNSRR packet = cast(DNSRR)(protocolConversion["DNSRR"](json));
//   assert(packet.rname == "google.fr");
//   assert(packet.rtype == 1);
//   assert(packet.rclass == 1);
//   assert(packet.ttl == 600);
//   assert(packet.rdlength == 10);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.primary = "google.fr";
//   json.admin = "admin.google.fr";
//   json.serial = 8000;
//   json.refresh = 2500;
//   json.retry = 2500;
//   json.expirationLimit = 400;
//   json.minTtl = 10;
//   DNSSOAResource packet = cast(DNSSOAResource)(protocolConversion["DNSSOAResource"](json));
//   assert(packet.primary == "google.fr");
//   assert(packet.admin == "admin.google.fr");
//   assert(packet.serial == 8000);
//   assert(packet.refresh == 2500);
//   assert(packet.retry == 2500);
//   assert(packet.expirationLimit == 400);
//   assert(packet.minTtl == 10);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.pref = 1;
//   json.mxname = "google.fr";
//   DNSMXResource packet = cast(DNSMXResource)(protocolConversion["DNSMXResource"](json));
//   assert(packet.pref == 1);
//   assert(packet.mxname == "google.fr");
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.ip = serializeToJson([127, 0, 0, 1]);
//   DNSAResource packet = cast(DNSAResource)(protocolConversion["DNSAResource"](json));
//   assert(packet.ip == [127, 0, 0, 1]);
// }
//
// unittest {
//   Json json = Json.emptyObject;
//   json.ptrname = "google.fr";
//   DNSPTRResource packet = cast(DNSPTRResource)(protocolConversion["DNSPTRResource"](json));
//   assert(packet.ptrname == "google.fr");
// }
