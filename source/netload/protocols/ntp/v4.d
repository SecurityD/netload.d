module netload.protocols.ntp.v4;

import std.bitmanip;
import std.bigint;
import std.array;

import vibe.data.json;

import netload.core.protocol;
import netload.protocols.ntp.common;

class NTPv4 : NTPCommon, Protocol {
  public:
    this() {

    }

    override Json toJson() const {
      auto json = Json.emptyObject;
      json.leap_indicator = leapIndicator;
      json.version_number = versionNumber;
      json.mode = mode;
      json.stratum = stratum;
      json.poll = poll;
      json.precision = precision;
      json.root_delay = rootDelay;
      json.root_dispersion = rootDispersion;
      json.reference_clock_identifier = referenceClockIdentifier;
      json.reference_timestamp = referenceTimestamp;
      json.originate_timestamp = originateTimestamp;
      json.receive_timestamp = receiveTimestamp;
      json.transmit_timestamp = transmitTimestamp;
      if (_extensionFields.length > 0)
        json.extension_fields = serializeToJson(_extensionFields);
      if (keyIdentifier != 0)
        json.key_identifier = keyIdentifier;
      foreach (byte b ; _digest) {
        if (b)
          json.digest = serializeToJson(_digest);
      }
      json.name = name;
      if (_data is null)
        json.data = null;
      else
        json.data = _data.toJson;
      return json;
    }

    unittest {
      auto packet = new NTPv4;
      packet.leapIndicator = 0x00;
      packet.versionNumber = 0x03;
      packet.mode = 0x03;
      packet.stratum = 0x03;
      packet.poll = 0x06;
      packet.precision = 0xec;
      packet.rootDelay = 0x03_53;
      packet.rootDispersion = 0x03_6c;
      packet.referenceClockIdentifier = 0x5f_51_ad_08;
      packet.referenceTimestamp = 0xd9_39_0d_b2_a4_63_7a_91;
      packet.originateTimestamp = 0xd9_39_0d_73_37_64_28_6d;
      packet.receiveTimestamp = 0xd9_39_0d_73_39_4d_93_98;
      packet.transmitTimestamp = 0xd9_39_0d_b3_58_3e_91_e8;

      auto json = packet.toJson;
      assert(json.leap_indicator == 0x00);
      assert(json.version_number == 0x03);
      assert(json.mode == 0x03);
      assert(json.stratum == 0x03);
      assert(json.poll == 0x06);
      assert(json.precision == 0xec);
      assert(json.root_delay == 0x03_53);
      assert(json.root_dispersion == 0x03_6c);
      assert(json.reference_clock_identifier == 0x5f_51_ad_08);
      assert(json.reference_timestamp == 0xd9_39_0d_b2_a4_63_7a_91);
      assert(json.originate_timestamp == 0xd9_39_0d_73_37_64_28_6d);
      assert(json.receive_timestamp == 0xd9_39_0d_73_39_4d_93_98);
      assert(json.transmit_timestamp == 0xd9_39_0d_b3_58_3e_91_e8);
    }

    unittest {
      import netload.protocols.ethernet;
      import netload.protocols.raw;
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);

      auto ntp = new NTPv4;
      ntp.leapIndicator = 0x00;
      ntp.versionNumber = 0x03;
      ntp.mode = 0x03;
      ntp.stratum = 0x03;
      ntp.poll = 0x06;
      ntp.precision = 0xec;
      ntp.rootDelay = 0x03_53;
      ntp.rootDispersion = 0x03_6c;
      ntp.referenceClockIdentifier = 0x5f_51_ad_08;
      ntp.referenceTimestamp = 0xd9_39_0d_b2_a4_63_7a_91;
      ntp.originateTimestamp = 0xd9_39_0d_73_37_64_28_6d;
      ntp.receiveTimestamp = 0xd9_39_0d_73_39_4d_93_98;
      ntp.transmitTimestamp = 0xd9_39_0d_b3_58_3e_91_e8;
      packet.data = ntp;

      packet.data.data = new Raw([42, 21, 84]);

      Json json = packet.toJson;
      assert(json.name == "Ethernet");
      assert(deserializeJson!(ubyte[6])(json.dest_mac_address) == [0, 0, 0, 0, 0, 0]);
      assert(deserializeJson!(ubyte[6])(json.src_mac_address) == [255, 255, 255, 255, 255, 255]);

