module netload.protocols.ntp.v4;

import std.bitmanip;
import std.bigint;
import std.array;
import std.conv;
import std.outbuffer;
import std.range;

import stdx.data.json;

import netload.core.protocol;
import netload.protocols.ntp.common;
import netload.core.conversion.json_array;

/++
 + The Network Time Protocol (NTP) is a protocol for synchronizing a set of network
 + clocks using a set of distributed clients and servers.
 +/
class NTPv4 : NTPCommon, Protocol {
public:
    static NTPv4 opCall(inout JSONValue val) {
  		return new NTPv4(val);
  	}

    this() {

    }

    this(JSONValue json) {
		_leapIndicator = json["leap_indicator"].to!ubyte;
		_versionNumber = json["version_number"].to!ubyte;
		_mode = json["mode"].to!ubyte;
		_stratum = json["stratum"].to!ubyte;
		_poll = json["poll"].to!ubyte;
		_precision = json["precision"].to!ubyte;
		_rootDelay = json["root_delay"].to!uint;
		_rootDispersion = json["root_dispersion"].to!uint;
		referenceClockIdentifier = json["reference_clock_identifier"].to!uint;
		referenceTimestamp = json["reference_timestamp"].to!ulong;
		originateTimestamp = json["originate_timestamp"].to!ulong;
		receiveTimestamp = json["receive_timestamp"].to!ulong;
		transmitTimestamp = json["transmit_timestamp"].to!ulong;
		if ("extension_fields" in json && json["extension_fields"] != null) {
			foreach(JSONValue field; json["extension_fields"].get!(JSONValue[])) {
				_extensionFields ~= NTPv4ExtensionField(field);
			}
		}
		if ("key_identifier" in json)
			_keyIdentifier = json["key_identifier"].to!uint;
		if ("digest" in json && json["digest"] != null)
			_digest = json["digest"].toArrayOf!ubyte;
		if ("data" in json && json["data"] != null)
  			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
    }

    this(ubyte[] encodedPacket) {
		{
			ubyte tmp = encodedPacket.read!ubyte;
			_leapIndicator = (tmp >> 6) & 0b0000_0011;
			_versionNumber = (tmp >> 3) & 0b0000_0111;
			_mode = tmp & 0b0000_0111;
		}
		_stratum = encodedPacket.read!ubyte;
		_poll = encodedPacket.read!ubyte;
		_precision = encodedPacket.read!ubyte;
		_rootDelay = encodedPacket.read!uint;
		_rootDispersion = encodedPacket.read!uint;
		referenceClockIdentifier = encodedPacket.read!uint;
		referenceTimestamp = encodedPacket.read!ulong;
		originateTimestamp = encodedPacket.read!ulong;
		receiveTimestamp = encodedPacket.read!ulong;
		transmitTimestamp = encodedPacket.read!ulong;
		while (encodedPacket.length > 20) {
			auto extensionField = encodedPacket.to!NTPv4ExtensionField;
			encodedPacket = encodedPacket[extensionField.length..$];
		}
		if (encodedPacket.length >= 4)
			_keyIdentifier = encodedPacket.read!uint;
		if (encodedPacket.length == 128) {
			_digest = encodedPacket;
		}
    }

