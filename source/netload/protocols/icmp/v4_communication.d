module netload.protocols.icmp.v4_communication;

import netload.core.protocol;
import netload.protocols.icmp.common;
import netload.core.conversion.array_conversion;
import stdx.data.json;
import std.bitmanip;
import std.conv;

alias ICMPv4Communication = ICMPv4CommunicationBase!(ICMPType.ANY);
alias ICMPv4EchoRequest = ICMPv4CommunicationBase!(ICMPType.ECHO_REQUEST);
alias ICMPv4EchoReply = ICMPv4CommunicationBase!(ICMPType.ECHO_REPLY);
alias ICMPv4InformationRequest = ICMPv4CommunicationBase!(ICMPType.INFORMATION_REQUEST);
alias ICMPv4InformationReply = ICMPv4CommunicationBase!(ICMPType.INFORMATION_REPLY);
alias ICMPv4Timestamp = ICMPv4TimestampBase!(ICMPType.ANY);
alias ICMPv4TimestampRequest = ICMPv4TimestampBase!(ICMPType.TIMESTAMP_REQUEST);
alias ICMPv4TimestampReply = ICMPv4TimestampBase!(ICMPType.TIMESTAMP_REPLY);

class ICMPv4CommunicationBase(ICMPType __type__) : ICMPBase!(ICMPType.NONE) {
  public:
    static ICMPv4CommunicationBase!(__type__) opCall(inout JSONValue val) {
  		return new ICMPv4CommunicationBase!(__type__)(val);
  	}

    this(ubyte type) {
      super(type, 0);
    }

    this() {
      static if (__type__ == ICMPType.ANY)
        super();
      else static if (__type__ == ICMPType.ECHO_REQUEST)
        this(8);
      else static if (__type__ == ICMPType.ECHO_REPLY)
        this(0);
      else static if (__type__ == ICMPType.INFORMATION_REQUEST)
        this(15);
      else static if (__type__ == ICMPType.INFORMATION_REPLY)
        this(16);
    }

    this(JSONValue json) {
      super(json);
      _id = json["id"].to!ushort;
      _seq = json["seq"].to!ushort;
    }

    this(ref ubyte[] encodedPacket) {
      super(encodedPacket);
      _id = encodedPacket.read!ushort();
      _seq = encodedPacket.read!ushort();
    }

    override JSONValue toJson() const {
      JSONValue json = super.toJson();
      json["id"] = JSONValue(_id);
      json["seq"] = JSONValue(_seq);
      return json;
    }

    unittest {
      ICMPv4Communication packet = new ICMPv4Communication(8);
      assert(packet.toJson["packetType"] == 8);
      assert(packet.toJson["code"] == 0);
      assert(packet.toJson["checksum"] == 0);
      assert(packet.toJson["id"] == 0);
      assert(packet.toJson["seq"] == 0);
    }

    unittest {
      import netload.protocols.raw;
      ICMPv4Communication packet = new ICMPv4Communication(8);

      packet.data = new Raw([42, 21, 84]);

      JSONValue json = packet.toJson;
      assert(json["name"] == "ICMP");
      assert(json["packetType"] == 8);
      assert(json["code"] == 0);
      assert(json["checksum"] == 0);
      assert(json["id"] == 0);
      assert(json["seq"] == 0);

      json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[8];
      packet.write!ubyte(_type, 0);
      packet.write!ubyte(_code, 1);
      packet.write!ushort(_checksum, 2);
      packet.write!ushort(_id, 4);
      packet.write!ushort(_seq, 6);
      if (_data !is null)
        packet ~= _data.toBytes;
      return packet;
    }

    unittest {
      ICMPv4Communication packet = new ICMPv4Communication(8);
      packet.id = 1;
      packet.seq = 2;
      assert(packet.toBytes == [8, 0, 0, 0, 0, 1, 0, 2]);
    }

    unittest {
      import netload.protocols.raw;

      ICMPv4Communication packet = new ICMPv4Communication(8);
      packet.id = 1;
      packet.seq = 2;

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [8, 0, 0, 0, 0, 1, 0, 2] ~ [42, 21, 84]);
    }

    @property {
      inout ushort id() { return _id; }
      void id(ushort id) { _id = id; }
      inout ushort seq() { return _seq; }
      void seq(ushort seq) { _seq = seq; }
      static if (__type__ == ICMPType.ANY) {
        inout ubyte type() { return _type; }
        void type(ubyte type) { _type = type; }
      }
    }

  protected:
    ushort _id = 0;
    ushort _seq = 0;
}

