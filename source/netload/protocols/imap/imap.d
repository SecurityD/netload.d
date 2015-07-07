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

    this(Json json) {
      _body = json.body_.to!string;
    }

    this(ubyte[] encoded) {
      this(cast(string)(encoded));
    }

    override @property inout string name() { return "IMAP"; };
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

    override string toString() const { return toJson.toPrettyString; }

    @property string str() const { return _body; }
    @property void str(string b) { _body = b; }

  private:
    string _body;
}

unittest {
  Json json = Json.emptyObject;
  json.body_ = "test";
  IMAP packet = cast(IMAP)to!IMAP(json);
  assert(packet.str == "test");
}

unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  IMAP packet = cast(IMAP)encoded.to!IMAP();
  assert(packet.str == "test");
}