    override JSONValue toJson() const {
		JSONValue json = [
			"leap_indicator": JSONValue(leapIndicator),
			"version_number": JSONValue(versionNumber),
			"mode": JSONValue(mode),
			"stratum": JSONValue(stratum),
			"poll": JSONValue(poll),
			"precision": JSONValue(precision),
			"root_delay": JSONValue(rootDelay),
			"root_dispersion": JSONValue(rootDispersion),
			"reference_clock_identifier": JSONValue(referenceClockIdentifier),
			"reference_timestamp": JSONValue(referenceTimestamp),
			"originate_timestamp": JSONValue(originateTimestamp),
			"receive_timestamp": JSONValue(receiveTimestamp),
			"transmit_timestamp": JSONValue(transmitTimestamp)
		];
		if (_extensionFields.length > 0) {
			JSONValue[] fields = [];
			foreach(const(NTPv4ExtensionField) field; _extensionFields) {
				fields ~= field.toJson;
			}
			json["extension_fields"] = JSONValue(fields);
		}
		if (keyIdentifier != 0)
			json["key_identifier"] = keyIdentifier;
		foreach (byte b ; _digest) {
			if (b)
				json["digest"] = _digest.toJsonArray;
		}
		json["name"] = name;
		if (_data is null)
  			json["data"] = JSONValue(null);
  		else
  			json["data"] = _data.toJson;
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
		assert(json["leap_indicator"] == 0x00);
		assert(json["version_number"] == 0x03);
		assert(json["mode"] == 0x03);
		assert(json["stratum"] == 0x03);
		assert(json["poll"] == 0x06);
		assert(json["precision"] == 0xec);
		assert(json["root_delay"] == 0x03_53);
		assert(json["root_dispersion"] == 0x03_6c);
		assert(json["reference_clock_identifier"] == 0x5f_51_ad_08);
		assert(json["reference_timestamp"] == 0xd9_39_0d_b2_a4_63_7a_91);
		assert(json["originate_timestamp"] == 0xd9_39_0d_73_37_64_28_6d);
		assert(json["receive_timestamp"] == 0xd9_39_0d_73_39_4d_93_98);
		assert(json["transmit_timestamp"] == 0xd9_39_0d_b3_58_3e_91_e8);
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

		JSONValue json = packet.toJson;
		assert(json["name"] == "NTPv4");
		assert(json["leap_indicator"] == 0x00);
		assert(json["version_number"] == 0x03);
		assert(json["mode"] == 0x03);
		assert(json["stratum"] == 0x03);
		assert(json["poll"] == 0x06);
		assert(json["precision"] == 0xec);
		assert(json["root_delay"] == 0x03_53);
		assert(json["root_dispersion"] == 0x03_6c);
		assert(json["reference_clock_identifier"] == 0x5f_51_ad_08);
		assert(json["reference_timestamp"] == 0xd9_39_0d_b2_a4_63_7a_91);
		assert(json["originate_timestamp"] == 0xd9_39_0d_73_37_64_28_6d);
		assert(json["receive_timestamp"] == 0xd9_39_0d_73_39_4d_93_98);
		assert(json["transmit_timestamp"] == 0xd9_39_0d_b3_58_3e_91_e8);

		json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
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

    override string toIndentedString(uint idt = 0) const {
  		OutBuffer buf = new OutBuffer();
  		string indent = join(repeat("\t", idt));
  		buf.writef("%s%s%s%s\n", indent, PROTOCOL_NAME, name, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "leap_indicator", RESET_SEQ, FIELD_VALUE, leapIndicator, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "version_number", RESET_SEQ, FIELD_VALUE, versionNumber, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "mode", RESET_SEQ, FIELD_VALUE, mode, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "stratum", RESET_SEQ, FIELD_VALUE, stratum, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "poll", RESET_SEQ, FIELD_VALUE, poll, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "precision", RESET_SEQ, FIELD_VALUE, precision, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "root_delay", RESET_SEQ, FIELD_VALUE, rootDelay, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "root_dispersion", RESET_SEQ, FIELD_VALUE, rootDispersion, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "reference_clock_identifier", RESET_SEQ, FIELD_VALUE, referenceClockIdentifier, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "reference_timestamp", RESET_SEQ, FIELD_VALUE, referenceTimestamp, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "originate_timestamp", RESET_SEQ, FIELD_VALUE, originateTimestamp, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "receive_timestamp", RESET_SEQ, FIELD_VALUE, receiveTimestamp, RESET_SEQ);
			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "transmit_timestamp", RESET_SEQ, FIELD_VALUE, transmitTimestamp, RESET_SEQ);
      if (_extensionFields.length > 0) {
  			string[] fields = [];
  			foreach(const(NTPv4ExtensionField) field; _extensionFields) {
  				fields ~= field.toJson.toJSON;
  			}
  			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "extension_fields", RESET_SEQ, FIELD_VALUE, fields, RESET_SEQ);
  		}
  		if (keyIdentifier != 0)
  			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "key_identifier", RESET_SEQ, FIELD_VALUE, keyIdentifier, RESET_SEQ);
  		foreach (byte b ; _digest) {
  			if (b)
  				buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "digest", RESET_SEQ, FIELD_VALUE, _digest, RESET_SEQ);
  		}
      if (_data is null)
  			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "data", RESET_SEQ, FIELD_VALUE, _data, RESET_SEQ);
  		else
  			buf.writef("%s", _data.toIndentedString(idt + 1));
      return buf.toString;
    }

    override string toString() const {
      return toIndentedString;
    }

    @property {
		override Protocol data() { return _data; }
		override void data(Protocol p) { _data = p; }

		/++
		 + 2-bit integer warning of an impending leap second to be inserted or deleted in the last minute of the current month with values defined like:
		 + <table>
		 +    <tr><td><b>Value</b></td><td><b>Meaning</b></td></tr>
		 +    <tr><td>0</td><td>no warning</td></tr>
		 +    <tr><td>1</td><td>last minute of the day has 61 seconds</td></tr>
		 +    <tr><td>2</td><td>last minute of the day has 59 seconds</td></tr>
		 +    <tr><td>3</td><td>unknown (clock unsynchronized)</td></tr>
		 + </table>
		 +/
		inout ubyte leapIndicator() { return _leapIndicator; }
		///ditto
		void leapIndicator(ubyte data) { _leapIndicator = data; }

		/++
		 + 3-bit integer representing the NTP version number, currently 4.
		 +/
		inout ubyte versionNumber() { return _versionNumber; }
		///ditto
		void versionNumber(ubyte data) { _versionNumber = data; }

		/++
		 + 3-bit integer representing the mode, with values defined like:
		 + <table>
		 +    <tr><td><b>Value</b></td><td><b>Meaning</b></td></tr>
		 +    <tr><td>0</td><td>reserved</td></tr>
		 +    <tr><td>1</td><td>symmetric active</td></tr>
		 +    <tr><td>2</td><td>symmetric passive</td></tr>
		 +    <tr><td>3</td><td>client</td></tr>
		 +    <tr><td>4</td><td>server</td></tr>
		 +    <tr><td>5</td><td>broadcast</td></tr>
		 +    <tr><td>6</td><td>NTP control message</td></tr>
		 +    <tr><td>7</td><td>reserved for private use</td></tr>
		 + </table>
		 +/
		inout ubyte mode() { return _mode; }
		void mode(ubyte data) { _mode = data; }

		/++
		 + 8-bit integer representing the stratum, with values defined like:
		 + <table>
		 +    <tr><td><b>Value</b></td><td><b>Meaning</b></td></tr>
		 +    <tr><td>0</td><td>unspecified or invalid</td></tr>
		 +    <tr><td>1</td><td>primary server (e.g., equipped with a GPS receiver)</td></tr>
		 +    <tr><td>2-15</td><td>secondary server (via NTP)</td></tr>
		 +    <tr><td>16</td><td>unsynchronized</td></tr>
		 +    <tr><td>17-255</td><td>reserved</td></tr>
		 + </table>
		 + It is customary to map the stratum value 0 in received packets to
		 + MAXSTRAT (16) in the peer variable p.stratum and to map p.stratum
		 + values of MAXSTRAT or greater to 0 in transmitted packets. This allows
		 + reference clocks, which normally appear at stratum 0, to be conveniently
		 + mitigated using the same clock selection algorithms used for external
		 + sources.
		 +/
		inout ubyte stratum() { return _stratum; }
		///ditto
		void stratum(ubyte data) { _stratum = data; }

		/++
		 + 8-bit signed integer representing the maximum interval between successive
		 + messages, in log2 seconds. Suggested default limits for minimum and maximum
		 + poll intervals are 6 and 10, respectively.
		 +/
		inout ubyte poll() { return _poll; }
		///ditto
		void poll(ubyte data) { _poll = data; }

		/++
		 + 8-bit signed integer representing the precision of the system clock, in
		 + log2 seconds. For instance, a value of -18 corresponds to a precision of
		 + about one microsecond. The precision can be determined when the service
		 + first starts up as the minimum time of several iterations to read the
		 + system clock.
		 +/
		inout ubyte precision() { return _precision; }
		///ditto
		void precision(ubyte data) { _precision = data; }

		/++
		 + Total round-trip delay to the reference clock, in NTP short format.
		 +/
		inout uint rootDelay() { return _rootDelay; }
		///ditto
		void rootDelay(uint data) { _rootDelay = data; }

		/++
		 + Total dispersion to the reference clock, in NTP short format.
		 +/
		inout uint rootDispersion() { return _rootDispersion; }
		///ditto
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
    static NTPv4ExtensionField opCall(inout JSONValue val) {
  		return new NTPv4ExtensionField(val);
  	}

    this() {

    }

    this(ubyte[] encodedPacket) {
		_fieldType = encodedPacket.read!ushort;
		_length = encodedPacket.read!ushort;
		_value = encodedPacket[0.._length];
    }

    this(JSONValue src) {
		_fieldType = src["field_type"].to!ushort;
		_length = src["length_"].to!ushort;
		_value = src["value"].toArrayOf!ubyte;
    }

    @property {
		inout ushort fieldType() { return _fieldType; }
		void fieldType(ushort data) { _fieldType = data; }

		inout ushort length() { return _length; }
		void length(ushort data) { _length = data; }

		ref const(ubyte[]) value() const { return _value; }
		void value(ubyte[] data) { _value = data; }
    }

    JSONValue toJson() const {
		JSONValue json = [
			"field_type": JSONValue(fieldType),
			"length_": JSONValue(length),
			"value": (_value.toJsonArray)
		];
		return json;
    }

    ubyte[] toBytes() const {
		auto packet = appender!(ubyte[])();
		packet.append!ushort(fieldType);
		packet.append!ushort(length);
		foreach (ubyte b ; value)
			packet.append!ubyte(b);
		return packet.data;
    }

private:
    ushort _fieldType;
    ushort _length;
    ubyte[] _value;
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
	auto packet = cast(NTPv4)to!NTPv4(json);
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
	json["extension_fields"] = JSONValue(fields);
	json["key_identifier"] = JSONValue(0x00);
	JSONValue[] digest = [];
	for (int i = 0 ; i < 16 ; ++i) {
		digest ~= JSONValue(0x00);
	}
	json["digest"] = JSONValue(digest);

	auto packet = cast(NTPv4)to!NTPv4(json);
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

	JSONValue json = [
		"name": JSONValue("NTPv0"),
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
	json["extension_fields"] = JSONValue(fields);
	json["key_identifier"] = JSONValue(0x00);
	JSONValue[] digest = [];
	for (int i = 0 ; i < 16 ; ++i) {
		digest ~= JSONValue(0x00);
	}
	json["digest"] = JSONValue(digest);

	json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": JSONValue((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

	auto packet = cast(NTPv4)to!NTPv4(json);
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

unittest {
	auto packet = cast(NTPv4)(cast(ubyte[])[
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
	]).to!NTPv4;

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
