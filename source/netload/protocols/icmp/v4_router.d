module netload.protocols.icmp.v4_router;

import netload.core.protocol;
import netload.core.addr;
import netload.protocols.icmp.common;
import netload.core.conversion.json_array;
import stdx.data.json;
import std.bitmanip;
import std.conv;

alias ICMPv4RouterAdvert = ICMPv4Router!(ICMPType.ADVERT);
alias ICMPv4RouterSollicitation = ICMPv4Router!(ICMPType.SOLLICITATION);

/++
 + In case of an error, it indicates what problem happened.
 +/
class ICMPv4Router(ICMPType __type__) : ICMPBase!(ICMPType.NONE) {
  public:
    static ICMPv4Router!(__type__) opCall(inout JSONValue val) {
  		return new ICMPv4Router!(__type__)(val);
  	}

    static if (__type__ == ICMPType.SOLLICITATION) {
      this() {
        super(10, 0);
      }

      this(JSONValue json) {
        this();
        checksum = json["checksum"].to!ushort;
        if ("data" in json && json["data"] != null)
    			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
      }

      this(ubyte[] encodedPacket) {
        encodedPacket.read!ushort();
        checksum = encodedPacket.read!ushort();
      }
    }
    else static if (__type__ == ICMPType.ADVERT) {
      this() {
        super(9, 0);
        _routerAddr = new ubyte[4][_numAddr];
        _prefAddr = new ubyte[4][_numAddr];
      }

      this(ubyte numAddr, ushort life = 0) {
        super(9, 0);
        _numAddr = numAddr;
        _life = life;
        _routerAddr = new ubyte[4][_numAddr];
        _prefAddr = new ubyte[4][_numAddr];
      }

      this(JSONValue json) {
        this(json["numAddr"].to!ubyte, json["addrEntrySize"].to!ubyte);
        checksum = json["checksum"].to!ushort;
        life = json["life"].to!ushort;
        string[] buf;
        uint i = 0;
        buf = json["routerAddr"].toArrayOf!string;
        foreach(member; buf) {
          _routerAddr[i] = stringToIp(member);
          i++;
        }
        i = 0;
        buf = json["prefAddr"].toArrayOf!string;
        foreach(member; buf) {
          _prefAddr[i] = stringToIp(member);
          i++;
        }
        if ("data" in json && json["data"] != null)
    			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
      }

      this(ubyte[] encodedPacket) {
        encodedPacket.read!ushort();
        checksum = encodedPacket.read!ushort();
        ubyte numAddr = encodedPacket.read!ubyte();
        ubyte addrEntrySize = encodedPacket.read!ubyte();
        life = encodedPacket.read!ushort();
        this(numAddr, addrEntrySize);
        for (ubyte i = 0; i < numAddr; i++) {
          routerAddr[i] = encodedPacket[(0 + i * 8)..(4 + i * 8)];
          prefAddr[i] = encodedPacket[(4 + i * 8)..(8 + i * 8)];
        }
      }
    }

    override JSONValue toJson() const {
      JSONValue packet = super.toJson();
      packet["numAddr"] = JSONValue(_numAddr);
      packet["addrEntrySize"] = JSONValue(_addrEntrySize);
      packet["life"] = JSONValue(_life);
      string[] buf = [];
      foreach(member; _routerAddr) {
        buf ~= ipToString(member);
      }
      packet["routerAddr"] = buf.toJsonArray;
      buf = [];
      foreach(member; _prefAddr) {
        buf ~= ipToString(member);
      }
      packet["prefAddr"] = buf.toJsonArray;
      return packet;
    }

    ///
    unittest {
      ICMPv4RouterAdvert packet = new ICMPv4RouterAdvert(3, 2);
      assert(packet.toJson["packetType"] == 9);
      assert(packet.toJson["code"] == 0);
      assert(packet.toJson["checksum"] == 0);
      assert(packet.toJson["numAddr"] == 3);
      assert(packet.toJson["addrEntrySize"] == 2);
      assert(packet.toJson["life"] == 2);
      assert(packet.toJson["routerAddr"].toArrayOf!string == ["0.0.0.0", "0.0.0.0", "0.0.0.0"]);
      assert(packet.toJson["prefAddr"].toArrayOf!string == ["0.0.0.0", "0.0.0.0", "0.0.0.0"]);
    }

    ///
    unittest {
      import netload.protocols.raw;
      ICMPv4RouterAdvert packet = new ICMPv4RouterAdvert(3, 2);

      packet.data = new Raw([42, 21, 84]);

      JSONValue json = packet.toJson;
      assert(json["name"] == "ICMP");
      assert(json["packetType"] == 9);
      assert(json["code"] == 0);
      assert(json["checksum"] == 0);
      assert(json["numAddr"] == 3);
      assert(json["addrEntrySize"] == 2);
      assert(json["life"] == 2);
      assert(json["routerAddr"] == ["0.0.0.0", "0.0.0.0", "0.0.0.0"]);
      assert(json["prefAddr"] == ["0.0.0.0", "0.0.0.0", "0.0.0.0"]);

      json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[8];
      packet.write!ubyte(_type, 0);
      packet.write!ubyte(_code, 1);
      packet.write!ushort(_checksum, 2);
      static if (__type__ == ICMPType.ADVERT) {
        packet.write!ubyte(_numAddr, 4);
        packet.write!ubyte(_addrEntrySize, 5);
        packet.write!ushort(_life, 6);
        for (ubyte i = 0; i < _numAddr; i++) {
          packet ~= _routerAddr[i] ~ _prefAddr[i];
        }
      }
      if (_data !is null)
        packet ~= _data.toBytes;
      return packet;
    }

