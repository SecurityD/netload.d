module netload.protocols.http.http;

import netload.core.protocol;
import stdx.data.json;
import std.conv;

/++
 + The Hypertext Transfer Protocol (HTTP) is an application-level
 + protocol for distributed, collaborative, hypermedia information
 + systems. It is a generic, stateless, protocol which can be used for
 + many tasks beyond its use for hypertext, such as name servers and
 + distributed object management systems, through extension of its
 + request methods, error codes and headers. A feature of HTTP is
 + the typing and negotiation of data representation, allowing systems
 + to be built independently of the data being transferred.
 +/
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

	///
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

	///
    unittest {
      HTTP packet = new HTTP("test");
      assert(packet.toBytes == cast(ubyte[])("test"));
    }

    override string toString() const { return toJson.toJSON; }

	/++
	 + The body as plain text.
	 +/
    @property string str() const { return _body; }
	///ditto
    @property void str(string b) { _body = b; }

  private:
    string _body;
}

///
unittest {
  JSONValue json = [
    "body_": JSONValue("test")
  ];
  HTTP packet = cast(HTTP)to!HTTP(json);
  assert(packet.str == "test");
}

///
unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  HTTP packet = cast(HTTP)encoded.to!HTTP();
  assert(packet.str == "test");
}
