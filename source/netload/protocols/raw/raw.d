module netload.protocols.raw.raw;

import netload.core.protocol;
import netload.core.conversion.json_array;
import stdx.data.json;
import std.outbuffer;
import std.range;
import std.array;
import std.conv;

/++
 + A raw data protocol.
 +/
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

	///
	unittest {
	  Raw packet = new Raw([0, 1, 2]);
    JSONValue json = packet.toJson();
    assert(json["bytes"] == [0, 1, 2]);
    assert(json["name"] == "Raw");
	}

	override ubyte[] toBytes() const { return _bytes.dup; }

  override string toIndentedString(uint idt = 0) const {
    OutBuffer buf = new OutBuffer();
		string indent = join(repeat("\t", idt));
		buf.writef("%s%s%s%s\n", indent, PROTOCOL_NAME, name, RESET_SEQ);
	  buf.writef("%s%s%s%s : %s%(\\x%02x %)%s", indent, FIELD_NAME, "bytes", RESET_SEQ, FIELD_VALUE, bytes, RESET_SEQ);
	  return buf.toString;
  }

	override string toString() const {
    return toIndentedString();
	}

	/++
	 + The data bytes.
	 +/
	@property const(ubyte[]) bytes() const { return _bytes; }
	///ditto
	@property void bytes(ubyte[] array) { _bytes = array; }
  static Raw opCall(inout JSONValue val) {
		return new Raw(val);
	}

  private:
	ubyte[] _bytes;
}

///
unittest {
  ubyte[] bytes = [0, 1, 2];
  JSONValue json = [
    "bytes": (bytes.toJsonArray)
  ];
  Raw packet = Raw(json);
  assert(packet.bytes == [0, 1, 2]);
}

///
unittest {
  ubyte[] encoded = [0, 1, 2];
  Raw packet = cast(Raw)encoded.to!Raw();
  assert(packet.bytes == [0, 1, 2]);
}
