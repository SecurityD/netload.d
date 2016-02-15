module netload.protocols.pop3.pop3;

import stdx.data.json;
import std.conv;
import netload.core.protocol;
import netload.core.conversion.json_array;

/++
 + On certain types of smaller nodes in the Internet it is often
 + impractical to maintain a message transport system (MTS).  For
 + example, a workstation may not have sufficient resources (cycles,
 + disk space) in order to permit a SMTP server [RFC821] and associated
 + local mail delivery system to be kept resident and continuously
 + running.  Similarly, it may be expensive (or impossible) to keep a
 + personal computer interconnected to an IP-style network for long
 + amounts of time (the node is lacking the resource known as
 + "connectivity").
 +
 + Despite this, it is often very useful to be able to manage mail on
 + these smaller nodes, and they often support a user agent (UA) to aid
 + the tasks of mail handling.  To solve this problem, a node which can
 + support an MTS entity offers a maildrop service to these less endowed
 + nodes.  The Post Office Protocol - Version 3 (POP3) is intended to
 + permit a workstation to dynamically access a maildrop on a server
 + host in a useful fashion.  Usually, this means that the POP3 protocol
 + is used to allow a workstation to retrieve mail that the server is
 + holding for it.
 + 
 + POP3 is not intended to provide extensive manipulation operations of
 + mail on the server; normally, mail is downloaded and then deleted.  A
 + more advanced (and complex) protocol, IMAP4, is discussed in
 + [RFC1730].
 +/
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

	///
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

	///
    unittest {
      POP3 packet = new POP3("test");
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
  POP3 packet = cast(POP3)to!POP3(json);
  assert(packet.str == "test");
}

///
unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  POP3 packet = cast(POP3)encoded.to!POP3();
  assert(packet.str == "test");
}
