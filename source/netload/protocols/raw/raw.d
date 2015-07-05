module netload.protocols.raw.raw;

import vibe.data.json;
import netload.core.protocol;
import std.outbuffer;

class Raw : Protocol {
  public:
    this() {

    }

    this(ubyte[] array) {
      _bytes = array;
    }

    override @property inout string name() { return "Raw"; };
    @disable override @property Protocol data() { return null; }
    override @property void data(Protocol p) { }
    override @property int osiLayer() const { return 7; }

    override Json toJson() const {
      Json json = Json.emptyObject;
      json.bytes = serializeToJson(_bytes);
      json.name = name;
      return json;
    }

    unittest {
      Raw packet = new Raw([0, 1, 2]);
      assert(packet.toJson.toString == `{"name":"Raw","bytes":[0,1,2]}`);
    }

    override ubyte[] toBytes() const { return _bytes.dup; }

    override string toString() const {
      OutBuffer b = new OutBuffer();
      b.writef("%(\\x%02x %)", bytes);
      return b.toString;
    }

    unittest {
      Raw packet = new Raw([0, 1, 2]);
      assert(packet.toString == "\\x00 \\x01 \\x02");
    }

    @property const(ubyte[]) bytes() const { return _bytes; }
    @property void bytes(ubyte[] array) { _bytes = array; }
  private:
    ubyte[] _bytes;
}

Protocol toRaw(Json json) {
  Raw packet = new Raw();
  packet.bytes = deserializeJson!(ubyte[])(json.bytes);
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.bytes = serializeToJson([0, 1, 2]);
  Raw packet = cast(Raw)toRaw(json);
  assert(packet.bytes == [0, 1, 2]);
}

Protocol toRaw(ubyte[] encoded) {
  Raw packet = new Raw(encoded);
  packet.bytes = encoded;
  return packet;
}

unittest {
  ubyte[] encoded = [0, 1, 2];
  Raw packet = cast(Raw)encoded.toRaw();
  assert(packet.bytes == [0, 1, 2]);
}
