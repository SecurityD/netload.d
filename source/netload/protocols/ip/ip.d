module netload.protocols.ip.ip;

import netload.core.protocol;
import netload.core.addr;
import netload.protocols;
import netload.core.conversion.array_conversion;
import stdx.data.json;
import std.bitmanip;
import std.conv;

private Protocol delegate(ubyte[])[ubyte] ipType;

static this() {
  ipType[0x01] = delegate(ubyte[]encoded){ return cast(Protocol)to!ICMP(encoded); };
  ipType[0x06] = delegate(ubyte[]encoded){ return cast(Protocol)to!TCP(encoded); };
  ipType[0x11] = delegate(ubyte[]encoded){ return cast(Protocol)to!UDP(encoded); };
}

union VersionAndLength {
  mixin(bitfields!(
    ubyte, "ihl", 4,
    ubyte, "ipVersion", 4,
    ));
  ubyte versionAndLength;
}

union FlagsAndOffset {
  mixin(bitfields!(
    ushort, "offset", 13,
    bool, "reserved", 1,
    bool, "df", 1,
    bool, "mf", 1,
    ));
  ushort flagsAndOffset;
}

class IP : Protocol {
    public:
      static IP opCall(inout JSONValue val) {
    		return new IP(val);
    	}

      this() {

      }

      this(ubyte[4] src, ubyte[4] dest) {
        _srcIpAddress = src;
        _destIpAddress = dest;
      }

      this(JSONValue json) {
        _versionAndLength.ipVersion = json["ip_version"].to!ubyte;
        _versionAndLength.ihl = json["ihl"].to!ubyte;
        _tos = json["tos"].to!ubyte;
        _length = json["header_length"].to!ushort;
        _id = json["id"].to!ushort;
        _flagsAndOffset.offset = json["offset"].to!ushort;
        _flagsAndOffset.reserved = json["reserved"].to!bool;
        _flagsAndOffset.df = json["df"].to!bool;
        _flagsAndOffset.mf = json["mf"].to!bool;
        _ttl = json["ttl"].to!ubyte;
        _protocol = json["protocol"].to!ubyte;
        _checksum = json["checksum"].to!ushort;
        _srcIpAddress = stringToIp(json["src_ip_address"].get!string);
        _destIpAddress = stringToIp(json["dest_ip_address"].get!string);
        if ("data" in json && json["data"] != null)
    			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
      }

      this(ubyte[] encoded) {
        _versionAndLength.versionAndLength = encoded.read!ubyte();
        _tos = encoded.read!ubyte();
        _length = encoded.read!ushort();
        _id = encoded.read!ushort();
        _flagsAndOffset.flagsAndOffset = encoded.read!ushort();
        _ttl = encoded.read!ubyte();
        _protocol = encoded.read!ubyte();
        _checksum = encoded.read!ushort();
        _srcIpAddress = encoded[0..4];
        encoded.read!uint();
        _destIpAddress = encoded[0..4];
        encoded.read!uint();
        auto func = (_protocol in ipType);
        if (func !is null)
          _data = ipType[_protocol](encoded);
        else
          _data = to!Raw(encoded);
      }

      override @property inout string name() { return "IP"; };
      override @property Protocol data() { return _data; }
      override @property void data(Protocol p) { _data = p; }
      override @property int osiLayer() const { return 3; }

      override JSONValue toJson() const {
        JSONValue json = [
          "ip_version": JSONValue(ipVersion),
          "ihl": JSONValue(ihl),
          "tos": JSONValue(tos),
          "header_length": JSONValue(length),
          "id": JSONValue(id),
          "offset": JSONValue(offset),
          "reserved": JSONValue(reserved),
          "df": JSONValue(df),
          "mf": JSONValue(mf),
          "ttl": JSONValue(ttl),
          "protocol": JSONValue(protocol),
          "checksum": JSONValue(checksum),
          "src_ip_address": JSONValue(ipToString(srcIpAddress)),
          "dest_ip_address": JSONValue(ipToString(destIpAddress)),
          "name": JSONValue(name)
        ];
        if (_data is null)
    			json["data"] = JSONValue(null);
    		else
    			json["data"] = _data.toJson;
    		return json;
      }

      unittest {
        IP packet = new IP();
        packet.checksum = 42;
        assert(packet.toJson["checksum"].to!ushort == 42);
      }

      unittest {
        import netload.protocols.raw;

        IP packet = new IP();
        packet.checksum = 42;

        packet.data = new Raw([42, 21, 84]);

        JSONValue json = packet.toJson;
        assert(json["checksum"].to!ushort == 42);

        json = json["data"];
    		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
      }

      override ubyte[] toBytes() const {
        ubyte[] encoded = new ubyte[12];
        encoded.write!ubyte(_versionAndLength.versionAndLength, 0);
        encoded.write!ubyte(tos, 1);
        encoded.write!ushort(length, 2);
        encoded.write!ushort(id, 4);
        encoded.write!ushort(_flagsAndOffset.flagsAndOffset, 6);
        encoded.write!ubyte(ttl, 8);
        encoded.write!ubyte(protocol, 9);
        encoded.write!ushort(checksum, 10);
        encoded ~= srcIpAddress ~ destIpAddress;
        if (_data !is null)
          encoded ~= _data.toBytes;
        return encoded;
      }