      json = json.data;
      assert(json.name == "NTPv4");
      assert(json.leap_indicator == 0x00);
      assert(json.version_number == 0x03);
      assert(json.mode == 0x03);
      assert(json.stratum == 0x03);
      assert(json.poll == 0x06);
      assert(json.precision == 0xec);
      assert(json.root_delay == 0x03_53);
      assert(json.root_dispersion == 0x03_6c);
      assert(json.reference_clock_identifier == 0x5f_51_ad_08);
      assert(json.reference_timestamp == 0xd9_39_0d_b2_a4_63_7a_91);
      assert(json.originate_timestamp == 0xd9_39_0d_73_37_64_28_6d);
      assert(json.receive_timestamp == 0xd9_39_0d_73_39_4d_93_98);
      assert(json.transmit_timestamp == 0xd9_39_0d_b3_58_3e_91_e8);

      json = json.data;
      assert(json.toString == `{"name":"Raw","bytes":[42,21,84]}`);
    }

    override ubyte[] toBytes() const {
      auto packet = appender!(ubyte[])();
      packet.append!ubyte(cast(ubyte)((leapIndicator << 6) + (versionNumber << 3) + mode));
      packet.append!ubyte(stratum);
      packet.append!ubyte(poll);
      packet.append!ubyte(precision);
      packet.append!uint(rootDelay);
      packet.append!uint(rootDispersion);
      packet.append!uint(referenceClockIdentifier);
      packet.append!ulong(referenceTimestamp);
      packet.append!ulong(originateTimestamp);
      packet.append!ulong(receiveTimestamp);
      packet.append!ulong(transmitTimestamp);
      foreach (const(NTPv4ExtensionField) extensionField ; _extensionFields) {
        packet.append!ushort(extensionField.fieldType);
        packet.append!ushort(extensionField.length);
        foreach (ubyte b ; extensionField.value)
          packet.append!ubyte(b);
      }
      if (keyIdentifier != 0)
        packet.append!uint(keyIdentifier);
      foreach (byte b ; _digest) {
        if (b)
          return packet.data ~ _digest;
      }
      if (_data !is null)
        return packet.data ~ _data.toBytes;
      return packet.data;
    }

    unittest {
      auto packet = new NTPv4;
      packet.leapIndicator = 0x00;
      packet.versionNumber = 0x03;
      packet.mode = 0x03;
      packet.stratum = 0x03;
      packet.poll = 0x06;
      packet.precision = 0xec;
      packet.rootDelay = 0x03_53;
      packet.rootDispersion = 0x03_6c;
      packet.referenceClockIdentifier = 0x5f_51_ad_08;
      packet.referenceTimestamp = 0xd9_39_0d_b2_a4_63_7a_91;
      packet.originateTimestamp = 0xd9_39_0d_73_37_64_28_6d;
      packet.receiveTimestamp = 0xd9_39_0d_73_39_4d_93_98;
      packet.transmitTimestamp = 0xd9_39_0d_b3_58_3e_91_e8;

      assert(packet.toBytes == [
        0x1b, 0x03, 0x06, 0xec,
        0x00, 0x00, 0x03, 0x53,
        0x00, 0x00, 0x03, 0x6c,
        0x5f, 0x51, 0xad, 0x08,
        0xd9, 0x39, 0x0d, 0xb2,
        0xa4, 0x63, 0x7a, 0x91,
        0xd9, 0x39, 0x0d, 0x73,
        0x37, 0x64, 0x28, 0x6d,
        0xd9, 0x39, 0x0d, 0x73,
        0x39, 0x4d, 0x93, 0x98,
        0xd9, 0x39, 0x0d, 0xb3,
        0x58, 0x3e, 0x91, 0xe8
      ]);
    }

    unittest {
      import netload.protocols.raw;

      auto packet = new NTPv4;
      packet.leapIndicator = 0x00;
      packet.versionNumber = 0x03;
      packet.mode = 0x03;
      packet.stratum = 0x03;
      packet.poll = 0x06;
      packet.precision = 0xec;
      packet.rootDelay = 0x03_53;
      packet.rootDispersion = 0x03_6c;
      packet.referenceClockIdentifier = 0x5f_51_ad_08;
      packet.referenceTimestamp = 0xd9_39_0d_b2_a4_63_7a_91;
      packet.originateTimestamp = 0xd9_39_0d_73_37_64_28_6d;
      packet.receiveTimestamp = 0xd9_39_0d_73_39_4d_93_98;
      packet.transmitTimestamp = 0xd9_39_0d_b3_58_3e_91_e8;

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [
        0x1b, 0x03, 0x06, 0xec,
        0x00, 0x00, 0x03, 0x53,
        0x00, 0x00, 0x03, 0x6c,
        0x5f, 0x51, 0xad, 0x08,
        0xd9, 0x39, 0x0d, 0xb2,
        0xa4, 0x63, 0x7a, 0x91,
        0xd9, 0x39, 0x0d, 0x73,
        0x37, 0x64, 0x28, 0x6d,
        0xd9, 0x39, 0x0d, 0x73,
        0x39, 0x4d, 0x93, 0x98,
        0xd9, 0x39, 0x0d, 0xb3,
        0x58, 0x3e, 0x91, 0xe8
      ] ~ [42, 21, 84]);
    }

    @property inout string name() { return "NTPv4"; }
    override @property int osiLayer() const { return 7; };
    override string toString() const {
      return toJson.toString;
    }

    @property {
      override Protocol data() { return _data; }
      override void data(Protocol p) { _data = p; }

      inout ubyte leapIndicator() { return _leapIndicator; }
      void leapIndicator(ubyte data) { _leapIndicator = data; }

      inout ubyte versionNumber() { return _versionNumber; }
      void versionNumber(ubyte data) { _versionNumber = data; }

      inout ubyte mode() { return _mode; }
      void mode(ubyte data) { _mode = data; }

      inout ubyte stratum() { return _stratum; }
      void stratum(ubyte data) { _stratum = data; }

      inout ubyte poll() { return _poll; }
      void poll(ubyte data) { _poll = data; }

      inout ubyte precision() { return _precision; }
      void precision(ubyte data) { _precision = data; }

      inout uint rootDelay() { return _rootDelay; }
      void rootDelay(uint data) { _rootDelay = data; }

      inout uint rootDispersion() { return _rootDispersion; }
      void rootDispersion(uint data) { _rootDispersion = data; }

      ref const(NTPv4ExtensionField[]) extensionFields() { return _extensionFields; }
      void extensionFields(NTPv4ExtensionField[] data) { _extensionFields = data; }

      inout uint keyIdentifier() { return _keyIdentifier; }
      void keyIdentifier(uint data) { _keyIdentifier = data; }

      ref ubyte[16] digest() { return _digest; }
      void digest(ubyte[] data) { _digest = data; }
    }

  private:
    Protocol _data = null;

    mixin(bitfields!(
      ubyte, "_leapIndicator", 2,
      ubyte, "_versionNumber", 3,
      ubyte, "_mode", 3
    ));
    ubyte _stratum;
    ubyte _poll;
    ubyte _precision;
    uint _rootDelay;
    uint _rootDispersion;
    NTPv4ExtensionField[] _extensionFields;
    uint _keyIdentifier;
    ubyte[16] _digest;
}

