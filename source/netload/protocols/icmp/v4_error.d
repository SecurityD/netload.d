module netload.protocols.icmp.v4_error;

import netload.core.protocol;
import netload.protocols.icmp.common;
import netload.protocols.ip;
import vibe.data.json;
import std.bitmanip;

alias ICMPv4Error = ICMPv4ErrorBase!(ICMPType.ANY);
alias ICMPv4DestUnreach = ICMPv4ErrorBase!(ICMPType.DEST_UNREACH);
alias ICMPv4TimeExceed = ICMPv4ErrorBase!(ICMPType.TIME_EXCEED);
alias ICMPv4SourceQuench = ICMPv4ErrorBase!(ICMPType.SOURCE_QUENCH);
alias ICMPv4Redirect = ICMPv4ErrorBase!(ICMPType.REDIRECT);
alias ICMPv4ParamProblem = ICMPv4ErrorBase!(ICMPType.PARAM_PROBLEM);

class ICMPv4ErrorBase(ICMPType __type__) : ICMPBase!(ICMPType.NONE) {
  public:
    this(Json json) {
        static if (__type__ == ICMPType.ANY)
          _type = json.packetType.to!ubyte;
        else
          this();
        _code = json.code.to!ubyte;
        _checksum = json.checksum.to!ushort;
        static if (__type__ == ICMPType.PARAM_PROBLEM)
          _ptr = json.ptr.to!ubyte;
        else static if (__type__ == ICMPType.REDIRECT)
          _gateway = json.gateway.to!uint;
        auto packetData = ("data" in json);
        if (json.data.type != Json.Type.Null && packetData != null)
          _data = netload.protocols.conversion.protocolConversion[deserializeJson!string(packetData.name)](*packetData);
    }

    this(ubyte[] encodedPacket) {
      static if (__type__ == ICMPType.ANY) {
        super(encodedPacket);
        encodedPacket.read!uint();
      }
      else {
        this();
        encodedPacket.read!ubyte();
        _code = encodedPacket.read!ubyte();
        _checksum = encodedPacket.read!ushort();
        static if (__type__ == ICMPType.PARAM_PROBLEM) {
          _ptr = encodedPacket.read!ubyte();
          encodedPacket.read!ubyte();
          encodedPacket.read!ushort();
        }
        else static if (__type__ == ICMPType.REDIRECT)
          _gateway = encodedPacket.read!uint();
        else
          encodedPacket.read!uint();
      }
    }

    static if (__type__ == ICMPType.ANY) {
      this() {
        super();
      }

      this(ubyte type, ubyte code = 0, IP data = null) {
        super(type, code);
        _data = data;
      }
    }
    else static if (__type__ == ICMPType.REDIRECT) {
      this() {
        super(5, 0);
      }

      this(ubyte code, uint gateway, IP data) {
        super(5, code);
        _data = data;
        _gateway = gateway;
      }
    }
    else static if (__type__ == ICMPType.PARAM_PROBLEM) {
      this() {
        super(12, 0);
      }

      this(ubyte code, ubyte ptr, IP data) {
        super(12, code);
        _data = data;
        _ptr = ptr;
      }
    }
    else {
      this() {
        static if (__type__ == ICMPType.DEST_UNREACH)
          super(3, 0);
        else static if (__type__ == ICMPType.TIME_EXCEED)
          super(11, 0);
        else static if (__type__ == ICMPType.SOURCE_QUENCH)
          super(4, 0);
      }

      this(ubyte code, IP data) {
        static if (__type__ == ICMPType.DEST_UNREACH)
          super(3, code);
        else static if (__type__ == ICMPType.TIME_EXCEED)
          super(11, code);
        else static if (__type__ == ICMPType.SOURCE_QUENCH)
          super(4, code);
        _data = data;
      }
    }

    override Json toJson() const {
      Json packet = super.toJson();
      static if (__type__ == ICMPType.REDIRECT)
        packet.gateway = _gateway;
      else static if (__type__ == ICMPType.PARAM_PROBLEM)
        packet.ptr = _ptr;
      return packet;
    }

