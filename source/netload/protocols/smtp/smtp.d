module netload.protocols.smtp.smtp;

import std.conv;
import stdx.data.json;
import netload.core.protocol;
import netload.core.conversion.json_array;

class SMTP : Protocol {
  public:
    static SMTP opCall(inout JSONValue val) {
  		return new SMTP(val);
  	}

    this() {

    }

    this(string b) {
      _body = b;
    }

    this(JSONValue json) {
      _body = json["body_"].get!string;
    }

    this(ubyte[] encoded) {
      this(cast(string)(encoded));
    }

    override @property inout string name() { return "SMTP"; };
    override @property Protocol data() { return null; }
    override @property void data(Protocol p) { }
    override @property int osiLayer() const { return 7; }

    override JSONValue toJson() const {
      JSONValue json = [
        "body_": JSONValue(_body),
        "name": JSONValue(name)
      ];
      return json;
    }

    unittest {
      SMTP packet = new SMTP("test");
      JSONValue json = [
        "name": JSONValue("SMTP"),
        "body_": JSONValue("test")
      ];
      assert(packet.toJson == json);
    }

    override ubyte[] toBytes() const {
      return cast(ubyte[])(_body.dup);
    }

    unittest {
      SMTP packet = new SMTP("test");
      assert(packet.toBytes == cast(ubyte[])("test"));
    }

    override string toString() const { return toJson.toJSON; }

    @property string str() const { return _body; }
    @property void str(string b) { _body = b; }

  private:
    string _body;
}

unittest {
  JSONValue json = [
    "body_": JSONValue("test")
  ];
  SMTP packet = cast(SMTP)to!SMTP(json);
  assert(packet.str == "test");
}

unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  SMTP packet = cast(SMTP)encoded.to!SMTP();
  assert(packet.str == "test");
}
