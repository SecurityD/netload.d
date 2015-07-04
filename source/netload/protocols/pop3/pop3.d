module netload.protocols.pop3.pop3;

import vibe.data.json;
import netload.core.protocol;

class POP3 : Protocol {
  public:
    this() {

    }

    this(string b) {
      _body = b;
    }

    override @property inout string name() { return "POP3"; };
    @disable override @property Protocol data() { return null; }
    override @property void data(Protocol p) { }
    override @property int osiLayer() const { return 7; }

    override Json toJson() const {
      Json json = Json.emptyObject;
      json.body_ = _body;
      return json;
    }

    unittest {
      POP3 packet = new POP3("test");
      auto json = Json.emptyObject;
      json.body_ = "test";
      assert(packet.toJson == json);
    }

    override ubyte[] toBytes() const {
      return cast(ubyte[])(_body.dup);
    }

    unittest {
      POP3 packet = new POP3("test");
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

POP3 toPOP3(Json json) {
  POP3 packet = new POP3();
  packet.str = json.body_.to!string;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.body_ = "test";
  POP3 packet = toPOP3(json);
  assert(packet.str == "test");
}

POP3 toPOP3(ubyte[] encoded) {
  POP3 packet = new POP3(cast(string)(encoded));
  return packet;
}

unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  POP3 packet = encoded.toPOP3();
  assert(packet.str == "test");
}