class NTPv4ExtensionField {
  public:
    this() {

    }

    @property {
      inout ushort fieldType() { return _fieldType; }
      void fieldType(ushort data) { _fieldType = data; }

      inout ushort length() { return _length; }
      void length(ushort data) { _length = data; }

      ref const(ubyte[]) value() const { return _value; }
      void value(ubyte[] data) { _value = data; }
    }

    Json toJson() const {
      auto json = Json.emptyObject;
      json.field_type = fieldType;
      json.length_ = length;
      json.value = serializeToJson(_value);
      return json;
    }

    static NTPv4ExtensionField fromJson(Json src) {
      auto extensionField = new NTPv4ExtensionField;
      extensionField.fieldType = src.field_type.to!ushort;
      extensionField.length = src.length_.to!ushort;
      extensionField.value = deserializeJson!(ubyte[])(src.value);
      return extensionField;
    }

  private:
    ushort _fieldType;
    ushort _length;
    ubyte[] _value;
}

Protocol toNTPv4(Json json) {
  auto packet = new NTPv4;
  packet.leapIndicator = json.leap_indicator.to!ubyte;
  packet.versionNumber = json.version_number.to!ubyte;
  packet.mode = json.mode.to!ubyte;
  packet.stratum = json.stratum.to!ubyte;
  packet.poll = json.poll.to!ubyte;
  packet.precision = json.precision.to!ubyte;
  packet.rootDelay = json.root_delay.to!uint;
  packet.rootDispersion = json.root_dispersion.to!uint;
  packet.referenceClockIdentifier = json.reference_clock_identifier.to!uint;
  packet.referenceTimestamp = json.reference_timestamp.to!ulong;
  packet.originateTimestamp = json.originate_timestamp.to!ulong;
  packet.receiveTimestamp = json.receive_timestamp.to!ulong;
  packet.transmitTimestamp = json.transmit_timestamp.to!ulong;
  if (json.extension_fields.type != Json.Type.Undefined)
    packet.extensionFields = deserializeJson!(NTPv4ExtensionField[])(json.extension_fields);
  if (json.key_identifier.type != Json.Type.Undefined)
    packet.keyIdentifier = json.key_identifier.to!uint;
  if (json.digest.type != Json.Type.Undefined)
    packet.digest = deserializeJson!(ubyte[])(json.digest);
  auto data = ("data" in json);
  if (json.data.type != Json.Type.Null && data != null)
    packet.data = netload.protocols.conversion.protocolConversion[deserializeJson!string(data.name)](*data);
  return packet;
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
  auto packet = cast(NTPv4)toNTPv4(json);
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

  auto packet = cast(NTPv4)toNTPv4(json);
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

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "NTPv0";
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

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  auto packet = cast(NTPv4)toNTPv4(json);
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
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

Protocol toNTPv4(ubyte[] encodedPacket) {
  auto packet = new NTPv4;
  {
    ubyte tmp = encodedPacket.read!ubyte;
    packet.leapIndicator = (tmp >> 6) & 0b0000_0011;
    packet.versionNumber = (tmp >> 3) & 0b0000_0111;
    packet.mode = tmp & 0b0000_0111;
  }
  packet.stratum = encodedPacket.read!ubyte;
  packet.poll = encodedPacket.read!ubyte;
  packet.precision = encodedPacket.read!ubyte;
  packet.rootDelay = encodedPacket.read!uint;
  packet.rootDispersion = encodedPacket.read!uint;
  packet.referenceClockIdentifier = encodedPacket.read!uint;
  packet.referenceTimestamp = encodedPacket.read!ulong;
  packet.originateTimestamp = encodedPacket.read!ulong;
  packet.receiveTimestamp = encodedPacket.read!ulong;
  packet.transmitTimestamp = encodedPacket.read!ulong;
  while (encodedPacket.length > 20) {
    auto extensionField = new NTPv4ExtensionField;
    extensionField.fieldType = encodedPacket.read!ushort;
    extensionField.length = encodedPacket.read!ushort;
    extensionField.value = encodedPacket[0..extensionField.length];
    encodedPacket = encodedPacket[extensionField.length..$];
  }
  if (encodedPacket.length >= 4)
    packet.keyIdentifier = encodedPacket.read!uint;
  if (encodedPacket.length == 128) {
    packet.digest = encodedPacket;
  }
  return packet;
}

unittest {
  auto packet = cast(NTPv4)[
    0x1b, 0x03, 0x06, 0xec,
    0x00, 0x00, 0x03, 0x53,
    0x00, 0x00, 0x03, 0x6c,
    0x5f, 0x51, 0xad, 0x08,
    0xd9, 0x39, 0x0d, 0xb2,
    0xa4, 0x63, 0x7a, 0x91,
    0xd9, 0x39, 0x0d, 0x73,
    0x37, 0x64, 0x28, 0x6d,
    0xd9, 0x39, 0x0d, 0x73,
    0x39, 0x4d, 0x93, 0x98,
    0xd9, 0x39, 0x0d, 0xb3,
    0x58, 0x3e, 0x91, 0xe8
  ].toNTPv4;

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
