module netload.protocols.http.http;

import vibe.data.json;
import netload.core.protocol;

class HTTP : Protocol {
  public:
    this() {

    }

    this(string b) {
      _body = b;
    }

    override @property inout string name() { return "HTTP"; };
    @disable override @property Protocol data() { return null; }
    override @property void data(Protocol p) { }
    override @property int osiLayer() const { return 7; }

    override Json toJson() const {
      Json json = Json.emptyObject;
      json.body_ = _body;
      return json;
    }

    unittest {
      HTTP packet = new HTTP("test");
      auto json = Json.emptyObject;
      json.body_ = "test";
      assert(packet.toJson == json);
    }

    override ubyte[] toBytes() const {
      return cast(ubyte[])(_body.dup);
    }

    unittest {
      HTTP packet = new HTTP("test");
      assert(packet.toBytes == cast(ubyte[])("test"));
    }

    override string toString() const {
      return toJson.toString;
    }

    @property string str() const { return _body; }
    @property void str(string b) { _body = b; }

  private:
    string _body;
}

HTTP toHTTP(Json json) {
  HTTP packet = new HTTP();
  packet.str = json.body_.to!string;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.body_ = "test";
  HTTP packet = toHTTP(json);
  assert(packet.str == "test");
}

HTTP toHTTP(ubyte[] encoded) {
  HTTP packet = new HTTP(cast(string)(encoded));
  return packet;
}

unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  HTTP packet = encoded.toHTTP();
  assert(packet.str == "test");
}
