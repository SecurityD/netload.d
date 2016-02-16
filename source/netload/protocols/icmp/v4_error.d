module netload.protocols.icmp.v4_error;

import netload.core.protocol;
import netload.protocols.icmp.common;
import netload.protocols.ip;
import netload.core.conversion.json_array;
import stdx.data.json;
import std.bitmanip;
import std.conv;
import std.outbuffer;
import std.range;
import std.array;

alias ICMPv4Error = ICMPv4ErrorBase!(ICMPType.ANY);
alias ICMPv4DestUnreach = ICMPv4ErrorBase!(ICMPType.DEST_UNREACH);
alias ICMPv4TimeExceed = ICMPv4ErrorBase!(ICMPType.TIME_EXCEED);
alias ICMPv4SourceQuench = ICMPv4ErrorBase!(ICMPType.SOURCE_QUENCH);
alias ICMPv4Redirect = ICMPv4ErrorBase!(ICMPType.REDIRECT);
alias ICMPv4ParamProblem = ICMPv4ErrorBase!(ICMPType.PARAM_PROBLEM);

/++
 + Used to handle easily some defined ICMPv4 Error types
 +/
class ICMPv4ErrorBase(ICMPType __type__) : ICMPBase!(ICMPType.NONE) {
  public:
    static ICMPv4ErrorBase!(__type__) opCall(inout JSONValue val) {
  		return new ICMPv4ErrorBase!(__type__)(val);
  	}

    this(JSONValue json) {
      static if (__type__ == ICMPType.ANY)
        _type = json["packetType"].to!ubyte;
      else
        this();
      _code = json["code"].to!ubyte;
      _checksum = json["checksum"].to!ushort;
      static if (__type__ == ICMPType.PARAM_PROBLEM)
        _ptr = json["ptr"].to!ubyte;
      else static if (__type__ == ICMPType.REDIRECT)
        _gateway = json["gateway"].to!uint;
      if ("data" in json && json["data"] != null)
  			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
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

    override JSONValue toJson() const {
      JSONValue json = super.toJson;
      static if (__type__ == ICMPType.REDIRECT)
        json["gateway"] = JSONValue(_gateway);
      else static if (__type__ == ICMPType.PARAM_PROBLEM)
        json["ptr"] = JSONValue(_ptr);
      return json;
    }

    ///
    unittest {
      ICMPv4Redirect packet = new ICMPv4Redirect(2, 42, null);
      assert(packet.toJson["packetType"] == 5);
      assert(packet.toJson["code"] == 2);
      assert(packet.toJson["checksum"] == 0);
      assert(packet.toJson["gateway"] == 42);
    }

    ///
    unittest {
      import netload.protocols.raw;
      ICMPv4Redirect packet = new ICMPv4Redirect(2, 42, null);

      packet.data = new Raw([42, 21, 84]);

      JSONValue json = packet.toJson;
      assert(json["name"] == "ICMP");
      assert(json["packetType"] == 5);
      assert(json["code"] == 2);
      assert(json["checksum"] == 0);
      assert(json["gateway"] == 42);

      json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
    }

    ///
    unittest {
      ICMPv4ParamProblem packet = new ICMPv4ParamProblem(2, 1, null);
      assert(packet.toJson["packetType"] == 12);
      assert(packet.toJson["code"] == 2);
      assert(packet.toJson["checksum"] == 0);
      assert(packet.toJson["ptr"] == 1);
    }

    ///
    unittest {
      import netload.protocols.ethernet;
      import netload.protocols.raw;
      Ethernet packet = new Ethernet([255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0]);

      ICMPv4ParamProblem icmp = new ICMPv4ParamProblem(2, 1, null);
      packet.data = icmp;

      packet.data.data = new Raw([42, 21, 84]);

      JSONValue json = packet.toJson;
      assert(json["name"] == "Ethernet");
      assert(json["dest_mac_address"] == "00:00:00:00:00:00");
      assert(json["src_mac_address"] == "ff:ff:ff:ff:ff:ff");

      json = json["data"];
      assert(json["name"] == "ICMP");
      assert(json["packetType"] == 12);
      assert(json["code"] == 2);
      assert(json["checksum"] == 0);
      assert(json["ptr"] == 1);

      json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
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

    ///
    unittest {
      ICMPv4Error packet = new ICMPv4Error(3, 1, null);
      assert(packet.toBytes == [3, 1, 0, 0, 0, 0, 0, 0]);
    }

    ///
    unittest {
      import netload.protocols.raw;

      ICMPv4Error packet = new ICMPv4Error(3, 1, null);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [3, 1, 0, 0, 0, 0, 0, 0] ~ [42, 21, 84]);
    }

    ///
    unittest {
      ICMPv4Redirect packet = new ICMPv4Redirect(2, 42, null);
      assert(packet.toBytes == [5, 2, 0, 0, 0, 0, 0, 42]);
    }

    ///
    unittest {
      import netload.protocols.raw;

      ICMPv4Redirect packet = new ICMPv4Redirect(2, 42, null);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [5, 2, 0, 0, 0, 0, 0, 42] ~ [42, 21, 84]);
    }

