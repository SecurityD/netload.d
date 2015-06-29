module netload.protocols.ntp.v0;

import std.bitmanip;

import vibe.data.json;

import netload.core.protocol;
import netload.protocols.ntp.common;

class NTPv0 : NTPCommon, Protocol {
  public:
    this() {

    }

    override Json toJson() const {
      auto json = Json.emptyObject;
      json.leap_indicator = leapIndicator;
      json.status = status;
      json.type_ = type;
      json.precision = precision;
      json.estimated_error = estimatedError;
      json.estimated_drift_rate = estimatedDriftRate;
      json.reference_clock_identifier = referenceClockIdentifier;
      json.reference_timestamp = referenceTimestamp;
      json.originate_timestamp = originateTimestamp;
      json.receive_timestamp = receiveTimestamp;
      json.transmit_timestamp = transmitTimestamp;
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

      auto test = Json.emptyObject;
      test.leap_indicator = 2u;
      test.status = 4u;
      test.type_ = 50u;
      test.precision = 100u;
      test.estimated_error = 150u;
      test.estimated_drift_rate = 200u;
      test.reference_clock_identifier = 250u;
      test.reference_timestamp = 300u;
      test.originate_timestamp = 350u;
      test.receive_timestamp = 400u;
      test.transmit_timestamp = 450u;

      assert(ntp.toJson == test);
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

    @property inout string name() { return "NTPv0"; }
    override @property int osiLayer() const { return 7; };
    override string toString() const { return toJson.toString; }

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
    Protocol _data;

    mixin(bitfields!(
      ubyte, "_leapIndicator", 2,
      ubyte, "_status", 6
    ));
    ubyte _type;
    ushort _precision;
    uint _estimatedError;
    uint _estimatedDriftRate;
}

NTPv0 toNTPv0(Json json) {
  auto packet = new NTPv0;
  packet.leapIndicator = json.leap_indicator.to!ubyte;
  packet.status = json.status.to!ubyte;
  packet.type = json.type_.to!ubyte;
  packet.precision = json.precision.to!ushort;
  packet.estimatedError = json.estimated_error.to!uint;
  packet.estimatedDriftRate = json.estimated_drift_rate.to!uint;
  packet.referenceClockIdentifier = json.reference_clock_identifier.to!uint;
  packet.referenceTimestamp = json.reference_timestamp.to!ulong;
  packet.originateTimestamp = json.originate_timestamp.to!ulong;
  packet.receiveTimestamp = json.receive_timestamp.to!ulong;
  packet.transmitTimestamp = json.transmit_timestamp.to!ulong;
  return packet;
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

  auto packet = toNTPv0(json);

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

NTPv0 toNTPv0(ubyte[] encodedPacket) {
  auto packet = new NTPv0;
  ubyte tmp = encodedPacket.read!ubyte;
  packet.leapIndicator = (tmp >> 6) & 0b0000_0011;
  packet.status = tmp & 0b0011_1111;
  packet.type = encodedPacket.read!ubyte;
  packet.precision = encodedPacket.read!ushort;
  packet.estimatedError = encodedPacket.read!uint;
  packet.estimatedDriftRate = encodedPacket.read!uint;
  packet.referenceClockIdentifier = encodedPacket.read!uint;
  packet.referenceTimestamp = encodedPacket.read!ulong;
  packet.originateTimestamp = encodedPacket.read!ulong;
  packet.receiveTimestamp = encodedPacket.read!ulong;
  packet.transmitTimestamp = encodedPacket.read!ulong;
  return packet;
}

unittest {
  auto packet = [
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
  ].toNTPv0;
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