    unittest {
      ICMPv4Redirect packet = new ICMPv4Redirect(2, 42, null);
      assert(packet.toJson.packetType == 5);
      assert(packet.toJson.code == 2);
      assert(packet.toJson.checksum == 0);
      assert(packet.toJson.gateway == 42);
    }

    unittest {
      import netload.protocols.raw;
      ICMPv4Redirect packet = new ICMPv4Redirect(2, 42, null);

      packet.data = new Raw([42, 21, 84]);

      Json json = packet.toJson;
      assert(json.name == "ICMP");
      assert(json.packetType == 5);
      assert(json.code == 2);
      assert(json.checksum == 0);
      assert(json.gateway == 42);

      json = json.data;
    }

    unittest {
      ICMPv4ParamProblem packet = new ICMPv4ParamProblem(2, 1, null);
      assert(packet.toJson.packetType == 12);
      assert(packet.toJson.code == 2);
      assert(packet.toJson.checksum == 0);
      assert(packet.toJson.ptr == 1);
    }

    unittest {
      import netload.protocols.ethernet;
      import netload.protocols.raw;
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);

      ICMPv4ParamProblem icmp = new ICMPv4ParamProblem(2, 1, null);
      packet.data = icmp;

      packet.data.data = new Raw([42, 21, 84]);

      Json json = packet.toJson;
      assert(json.name == "Ethernet");
      assert(json.dest_mac_address == "00:00:00:00:00:00");
      assert(json.src_mac_address == "ff:ff:ff:ff:ff:ff");

      json = json.data;
      assert(json.name == "ICMP");
      assert(json.packetType == 12);
      assert(json.code == 2);
      assert(json.checksum == 0);
      assert(json.ptr == 1);

      json = json.data;
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[8];
      packet.write!ubyte(_type, 0);
      packet.write!ubyte(_code, 1);
      packet.write!ushort(_checksum, 2);
      static if (__type__ == ICMPType.REDIRECT)
        packet.write!uint(_gateway, 4);
      static if (__type__ == ICMPType.PARAM_PROBLEM)
        packet.write!ubyte(_ptr, 4);
      if (_data !is null)
        packet ~= _data.toBytes;
      return packet;
    }

    unittest {
      ICMPv4Error packet = new ICMPv4Error(3, 1, null);
      assert(packet.toBytes == [3, 1, 0, 0, 0, 0, 0, 0]);
    }

    unittest {
      import netload.protocols.raw;

      ICMPv4Error packet = new ICMPv4Error(3, 1, null);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [3, 1, 0, 0, 0, 0, 0, 0] ~ [42, 21, 84]);
    }

    unittest {
      ICMPv4Redirect packet = new ICMPv4Redirect(2, 42, null);
      assert(packet.toBytes == [5, 2, 0, 0, 0, 0, 0, 42]);
    }

    unittest {
      import netload.protocols.raw;

      ICMPv4Redirect packet = new ICMPv4Redirect(2, 42, null);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [5, 2, 0, 0, 0, 0, 0, 42] ~ [42, 21, 84]);
    }

    unittest {
      ICMPv4ParamProblem packet = new ICMPv4ParamProblem(2, 1, null);
      assert(packet.toBytes == [12, 2, 0, 0, 1, 0, 0, 0]);
    }

    unittest {
      import netload.protocols.raw;

      ICMPv4ParamProblem packet = new ICMPv4ParamProblem(2, 1, null);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [12, 2, 0, 0, 1, 0, 0, 0] ~ [42, 21, 84]);
    }

    @property {
      inout ubyte code() { return _code; }
      void code(ubyte code) { _code = code; }
      static if (__type__ == ICMPType.ANY) {
        inout ubyte type() { return _type; }
        void type(ubyte type) { _type = type; }
      }
    }

    static if (__type__ == ICMPType.REDIRECT) {
      @property {
        inout uint gateway() { return _gateway; }
        void gateway(uint gateway) { _gateway = gateway; }
      }

      private:
        uint _gateway = 0;
    }
    else static if (__type__ == ICMPType.PARAM_PROBLEM) {
      @property {
        inout ubyte ptr() { return _ptr; }
        void ptr(ubyte ptr) { _ptr = ptr; }
      }

      private:
        ubyte _ptr = 0;
    }
}

