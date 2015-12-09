module netload.protocols.raw.raw;
//
//import vibe.data.json;
//import netload.core.protocol;
//import std.outbuffer;
//
//class Raw : Protocol {
//  public:
//    this() {
//
//    }
//
//    this(ubyte[] array) {
//      _bytes = array;
//    }
//
//    this(Json json) {
//      _bytes = deserializeJson!(ubyte[])(json.bytes);
//    }
//
//    override @property inout string name() { return "Raw"; };
//    override @property Protocol data() { return null; }
//    override @property void data(Protocol p) { }
//    override @property int osiLayer() const { return 7; }
//
//    override Json toJson() const {
//      Json json = Json.emptyObject;
//      json.bytes = serializeToJson(_bytes);
//      json.name = name;
//      return json;
//    }
//
//    unittest {
//      Raw packet = new Raw([0, 1, 2]);
//    }
//
//    override ubyte[] toBytes() const { return _bytes.dup; }
//
//    override string toString() const {
//      OutBuffer b = new OutBuffer();
//      b.writef("%(\\x%02x %)", bytes);
//      return b.toString;
//    }
//
//    unittest {
//      Raw packet = new Raw([0, 1, 2]);
//      assert(packet.toString == "\\x00 \\x01 \\x02");
//    }
//
//    @property const(ubyte[]) bytes() const { return _bytes; }
//    @property void bytes(ubyte[] array) { _bytes = array; }
//  private:
//    ubyte[] _bytes;
//}
//
//unittest {
//  Json json = Json.emptyObject;
//  json.bytes = serializeToJson([0, 1, 2]);
//  Raw packet = cast(Raw)to!Raw(json);
//  assert(packet.bytes == [0, 1, 2]);
//}
//
//unittest {
//  ubyte[] encoded = [0, 1, 2];
//  Raw packet = cast(Raw)encoded.to!Raw();
//  assert(packet.bytes == [0, 1, 2]);
//}