    ///
    unittest {
      ICMPv4ParamProblem packet = new ICMPv4ParamProblem(2, 1, null);
      assert(packet.toBytes == [12, 2, 0, 0, 1, 0, 0, 0]);
    }

    ///
    unittest {
      import netload.protocols.raw;

      ICMPv4ParamProblem packet = new ICMPv4ParamProblem(2, 1, null);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [12, 2, 0, 0, 1, 0, 0, 0] ~ [42, 21, 84]);
    }

    override string toIndentedString(uint idt = 0) const {
  		OutBuffer buf = new OutBuffer();
  		string indent = join(repeat("\t", idt));
  		buf.writef("%s%s%s%s\n", indent, PROTOCOL_NAME, name, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "packetType", RESET_SEQ, FIELD_VALUE, _type, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "code", RESET_SEQ, FIELD_VALUE, _code, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "checksum", RESET_SEQ, FIELD_VALUE, _checksum, RESET_SEQ);
      static if (__type__ == ICMPType.REDIRECT)
        buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "gateway", RESET_SEQ, FIELD_VALUE, _gateway, RESET_SEQ);
      else static if (__type__ == ICMPType.PARAM_PROBLEM)
        buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "ptr", RESET_SEQ, FIELD_VALUE, _ptr, RESET_SEQ);
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
      /++
       + It indicates what problem happened.
       +/
      inout ubyte code() { return _code; }
      ///ditto
      void code(ubyte code) { _code = code; }
      static if (__type__ == ICMPType.ANY) {
        /++
         + Indicates the type of the packet.
         +/
        inout ubyte type() { return _type; }
        ///ditto
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

///
unittest {
  JSONValue json = [
    "packetType": JSONValue(3),
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];
  ICMPv4Error packet = cast(ICMPv4Error)to!ICMPv4Error(json);
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "packetType": JSONValue(3),
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4Error packet = cast(ICMPv4Error)to!ICMPv4Error(json);
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 0, 0, 0, 0];
  ICMPv4Error packet = cast(ICMPv4Error)encodedPacket.to!ICMPv4Error;
  assert(packet.type == 3);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

///
unittest {
  JSONValue json = [
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];
  ICMPv4DestUnreach packet = cast(ICMPv4DestUnreach)to!ICMPv4DestUnreach(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4DestUnreach packet = cast(ICMPv4DestUnreach)to!ICMPv4DestUnreach(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 0, 0, 0, 0];
  ICMPv4DestUnreach packet = cast(ICMPv4DestUnreach)encodedPacket.to!ICMPv4DestUnreach;
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

///
unittest {
  JSONValue json = [
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];
  ICMPv4TimeExceed packet = cast(ICMPv4TimeExceed)to!ICMPv4TimeExceed(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4TimeExceed packet = cast(ICMPv4TimeExceed)to!ICMPv4TimeExceed(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 0, 0, 0, 0];
  ICMPv4TimeExceed packet = cast(ICMPv4TimeExceed)encodedPacket.to!ICMPv4TimeExceed;
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

///
unittest {
  JSONValue json = [
    "code": JSONValue(2),
    "checksum": JSONValue(0),
    "ptr": JSONValue(1)
  ];
  ICMPv4ParamProblem packet = cast(ICMPv4ParamProblem)to!ICMPv4ParamProblem(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.ptr == 1);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "code": JSONValue(2),
    "checksum": JSONValue(0),
    "ptr": JSONValue(1)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4ParamProblem packet = cast(ICMPv4ParamProblem)to!ICMPv4ParamProblem(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.ptr == 1);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 1, 0, 0, 0];
  ICMPv4ParamProblem packet = cast(ICMPv4ParamProblem)encodedPacket.to!ICMPv4ParamProblem;
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.ptr == 1);
}

///
unittest {
  JSONValue json = [
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];
  ICMPv4SourceQuench packet = cast(ICMPv4SourceQuench)to!ICMPv4SourceQuench(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "code": JSONValue(2),
    "checksum": JSONValue(0)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4SourceQuench packet = cast(ICMPv4SourceQuench)to!ICMPv4SourceQuench(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 0, 0, 0, 0];
  ICMPv4SourceQuench packet = cast(ICMPv4SourceQuench)encodedPacket.to!ICMPv4SourceQuench;
  assert(packet.code == 2);
  assert(packet.checksum == 0);
}

///
unittest {
  JSONValue json = [
    "code": JSONValue(2),
    "checksum": JSONValue(0),
    "gateway": JSONValue(42)
  ];
  ICMPv4Redirect packet = cast(ICMPv4Redirect)to!ICMPv4Redirect(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.gateway == 42);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "code": JSONValue(2),
    "checksum": JSONValue(0),
    "gateway": JSONValue(42)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4Redirect packet = cast(ICMPv4Redirect)to!ICMPv4Redirect(json);
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.gateway == 42);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encodedPacket = [3, 2, 0, 0, 0, 0, 0, 42];
  ICMPv4Redirect packet = cast(ICMPv4Redirect)encodedPacket.to!ICMPv4Redirect;
  assert(packet.code == 2);
  assert(packet.checksum == 0);
  assert(packet.gateway == 42);
}