unittest {
  JSONValue json = [
    "packetType": JSONValue(8),
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];
  ICMPv4Communication packet = cast(ICMPv4Communication)to!ICMPv4Communication(json);
  assert(packet.type == 8);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "packetType": JSONValue(8),
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4Communication packet = cast(ICMPv4Communication)to!ICMPv4Communication(json);
  assert(packet.type == 8);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2];
  ICMPv4Communication packet = cast(ICMPv4Communication)encodedPacket.to!ICMPv4Communication;
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
  ICMPv4EchoRequest packet = cast(ICMPv4EchoRequest)to!ICMPv4EchoRequest(json);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4EchoRequest packet = cast(ICMPv4EchoRequest)to!ICMPv4EchoRequest(json);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2];
  ICMPv4EchoRequest packet = cast(ICMPv4EchoRequest)encodedPacket.to!ICMPv4EchoRequest;
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
  ICMPv4EchoReply packet = cast(ICMPv4EchoReply)to!ICMPv4EchoReply(json);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4EchoReply packet = cast(ICMPv4EchoReply)to!ICMPv4EchoReply(json);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2];
  ICMPv4EchoReply packet = cast(ICMPv4EchoReply)encodedPacket.to!ICMPv4EchoReply;
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

class ICMPv4TimestampBase(ICMPType __type__) : ICMPv4CommunicationBase!(ICMPType.NONE) {
  public:
    static ICMPv4TimestampBase!(__type__) opCall(inout JSONValue val) {
  		return new ICMPv4TimestampBase!(__type__)(val);
  	}

    this() {
      super();
    }

    this(ubyte type, uint originTime = 0, uint receiveTime = 0, uint transmitTime = 0) {
      static if (__type__ == ICMPType.ANY)
        super(type);
      else static if (__type__ == ICMPType.TIMESTAMP_REQUEST)
        super(13);
      else static if (__type__ == ICMPType.TIMESTAMP_REPLY)
        super(14);
      _originTime = originTime;
      _receiveTime = receiveTime;
      _transmitTime = transmitTime;
    }

    this(JSONValue json) {
      super(json);
      _originTime = json["originTime"].to!uint;
      _receiveTime = json["receiveTime"].to!uint;
      _transmitTime = json["transmitTime"].to!uint;
    }

    this(ubyte[] encodedPacket) {
      super(encodedPacket);
      _originTime = encodedPacket.read!uint();
      _receiveTime = encodedPacket.read!uint();
      _transmitTime = encodedPacket.read!uint();
    }

    override JSONValue toJson() const {
      JSONValue json = super.toJson();
      json["originTime"] = JSONValue(_originTime);
      json["receiveTime"] = JSONValue(_receiveTime);
      json["transmitTime"] = JSONValue(_transmitTime);
      return json;
    }

    unittest {
      ICMPv4Timestamp packet = new ICMPv4Timestamp(14, 21, 42, 84);
      assert(packet.toJson["packetType"] == 14);
      assert(packet.toJson["code"] == 0);
      assert(packet.toJson["checksum"] == 0);
      assert(packet.toJson["id"] == 0);
      assert(packet.toJson["seq"] == 0);
      assert(packet.toJson["originTime"] == 21);
      assert(packet.toJson["receiveTime"] == 42);
      assert(packet.toJson["transmitTime"] == 84);
    }

    unittest {
      import netload.protocols.raw;
      ICMPv4Timestamp packet = new ICMPv4Timestamp(14, 21, 42, 84);

      packet.data = new Raw([42, 21, 84]);

      JSONValue json = packet.toJson;
      assert(json["name"] == "ICMP");
      assert(json["packetType"] == 14);
      assert(json["code"] == 0);
      assert(json["checksum"] == 0);
      assert(json["id"] == 0);
      assert(json["seq"] == 0);
      assert(json["originTime"] == 21);
      assert(json["receiveTime"] == 42);
      assert(json["transmitTime"] == 84);

      json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[20];
      packet.write!ubyte(_type, 0);
      packet.write!ubyte(_code, 1);
      packet.write!ushort(_checksum, 2);
      packet.write!ushort(_id, 4);
      packet.write!ushort(_seq, 6);
      if (_data !is null)
        packet ~= _data.toBytes;
      packet.write!uint(_originTime, 8);
      packet.write!uint(_receiveTime, 12);
      packet.write!uint(_transmitTime, 16);
      return packet;
    }