    ///
    unittest {
      ICMPv4RouterAdvert packet = new ICMPv4RouterAdvert(3, 2);
      assert(packet.toBytes == [9, 0, 0, 0, 3, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    }

    ///
    unittest {
      import netload.protocols.raw;

      ICMPv4RouterAdvert packet = new ICMPv4RouterAdvert(3, 2);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [9, 0, 0, 0, 3, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ~ [42, 21, 84]);
    }

    ///
    unittest {
      ICMPv4RouterSollicitation packet = new ICMPv4RouterSollicitation();
      assert(packet.toBytes == [10, 0, 0, 0, 0, 0, 0, 0]);
    }

    ///
    unittest {
      import netload.protocols.raw;

      ICMPv4RouterSollicitation packet = new ICMPv4RouterSollicitation();

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [10, 0, 0, 0, 0, 0, 0, 0] ~ [42, 21, 84]);
    }

    @property {
      /++
       + The number of router addresses advertised in this message.
       +/
      inout ubyte numAddr() { return _numAddr; }
      ///ditto
      void numAddr(ubyte numAddr) { _numAddr = numAddr; }
      /++
       + The number of 32-bit words of information per each router address
       + (2, in the version of the protocol described here).
       +/
      inout ubyte addrEntrySize() { return _addrEntrySize; }
      ///ditto
      void addrEntrySize(ubyte addrEntrySize) { _addrEntrySize = addrEntrySize; }
      /++
       + The maximum number of seconds that the router addresses may be
       + considered valid.
       +/
      inout ushort life() { return _life; }
      ///ditto
      void life(ushort life) { _life = life; }
      /++
       + The sending router's IP address(es) on the interface
       + from which this message is sent.
       +/
      ubyte[4][] routerAddr() { return _routerAddr; }
      ///ditto
      void routerAddr(ubyte[4][] routerAddr) { _routerAddr = routerAddr; }
      /++
       + The preferability of each Router Address[i] as a default router
       + address, relative to other router addresses on the same subnet.
       + A signed, twos-complement value; higher values mean more preferable.
       +/
      ubyte[4][] prefAddr() { return _prefAddr; }
      ///ditto
      void prefAddr(ubyte[4][] prefAddr) { _prefAddr = prefAddr; }
    }

  private:
    ubyte _numAddr = 0;
    ubyte _addrEntrySize = 2;
    ushort _life = 0;
    ubyte[4][] _routerAddr;
    ubyte[4][] _prefAddr;
}

///
unittest {
  JSONValue json = [
    "checksum": JSONValue(0),
    "numAddr": JSONValue(3),
    "addrEntrySize": JSONValue(2),
    "life": JSONValue(1),
    "routerAddr": ["1.1.1.1", "2.2.2.2", "3.3.3.3"].toJsonArray,
    "prefAddr": ["1.1.1.1", "2.2.2.2", "3.3.3.3"].toJsonArray
  ];
  ICMPv4RouterAdvert packet = cast(ICMPv4RouterAdvert)to!ICMPv4RouterAdvert(json);
  assert(packet.checksum == 0);
  assert(packet.life == 1);
  assert(packet.numAddr == 3);
  assert(packet.addrEntrySize == 2);
  assert(packet.routerAddr == [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
  assert(packet.prefAddr == [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "checksum": JSONValue(0),
    "numAddr": JSONValue(3),
    "addrEntrySize": JSONValue(2),
    "life": JSONValue(1),
    "routerAddr": ["1.1.1.1", "2.2.2.2", "3.3.3.3"].toJsonArray,
    "prefAddr": ["1.1.1.1", "2.2.2.2", "3.3.3.3"].toJsonArray
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": JSONValue((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4RouterAdvert packet = cast(ICMPv4RouterAdvert)to!ICMPv4RouterAdvert(json);
  assert(packet.checksum == 0);
  assert(packet.life == 1);
  assert(packet.numAddr == 3);
  assert(packet.addrEntrySize == 2);
  assert(packet.routerAddr == [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
  assert(packet.prefAddr == [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encodedPacket = [9, 0, 0, 0, 3, 2, 0, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3];
  ICMPv4RouterAdvert packet = cast(ICMPv4RouterAdvert)encodedPacket.to!ICMPv4RouterAdvert;
  assert(packet.checksum == 0);
  assert(packet.numAddr == 3);
  assert(packet.addrEntrySize == 2);
  assert(packet.life == 2);
  assert(packet.routerAddr == [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
  assert(packet.prefAddr == [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]]);
}

///
unittest {
  JSONValue json = [
    "checksum": JSONValue(0)
  ];
  ICMPv4RouterSollicitation packet = cast(ICMPv4RouterSollicitation)to!ICMPv4RouterSollicitation(json);
  assert(packet.checksum == 0);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("ICMP"),
    "checksum": JSONValue(0)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": JSONValue((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  ICMPv4RouterSollicitation packet = cast(ICMPv4RouterSollicitation)to!ICMPv4RouterSollicitation(json);
  assert(packet.checksum == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encodedPacket = [10, 0, 0, 0, 0, 0, 0, 0];
  ICMPv4RouterSollicitation packet = cast(ICMPv4RouterSollicitation)encodedPacket.to!ICMPv4RouterSollicitation;
  assert(packet.checksum == 0);
}