unittest {
  Json json = Json.emptyObject;
  json.packetType = 3;
  json.code = 2;
  json.checksum = 0;
  ICMPv4Error packet = cast(ICMPv4Error)to!ICMPv4Error(json);
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "ICMP";
  json.packetType = 3;
  json.code = 2;
  json.checksum = 0;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  ICMPv4Error packet = cast(ICMPv4Error)to!ICMPv4Error(json);
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 0, 0, 0, 0];
  ICMPv4Error packet = cast(ICMPv4Error)encodedPacket.to!ICMPv4Error;
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest {
  Json json = Json.emptyObject;
  json.code = 2;
  json.checksum = 0;
  ICMPv4DestUnreach packet = cast(ICMPv4DestUnreach)to!ICMPv4DestUnreach(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "ICMP";
  json.code = 2;
  json.checksum = 0;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  ICMPv4DestUnreach packet = cast(ICMPv4DestUnreach)to!ICMPv4DestUnreach(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 0, 0, 0, 0];
  ICMPv4DestUnreach packet = cast(ICMPv4DestUnreach)encodedPacket.to!ICMPv4DestUnreach;
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest {
  Json json = Json.emptyObject;
  json.code = 2;
  json.checksum = 0;
  ICMPv4TimeExceed packet = cast(ICMPv4TimeExceed)to!ICMPv4TimeExceed(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "ICMP";
  json.code = 2;
  json.checksum = 0;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  ICMPv4TimeExceed packet = cast(ICMPv4TimeExceed)to!ICMPv4TimeExceed(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 0, 0, 0, 0];
  ICMPv4TimeExceed packet = cast(ICMPv4TimeExceed)encodedPacket.to!ICMPv4TimeExceed;
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest {
  Json json = Json.emptyObject;
  json.code = 2;
  json.checksum = 0;
  json.ptr = 1;
  ICMPv4ParamProblem packet = cast(ICMPv4ParamProblem)to!ICMPv4ParamProblem(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.ptr == 1);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "ICMP";
  json.code = 2;
  json.checksum = 0;
  json.ptr = 1;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  ICMPv4ParamProblem packet = cast(ICMPv4ParamProblem)to!ICMPv4ParamProblem(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.ptr == 1);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 1, 0, 0, 0];
  ICMPv4ParamProblem packet = cast(ICMPv4ParamProblem)encodedPacket.to!ICMPv4ParamProblem;
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.ptr == 1);
}

unittest {
  Json json = Json.emptyObject;
  json.code = 2;
  json.checksum = 0;
  ICMPv4SourceQuench packet = cast(ICMPv4SourceQuench)to!ICMPv4SourceQuench(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "ICMP";
  json.code = 2;
  json.checksum = 0;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  ICMPv4SourceQuench packet = cast(ICMPv4SourceQuench)to!ICMPv4SourceQuench(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 0, 0, 0, 0];
  ICMPv4SourceQuench packet = cast(ICMPv4SourceQuench)encodedPacket.to!ICMPv4SourceQuench;
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

unittest {
  Json json = Json.emptyObject;
  json.code = 2;
  json.checksum = 0;
  json.gateway = 42;
  ICMPv4Redirect packet = cast(ICMPv4Redirect)to!ICMPv4Redirect(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.gateway == 42);
}

unittest  {
  import netload.protocols.raw;

  Json json = Json.emptyObject;

  json.name = "ICMP";
  json.code = 2;
  json.checksum = 0;
  json.gateway = 42;

  json.data = Json.emptyObject;
  json.data.name = "Raw";
  json.data.bytes = serializeToJson([42,21,84]);

  ICMPv4Redirect packet = cast(ICMPv4Redirect)to!ICMPv4Redirect(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.gateway == 42);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 0, 0, 0, 42];
  ICMPv4Redirect packet = cast(ICMPv4Redirect)encodedPacket.to!ICMPv4Redirect;
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.gateway == 42);
}
