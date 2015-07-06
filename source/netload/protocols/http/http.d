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
    override @property Protocol data() { return null; }
    override @property void data(Protocol p) { }
    override @property int osiLayer() const { return 7; }

    override Json toJson() const {
      Json json = Json.emptyObject;
      json.body_ = _body;
      json.name = name;
      return json;
    }

    unittest {
      HTTP packet = new HTTP("test");
      auto json = Json.emptyObject;
      json.body_ = "test";
      json.name = "HTTP";
      assert(packet.toJson == json);
    }

    override ubyte[] toBytes() const {
      return cast(ubyte[])(_body.dup);
    }

    unittest {
      HTTP packet = new HTTP("test");
      assert(packet.toBytes == cast(ubyte[])("test"));
    }

    override string toString() const { return toJson.toPrettyString; }

    @property string str() const { return _body; }
    @property void str(string b) { _body = b; }

  private:
    string _body;
}

Protocol toHTTP(Json json) {
  HTTP packet = new HTTP();
  packet.str = json.body_.to!string;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.body_ = "test";
  HTTP packet = cast(HTTP)toHTTP(json);
  assert(packet.str == "test");
}

Protocol toHTTP(ubyte[] encoded) {
  HTTP packet = new HTTP(cast(string)(encoded));
  return packet;
}

unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  HTTP packet = cast(HTTP)encoded.toHTTP();
  assert(packet.str == "test");
}
