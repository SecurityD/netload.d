module netload.protocols.pop3.pop3;

import stdx.data.json;
import std.conv;
import netload.core.protocol;
import netload.core.conversion.json_array;

class POP3 : Protocol {
  public:
    static POP3 opCall(inout JSONValue val) {
  		return new POP3(val);
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

    override @property inout string name() { return "POP3"; };
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
      POP3 packet = new POP3("test");
      JSONValue json = [
        "name": JSONValue("POP3"),
        "body_": JSONValue("test")
      ];
      assert(packet.toJson == json);
    }

    override ubyte[] toBytes() const {
      return cast(ubyte[])(_body.dup);
    }

    unittest {
      POP3 packet = new POP3("test");
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
  POP3 packet = cast(POP3)to!POP3(json);
  assert(packet.str == "test");
}

unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  POP3 packet = cast(POP3)encoded.to!POP3();
  assert(packet.str == "test");
}
