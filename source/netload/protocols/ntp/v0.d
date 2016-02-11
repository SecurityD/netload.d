module netload.protocols.ntp.v0;

import std.bitmanip;
import std.conv;

import stdx.data.json;

import netload.core.protocol;
import netload.protocols.ntp.common;
import netload.core.conversion.json_array;

class NTPv0 : NTPCommon, Protocol {
  public:
    static NTPv0 opCall(inout JSONValue val) {
  		return new NTPv0(val);
  	}

    this() {

    }

    this(JSONValue json) {
      _leapIndicator = json["leap_indicator"].to!ubyte;
      _status = json["status"].to!ubyte;
      _type = json["type_"].to!ubyte;
      _precision = json["precision"].to!ushort;
      _estimatedError = json["estimated_error"].to!uint;
      _estimatedDriftRate = json["estimated_drift_rate"].to!uint;
      referenceClockIdentifier = json["reference_clock_identifier"].to!uint;
      referenceTimestamp = json["reference_timestamp"].to!ulong;
      originateTimestamp = json["originate_timestamp"].to!ulong;
      receiveTimestamp = json["receive_timestamp"].to!ulong;
      transmitTimestamp = json["transmit_timestamp"].to!ulong;
      if ("data" in json && json["data"] != null)
  			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
    }

    this(ubyte[] encodedPacket) {
      ubyte tmp = encodedPacket.read!ubyte;
      _leapIndicator = (tmp >> 6) & 0b0000_0011;
      _status = tmp & 0b0011_1111;
      _type = encodedPacket.read!ubyte;
      _precision = encodedPacket.read!ushort;
      _estimatedError = encodedPacket.read!uint;
      _estimatedDriftRate = encodedPacket.read!uint;
      referenceClockIdentifier = encodedPacket.read!uint;
      referenceTimestamp = encodedPacket.read!ulong;
      originateTimestamp = encodedPacket.read!ulong;
      receiveTimestamp = encodedPacket.read!ulong;
      transmitTimestamp = encodedPacket.read!ulong;
    }

    override JSONValue toJson() const {
      JSONValue json = [
        "leap_indicator": JSONValue(leapIndicator),
        "status": JSONValue(status),
        "type_": JSONValue(type),
        "precision": JSONValue(precision),
        "estimated_error": JSONValue(estimatedError),
        "estimated_drift_rate": JSONValue(estimatedDriftRate),
        "reference_clock_identifier": JSONValue(referenceClockIdentifier),
        "reference_timestamp": JSONValue(referenceTimestamp),
        "originate_timestamp": JSONValue(originateTimestamp),
        "receive_timestamp": JSONValue(receiveTimestamp),
        "transmit_timestamp": JSONValue(transmitTimestamp),
        "name": JSONValue(name)
      ];
      if (_data is null)
  			json["data"] = JSONValue(null);
  		else
  			json["data"] = _data.toJson;
  		return json;
    }

    unittest {
      auto ntp = new NTPv0;
      ntp.leapIndicator = 2u;
      ntp.status = 4u;
      ntp.type = 50u;
      ntp.precision = 100u;
      ntp.estimatedError = 150u;
      ntp.estimatedDriftRate = 200u;
      ntp.referenceClockIdentifier = 250u;
      ntp.referenceTimestamp = 300u;
      ntp.originateTimestamp = 350u;
      ntp.receiveTimestamp = 400u;
      ntp.transmitTimestamp = 450u;

      JSONValue test = [
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
        "transmit_timestamp": JSONValue(450u),
        "name": JSONValue("NTPv0"),
        "data": JSONValue(null)
      ];

      assert(ntp.toJson == test);
    }

    unittest {
      import netload.protocols.raw;

      auto packet = new NTPv0;
      packet.leapIndicator = 2u;
      packet.status = 4u;
      packet.type = 50u;
      packet.precision = 100u;
      packet.estimatedError = 150u;
      packet.estimatedDriftRate = 200u;
      packet.referenceClockIdentifier = 250u;
      packet.referenceTimestamp = 300u;
      packet.originateTimestamp = 350u;
      packet.receiveTimestamp = 400u;
      packet.transmitTimestamp = 450u;

      packet.data = new Raw([42, 21, 84]);

      JSONValue json = packet.toJson;
      assert(json["name"] == "NTPv0");
      assert(json["leap_indicator"] == 2u);
      assert(json["status"] == 4u);
      assert(json["type_"] == 50u);
      assert(json["precision"] == 100u);
      assert(json["estimated_error"] == 150u);
      assert(json["estimated_drift_rate"] == 200u);
      assert(json["reference_clock_identifier"] == 250u);
      assert(json["reference_timestamp"] == 300u);
      assert(json["originate_timestamp"] == 350u);
      assert(json["receive_timestamp"] == 400u);
      assert(json["transmit_timestamp"] == 450u);

      json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
    }