      unittest {
        IP packet = new IP();
        assert(packet.toBytes == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
      }

      unittest {
        import netload.protocols.raw;

        IP packet = new IP();

        packet.data = new Raw([42, 21, 84]);

        assert(packet.toBytes == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ~ [42, 21, 84]);
      }

      override string toString() const { return toJson.toJSON; }

      @property ubyte ipVersion() const { return _versionAndLength.ipVersion; }
      @property void ipVersion(ubyte newVersion) { _versionAndLength.ipVersion = newVersion; }
      @property ubyte ihl() const { return _versionAndLength.ihl; }
      @property void ihl(ubyte newIhl) { _versionAndLength.ihl = newIhl; }
      @property ubyte tos() const { return _tos; }
      @property void tos(ubyte typeOfService) { _tos = typeOfService; }
      @property ushort length() const { return _length; }
      @property void length(ushort totalLength) { _length = totalLength; }
      @property ushort id() const { return _id; }
      @property void id(ushort newId) { _id = newId; }
      @property ushort offset() const { return _flagsAndOffset.offset; }
      @property void offset(ushort index) { _flagsAndOffset.offset = index; }
      @property bool reserved() const { return _flagsAndOffset.reserved; }
      @property void reserved(bool value) { _flagsAndOffset.reserved = value; }
      @property bool df() const { return _flagsAndOffset.df; }
      @property void df(bool value) { _flagsAndOffset.df = value; }
      @property bool mf() const { return _flagsAndOffset.mf; }
      @property void mf(bool value) { _flagsAndOffset.mf = value; }
      @property ubyte ttl() const { return _ttl; }
      @property void ttl(ubyte timeToLive) { _ttl = timeToLive; }
      @property ubyte protocol() const { return _protocol; }
      @property void protocol(ubyte proto) { _protocol = proto; }
      @property ushort checksum() const { return _checksum; }
      @property void checksum(ushort hash) { _checksum = hash; }
      @property ubyte[4] srcIpAddress() const { return _srcIpAddress; }
      @property void srcIpAddress(ubyte[4] address) { _srcIpAddress = address; }
      @property ubyte[4] destIpAddress() const { return _destIpAddress; }
      @property void destIpAddress(ubyte[4] address) { _destIpAddress = address; }

    private:
      Protocol _data = null;
      VersionAndLength _versionAndLength;
      ubyte _tos = 0;
      ushort _length = 0;
      ushort _id = 0;
      FlagsAndOffset _flagsAndOffset;
      ubyte _ttl = 0;
      ubyte _protocol = 0;
      ushort _checksum = 0;
      ubyte[4] _srcIpAddress = [0, 0, 0, 0];
      ubyte[4] _destIpAddress = [0, 0, 0, 0];
}

unittest {
  JSONValue json = [
    "ip_version": JSONValue(0),
    "ihl": JSONValue(0),
    "tos": JSONValue(0),
    "header_length": JSONValue(0),
    "id": JSONValue(0),
    "offset": JSONValue(0),
    "reserved": JSONValue(false),
    "df": JSONValue(false),
    "mf": JSONValue(true),
    "ttl": JSONValue(0),
    "protocol": JSONValue(0),
    "checksum": JSONValue(0),
    "src_ip_address": JSONValue(ipToString([127, 0, 0, 1])),
    "dest_ip_address": JSONValue(ipToString([0, 0, 0, 0]))
  ];
  IP packet = cast(IP)to!IP(json);
  assert(packet.srcIpAddress == [127, 0, 0, 1]);
  assert(packet.mf == true);
}

unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("IP"),
    "ip_version": JSONValue(0),
    "ihl": JSONValue(0),
    "tos": JSONValue(0),
    "header_length": JSONValue(0),
    "id": JSONValue(0),
    "offset": JSONValue(0),
    "reserved": JSONValue(false),
    "df": JSONValue(false),
    "mf": JSONValue(false),
    "ttl": JSONValue(0),
    "protocol": JSONValue(0),
    "checksum": JSONValue(0),
    "src_ip_address": JSONValue(ipToString([127, 0, 0, 1])),
    "dest_ip_address": JSONValue(ipToString([0, 0, 0, 0]))
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  IP packet = cast(IP)to!IP(json);
  assert(packet.srcIpAddress == [127, 0, 0, 1]);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

unittest {
 ubyte[] encoded = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
 IP packet = cast(IP)encoded.to!IP;
 assert(packet.destIpAddress == [0, 0, 0, 1]);
}

unittest {
  ubyte[] encoded = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0x06, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1] ~ [31, 64, 27, 88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0];
  IP packet = cast(IP)encoded.to!IP;
  assert(packet.destIpAddress == [0, 0, 0, 1]);
  assert((cast(TCP)packet.data).srcPort == 8000);
  assert((cast(TCP)packet.data).destPort == 7000);
  assert((cast(TCP)packet.data).window == 8192);
}
