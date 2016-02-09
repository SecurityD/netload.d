module netload.protocols.http.http;

import netload.core.protocol;
import stdx.data.json;
import std.conv;

class HTTP : Protocol {
  public:
    static HTTP opCall(inout JSONValue val) {
  		return new HTTP(val);
  	}

    this() {}

    this(string b) {
      _body = b;
    }

    this(JSONValue json) {
      _body = json["body_"].get!string;
    }

    this(ubyte[] encoded) {
      this(cast(string)(encoded));
    }

    override @property inout string name() { return "HTTP"; };
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
      HTTP packet = new HTTP("test");
      JSONValue json = [
        "body_": JSONValue("test"),
        "name": JSONValue("HTTP")
      ];
      assert(packet.toJson == json);
    }

    override ubyte[] toBytes() const {
      return cast(ubyte[])(_body.dup);
    }

    unittest {
      HTTP packet = new HTTP("test");
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
  HTTP packet = cast(HTTP)to!HTTP(json);
  assert(packet.str == "test");
}

unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  HTTP packet = cast(HTTP)encoded.to!HTTP();
  assert(packet.str == "test");
}
