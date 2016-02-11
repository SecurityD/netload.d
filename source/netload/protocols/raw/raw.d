module netload.protocols.raw.raw;

import netload.core.protocol;
import netload.core.conversion.array_conversion;
import stdx.data.json;
import std.outbuffer;
import std.conv;

class Raw : Protocol {
  public:
	this() {

	}

	this(ubyte[] array) {
	  _bytes = array;
	}

	this(JSONValue json) {
    _bytes = json["bytes"].toArrayOf!ubyte;
	}

	override @property inout string name() { return "Raw"; };
	override @property Protocol data() { return null; }
	override @property void data(Protocol p) { }
	override @property int osiLayer() const { return 7; }

	override JSONValue toJson() const {
	  JSONValue json = [
      "bytes" : (_bytes.toJsonArray),
      "name" : JSONValue(name)
    ];
    return json;
	}

	unittest {
	  Raw packet = new Raw([0, 1, 2]);
    JSONValue json = packet.toJson();
    assert(json["bytes"] == [0, 1, 2]);
    assert(json["name"] == "Raw");
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
  static Raw opCall(inout JSONValue val) {
		return new Raw(val);
	}

  private:
	ubyte[] _bytes;
}

unittest {
  ubyte[] bytes = [0, 1, 2];
  JSONValue json = [
    "bytes": (bytes.toJsonArray)
  ];
  Raw packet = Raw(json);
  assert(packet.bytes == [0, 1, 2]);
}

unittest {
  ubyte[] encoded = [0, 1, 2];
  Raw packet = cast(Raw)encoded.to!Raw();
  assert(packet.bytes == [0, 1, 2]);
}
