module netload.protocols.imap.imap;

import vibe.data.json;
import netload.core.protocol;

class IMAP : Protocol {
  public:
    this() {

    }

    this(string b) {
      _body = b;
    }

    override @property inout string name() { return "IMAP"; };
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
      IMAP packet = new IMAP("test");
      auto json = Json.emptyObject;
      json.body_ = "test";
      json.name = "IMAP";
      assert(packet.toJson == json);
    }

    override ubyte[] toBytes() const {
      return cast(ubyte[])(_body.dup);
    }

    unittest {
      IMAP packet = new IMAP("test");
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

Protocol toIMAP(Json json) {
  IMAP packet = new IMAP();
  packet.str = json.body_.to!string;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.body_ = "test";
  IMAP packet = cast(IMAP)toIMAP(json);
  assert(packet.str == "test");
}

Protocol toIMAP(ubyte[] encoded) {
  IMAP packet = new IMAP(cast(string)(encoded));
  return packet;
}

unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  IMAP packet = cast(IMAP)encoded.toIMAP();
  assert(packet.str == "test");
}