    override ubyte[] toBytes() const {
      auto packet = new ubyte[48];
      packet.write!ubyte(cast(ubyte)((leapIndicator << 6) + status), 0);
      packet.write!ubyte(type, 1);
      packet.write!ushort(precision, 2);
      packet.write!uint(estimatedError, 4);
      packet.write!uint(estimatedDriftRate, 8);
      packet.write!uint(referenceClockIdentifier, 12);
      packet.write!ulong(referenceTimestamp, 16);
      packet.write!ulong(originateTimestamp, 24);
      packet.write!ulong(receiveTimestamp, 32);
      packet.write!ulong(transmitTimestamp, 40);
      if (_data !is null)
        packet ~= _data.toBytes;
      return packet;
    }

    unittest {
      auto ntp = new NTPv0;
      ntp.leapIndicator = 2u;
      ntp.status = 4u;
      ntp.type = 50u;
      ntp.precision = 100u;
      ntp.estimatedError = 150u;
      ntp.estimatedDriftRate = 200u;
      ntp.referenceClockIdentifier = 250u;
      ntp.referenceTimestamp = 300u;
      ntp.originateTimestamp = 350u;
      ntp.receiveTimestamp = 400u;
      ntp.transmitTimestamp = 450u;
      assert(ntp.toBytes == [
        132,  50,   0, 100,
          0,   0,   0, 150,
          0,   0,   0, 200,
          0,   0,   0, 250,
          0,   0,   0,   0,
          0,   0,   1,  44,
          0,   0,   0,   0,
          0,   0,   1,  94,
          0,   0,   0,   0,
          0,   0,   1, 144,
          0,   0,   0,   0,
          0,   0,   1, 194
      ]);
    }

    unittest {
      import netload.protocols.raw;

      auto packet = new NTPv0;
      packet.leapIndicator = 2u;
      packet.status = 4u;
      packet.type = 50u;
      packet.precision = 100u;
      packet.estimatedError = 150u;
      packet.estimatedDriftRate = 200u;
      packet.referenceClockIdentifier = 250u;
      packet.referenceTimestamp = 300u;
      packet.originateTimestamp = 350u;
      packet.receiveTimestamp = 400u;
      packet.transmitTimestamp = 450u;

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [
        132,  50,   0, 100,
          0,   0,   0, 150,
          0,   0,   0, 200,
          0,   0,   0, 250,
          0,   0,   0,   0,
          0,   0,   1,  44,
          0,   0,   0,   0,
          0,   0,   1,  94,
          0,   0,   0,   0,
          0,   0,   1, 144,
          0,   0,   0,   0,
          0,   0,   1, 194
      ] ~ [42, 21, 84]);
    }

    @property inout string name() { return "NTPv0"; }
    override @property int osiLayer() const { return 7; };
    override string toString() const { return toJson.toJSON; }

    @property {
      override Protocol data() { return _data; }
      override @property void data(Protocol p) { _data = p; }

      ubyte leapIndicator() const { return _leapIndicator; }
      void leapIndicator(ubyte data) { _leapIndicator = data; }

      ubyte status() const { return _status; }
      void status(ubyte data) { _status = data; }

      ubyte type() const { return _type; }
      void type(ubyte data) { _type = data; }

      ushort precision() const { return _precision; }
      void precision(ushort data) { _precision = data; }

      uint estimatedError() const { return _estimatedError; }
      void estimatedError(uint data) { _estimatedError = data; }

      uint estimatedDriftRate() const { return _estimatedDriftRate; }
      void estimatedDriftRate(uint data) { _estimatedDriftRate = data; }
    }

  private:
    Protocol _data = null;

    mixin(bitfields!(
      ubyte, "_leapIndicator", 2,
      ubyte, "_status", 6
    ));
    ubyte _type;
    ushort _precision;
    uint _estimatedError;
    uint _estimatedDriftRate;
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

  auto packet = cast(NTPv0)to!NTPv0(json);

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

unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("NTPv0"),
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

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": JSONValue((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  auto packet = cast(NTPv0)to!NTPv0(json);
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
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  auto packet = cast(NTPv0)(cast(ubyte[])[
    132,  50,   0, 100,
      0,   0,   0, 150,
      0,   0,   0, 200,
      0,   0,   0, 250,
      0,   0,   0,   0,
      0,   0,   1,  44,
      0,   0,   0,   0,
      0,   0,   1,  94,
      0,   0,   0,   0,
      0,   0,   1, 144,
      0,   0,   0,   0,
      0,   0,   1, 194
  ]).to!NTPv0;
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
