module netload.protocols.icmp.v4;

import netload.core.protocol;
import netload.protocols.icmp.common;
import vibe.data.json;
import std.bitmanip;

class ICMPv4Communication : ICMP {
  public:
    this(ubyte type) {
      super(type, 0);
    }

    override Json toJson() const {
      Json packet = Json.emptyObject;
      packet.packetType = _type;
      packet.code = _code;
      packet.checksum = _checksum;
      packet.id = _id;
      packet.seq = _seq;
      return packet;
    }

    unittest {
      ICMPv4Communication packet = new ICMPv4Communication(8);
      assert(packet.toJson.packetType == 8);
      assert(packet.toJson.code == 0);
      assert(packet.toJson.checksum == 0);
      assert(packet.toJson.id == 0);
      assert(packet.toJson.seq == 0);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[8];
      packet.write!ubyte(_type, 0);
      packet.write!ubyte(_code, 1);
      packet.write!ushort(_checksum, 2);
      packet.write!ushort(_id, 4);
      packet.write!ushort(_seq, 6);
      return packet;
    }

    unittest {
      ICMPv4Communication packet = new ICMPv4Communication(8);
      packet.id = 1;
      packet.seq = 2;
      assert(packet.toBytes == [8, 0, 0, 0, 0, 1, 0, 2]);
    }

    @disable @property {
      override void code(ubyte code) { _code = code; }
    }

    @property {
      inout ushort id() { return _id; }
      void id(ushort id) { _id = id; }
      inout ushort seq() { return _seq; }
      void seq(ushort seq) { _seq = seq; }
    }

  protected:
    ushort _id = 0;
    ushort _seq = 0;
}

ICMPv4Communication toICMPv4Communication(Json json) {
  ICMPv4Communication packet = new ICMPv4Communication(json.packetType.to!ubyte);
  packet.checksum = json.checksum.to!ushort;
  packet.id = json.id.to!ushort;
  packet.seq = json.seq.to!ushort;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.packetType = 8;
  json.checksum = 0;
  json.id = 1;
  json.seq = 2;
  ICMPv4Communication packet = toICMPv4Communication(json);
  assert(packet.type == 8);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

ICMPv4Communication toICMPv4Communication(ubyte[] encodedPacket) {
  ICMPv4Communication packet = new ICMPv4Communication(encodedPacket.read!ubyte());
  encodedPacket.read!ubyte();
  packet.checksum = encodedPacket.read!ushort();
  packet.id = encodedPacket.read!ushort();
  packet.seq = encodedPacket.read!ushort();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2];
  ICMPv4Communication packet = encodedPacket.toICMPv4Communication;
  assert(packet.type == 8);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
}

class ICMPv4EchoRequest : ICMPv4Communication {
  public:
    this() {
      super(8);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}

class ICMPv4EchoReply : ICMPv4Communication {
  public:
    this() {
      super(0);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}

class ICMPv4Timestamp : ICMPv4Communication {
  public:
    this(ubyte type, uint originTime = 0, uint receiveTime = 0, uint transmitTime = 0) {
      super(type);
      _originTime = originTime;
      _receiveTime = receiveTime;
      _transmitTime = transmitTime;
    }

    override Json toJson() const {
      Json packet = Json.emptyObject;
      packet.packetType = _type;
      packet.code = _code;
      packet.checksum = _checksum;
      packet.id = _id;
      packet.seq = _seq;
      packet.originTime = _originTime;
      packet.receiveTime = _receiveTime;
      packet.transmitTime = _transmitTime;
      return packet;
    }

    unittest {
      ICMPv4Timestamp packet = new ICMPv4Timestamp(14, 21, 42, 84);
      assert(packet.toJson.packetType == 14);
      assert(packet.toJson.code == 0);
      assert(packet.toJson.checksum == 0);
      assert(packet.toJson.id == 0);
      assert(packet.toJson.seq == 0);
      assert(packet.toJson.originTime == 21);
      assert(packet.toJson.receiveTime == 42);
      assert(packet.toJson.transmitTime == 84);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[20];
      packet.write!ubyte(_type, 0);
      packet.write!ubyte(_code, 1);
      packet.write!ushort(_checksum, 2);
      packet.write!ushort(_id, 4);
      packet.write!ushort(_seq, 6);
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

    @property {
      inout uint originTime() { return _originTime; }
      void originTime(uint originTime) { _originTime = originTime; }
      inout uint receiveTime() { return _receiveTime; }
      void receiveTime(uint receiveTime) { _receiveTime = receiveTime; }
      inout uint transmitTime() { return _transmitTime; }
      void transmitTime(uint transmitTime) { _transmitTime = transmitTime; }
    }

  private:
    uint _originTime = 0;
    uint _receiveTime = 0;
    uint _transmitTime = 0;
}

ICMPv4Timestamp toICMPv4Timestamp(Json json) {
  ICMPv4Timestamp packet = new ICMPv4Timestamp(json.packetType.to!ubyte);
  packet.checksum = json.checksum.to!ushort;
  packet.id = json.id.to!ushort;
  packet.seq = json.seq.to!ushort;
  packet.originTime = json.originTime.to!uint;
  packet.receiveTime = json.receiveTime.to!uint;
  packet.transmitTime = json.transmitTime.to!uint;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.packetType = 14;
  json.checksum = 0;
  json.id = 1;
  json.seq = 2;
  json.originTime = 21;
  json.receiveTime = 42;
  json.transmitTime = 84;
  ICMPv4Timestamp packet = toICMPv4Timestamp(json);
  assert(packet.type == 14);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
}

ICMPv4Timestamp toICMPv4Timestamp(ubyte[] encodedPacket) {
  ICMPv4Timestamp packet = new ICMPv4Timestamp(encodedPacket.read!ubyte());
  encodedPacket.read!ubyte();
  packet.checksum = encodedPacket.read!ushort();
  packet.id = encodedPacket.read!ushort();
  packet.seq = encodedPacket.read!ushort();
  packet.originTime = encodedPacket.read!uint();
  packet.receiveTime = encodedPacket.read!uint();
  packet.transmitTime = encodedPacket.read!uint();
  return packet;
}

unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 21, 0, 0, 0, 42, 0, 0, 0, 84];
  ICMPv4Timestamp packet = encodedPacket.toICMPv4Timestamp;
  assert(packet.type == 8);
  assert(packet.checksum == 0);
  assert(packet.id == 1);
  assert(packet.seq == 2);
  assert(packet.originTime == 21);
  assert(packet.receiveTime == 42);
  assert(packet.transmitTime == 84);
}

class ICMPv4TimestampRequest : ICMPv4Timestamp {
  public:
    this(uint originTime = 0, uint receiveTime = 0, uint transmitTime = 0) {
      super(13, originTime, receiveTime, transmitTime);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}

class ICMPv4TimestampReply : ICMPv4Timestamp {
  public:
    this(uint originTime = 0, uint receiveTime = 0, uint transmitTime = 0) {
      super(14, originTime, receiveTime, transmitTime);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}

class ICMPv4InformationRequest : ICMPv4Communication {
  public:
    this() {
      super(15);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}

class ICMPv4InformationReply : ICMPv4Communication {
  public:
    this() {
      super(16);
    }

    @disable @property {
      override void type(ubyte type) { _type = type; }
    }
}
