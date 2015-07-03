module netload.protocols.smtp.smtp;

import vibe.data.json;
import netload.core.protocol;

class SMTP : Protocol {
  public:
    this() {

    }

    this(string b) {
      _body = b;
    }

    override @property inout string name() { return "SMTP"; };
    @disable override @property Protocol data() { return null; }
    override @property void data(Protocol p) { }
    override @property int osiLayer() const { return 7; }

    override Json toJson() const {
      Json json = Json.emptyObject;
      json.body_ = _body;
      json.name = name;
      return json;
    }

    unittest {
      SMTP packet = new SMTP("test");
      auto json = Json.emptyObject;
      json.name = "SMTP";
      json.body_ = "test";
      assert(packet.toJson == json);
    }

    override ubyte[] toBytes() const {
      return cast(ubyte[])(_body.dup);
    }

    unittest {
      SMTP packet = new SMTP("test");
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

Protocol toSMTP(Json json) {
  SMTP packet = new SMTP();
  packet.str = json.body_.to!string;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.body_ = "test";
  SMTP packet = cast(SMTP)toSMTP(json);
  assert(packet.str == "test");
}

Protocol toSMTP(ubyte[] encoded) {
  SMTP packet = new SMTP(cast(string)(encoded));
  return packet;
}

unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  SMTP packet = cast(SMTP)encoded.toSMTP();
  assert(packet.str == "test");
}
