module netload.protocols.ip.ip;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

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
      this() {

      }

      this(uint src, uint dest) {
        _srcIpAddress = src;
        _destIpAddress = dest;
      }

      override @property inout string name() { return "IP"; };
      override @property Protocol data() { return _data; }
      override @property void data(Protocol p) { _data = p; }
      override @property int osiLayer() const { return 3; }

      override Json toJson() const {
        Json json = Json.emptyObject;
        json.ip_version = ipVersion;
        json.ihl = ihl;
        json.tos = tos;
        json.header_length = length;
        json.id = id;
        json.offset = offset;
        json.reserved = reserved;
        json.df = df;
        json.mf = mf;
        json.ttl = ttl;
        json.protocol = protocol;
        json.checksum = checksum;
        json.src_ip_address = srcIpAddress;
        json.dest_ip_address = destIpAddress;
        return json;
      }

      unittest {
        IP packet = new IP();
        assert(packet.toJson.toString == `{"ihl":0,"checksum":0,"header_length":0,"src_ip_address":0,"ttl":0,"id":0,"ip_version":0,"reserved":false,"dest_ip_address":0,"df":false,"tos":0,"offset":0,"mf":false,"protocol":0}`);
      }

      override ubyte[] toBytes() const {
        ubyte[] encoded = new ubyte[20];
        encoded.write!ubyte(_versionAndLength.versionAndLength, 0);
        encoded.write!ubyte(tos, 1);
        encoded.write!ushort(length, 2);
        encoded.write!ushort(id, 4);
        encoded.write!ushort(_flagsAndOffset.flagsAndOffset, 6);
        encoded.write!ubyte(ttl, 8);
        encoded.write!ubyte(protocol, 9);
        encoded.write!ushort(checksum, 10);
        encoded.write!uint(srcIpAddress, 12);
        encoded.write!uint(destIpAddress, 16);
        return encoded;
      }

      unittest {
        IP packet = new IP();
        assert(packet.toBytes == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
      }

      override string toString() const { return toJson.toString; }

      unittest {
        IP packet = new IP();
        assert(packet.toString == `{"ihl":0,"checksum":0,"header_length":0,"src_ip_address":0,"ttl":0,"id":0,"ip_version":0,"reserved":false,"dest_ip_address":0,"df":false,"tos":0,"offset":0,"mf":false,"protocol":0}`);
      }

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
      @property uint srcIpAddress() const { return _srcIpAddress; }
      @property void srcIpAddress(uint address) { _srcIpAddress = address; }
      @property uint destIpAddress() const { return _destIpAddress; }
      @property void destIpAddress(uint address) { _destIpAddress = address; }

    private:
      Protocol _data;
      VersionAndLength _versionAndLength;
      ubyte _tos = 0;
      ushort _length = 0;
      ushort _id = 0;
      FlagsAndOffset _flagsAndOffset;
      ubyte _ttl = 0;
      ubyte _protocol = 0;
      ushort _checksum = 0;
      uint _srcIpAddress = 0;
      uint _destIpAddress = 0;
}

IP toIP(Json json) {
  IP packet = new IP();
  packet.ipVersion = json.ip_version.get!ubyte;
  packet.ihl = json.ihl.get!ubyte;
  packet.tos = json.tos.get!ubyte;
  packet.length = json.header_length.get!ushort;
  packet.id = json.id.get!ushort;
  packet.offset = json.offset.get!ushort;
  packet.reserved = json.reserved.get!bool;
  packet.df = json.df.get!bool;
  packet.mf = json.mf.get!bool;
  packet.ttl = json.ttl.get!ubyte;
  packet.protocol = json.protocol.get!ubyte;
  packet.checksum = json.checksum.get!ushort;
  packet.srcIpAddress = json.src_ip_address.get!uint;
  packet.destIpAddress = json.dest_ip_address.get!uint;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.ip_version = 0;
  json.ihl = 0;
  json.tos = 0;
  json.header_length = 0;
  json.id = 0;
  json.offset = 0;
  json.reserved = false;
  json.df = false;
  json.mf = false;
  json.ttl = 0;
  json.protocol = 0;
  json.checksum = 0;
  json.src_ip_address = 20;
  json.dest_ip_address = 0;
  IP packet = toIP(json);
  assert(packet.srcIpAddress == 20);
}

IP toIP(ubyte[] encoded) {
  IP packet = new IP();
  VersionAndLength vl;
  vl.versionAndLength = encoded.read!ubyte();
  packet.ipVersion = vl.ipVersion;
  packet.ihl = vl.ihl;
  packet.tos = encoded.read!ubyte();
  packet.length = encoded.read!ushort();
  packet.id = encoded.read!ushort();
  FlagsAndOffset fo;
  fo.flagsAndOffset = encoded.read!ushort();
  packet.offset = fo.offset;
  packet.reserved = fo.reserved;
  packet.df = fo.df;
  packet.mf = fo.mf;
  packet.ttl = encoded.read!ubyte();
  packet.protocol = encoded.read!ubyte();
  packet.checksum = encoded.read!ushort();
  packet.srcIpAddress = encoded.read!uint();
  packet.destIpAddress = encoded.read!uint();
  return packet;
}

unittest {
 ubyte[] encoded = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
 IP packet = encoded.toIP;
 assert(packet.destIpAddress == 1);
}