    unittest {
      ICMPv4Timestamp packet = new ICMPv4Timestamp(14, 21, 42, 84);
      packet.id = 1;
      packet.seq = 2;
      assert(packet.toBytes == [14, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 21, 0, 0, 0, 42, 0, 0, 0, 84]);
    }

    unittest {
      import netload.protocols.raw;

      ICMPv4Timestamp packet = new ICMPv4Timestamp(14, 21, 42, 84);
      packet.id = 1;
      packet.seq = 2;

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [14, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 21, 0, 0, 0, 42, 0, 0, 0, 84] ~ [42, 21, 84]);
    }

    @property {
      inout uint originTime() { return _originTime; }
      void originTime(uint originTime) { _originTime = originTime; }
      inout uint receiveTime() { return _receiveTime; }
      void receiveTime(uint receiveTime) { _receiveTime = receiveTime; }
      inout uint transmitTime() { return _transmitTime; }
      void transmitTime(uint transmitTime) { _transmitTime = transmitTime; }
      static if (__type__ == ICMPType.ANY) {
        inout ubyte type() { return _type; }
        void type(ubyte type) { _type = type; }
      }
    }

  private:
    uint _originTime = 0;
    uint _receiveTime = 0;
    uint _transmitTime = 0;
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
  ICMPv4Timestamp packet = cast(ICMPv4Timestamp)to!ICMPv4Timestamp(json);
  assert(packet.type == 14);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
}

unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "packetType": JSONValue(14),
    "id": JSONValue(1),
    "seq": JSONValue(2),
    "originTime": JSONValue(21),
    "receiveTime": JSONValue(42),
    "transmitTime": JSONValue(84)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4Timestamp packet = cast(ICMPv4Timestamp)to!ICMPv4Timestamp(json);
  assert(packet.type == 14);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 21, 0, 0, 0, 42, 0, 0, 0, 84];
  ICMPv4Timestamp packet = cast(ICMPv4Timestamp)encodedPacket.to!ICMPv4Timestamp;
  assert(packet.type == 8);
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
  ICMPv4TimestampRequest packet = cast(ICMPv4TimestampRequest)to!ICMPv4TimestampRequest(json);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
}

unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "packetType": JSONValue(14),
    "id": JSONValue(1),
    "seq": JSONValue(2),
    "originTime": JSONValue(21),
    "receiveTime": JSONValue(42),
    "transmitTime": JSONValue(84)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4TimestampRequest packet = cast(ICMPv4TimestampRequest)to!ICMPv4TimestampRequest(json);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 21, 0, 0, 0, 42, 0, 0, 0, 84];
  ICMPv4TimestampRequest packet = cast(ICMPv4TimestampRequest)encodedPacket.to!ICMPv4TimestampRequest;
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
  ICMPv4TimestampReply packet = cast(ICMPv4TimestampReply)to!ICMPv4TimestampReply(json);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
}

unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "packetType": JSONValue(14),
    "id": JSONValue(1),
    "seq": JSONValue(2),
    "originTime": JSONValue(21),
    "receiveTime": JSONValue(42),
    "transmitTime": JSONValue(84)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4TimestampReply packet = cast(ICMPv4TimestampReply)to!ICMPv4TimestampReply(json);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 21, 0, 0, 0, 42, 0, 0, 0, 84];
  ICMPv4TimestampReply packet = cast(ICMPv4TimestampReply)encodedPacket.to!ICMPv4TimestampReply;
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
  ICMPv4InformationRequest packet = cast(ICMPv4InformationRequest)to!ICMPv4InformationRequest(json);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4InformationRequest packet = cast(ICMPv4InformationRequest)to!ICMPv4InformationRequest(json);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2];
  ICMPv4InformationRequest packet = cast(ICMPv4InformationRequest)encodedPacket.to!ICMPv4InformationRequest;
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
  ICMPv4InformationReply packet = cast(ICMPv4InformationReply)to!ICMPv4InformationReply(json);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "checksum": JSONValue(0),
    "id": JSONValue(1),
    "seq": JSONValue(2)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4InformationReply packet = cast(ICMPv4InformationReply)to!ICMPv4InformationReply(json);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2];
  ICMPv4InformationReply packet = cast(ICMPv4InformationReply)encodedPacket.to!ICMPv4InformationReply;
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}
