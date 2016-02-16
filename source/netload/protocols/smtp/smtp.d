module netload.protocols.smtp.smtp;

import std.conv;
import stdx.data.json;
import std.outbuffer;
import std.range;
import std.array;
import netload.core.protocol;
import netload.core.conversion.json_array;

/+
 + The objective of Simple Mail Transfer Protocol (SMTP) is to transfer
 + mail reliably and efficiently.
 +
 + SMTP is independent of the particular transmission subsystem and
 + requires only a reliable ordered data stream channel.  Appendices A,
 + B, C, and D describe the use of SMTP with various transport services.
 + A Glossary provides the definitions of terms as used in this
 + document.
 +
 + An important feature of SMTP is its capability to relay mail across
 + transport service environments.  A transport service provides an
 + interprocess communication environment (IPCE).  An IPCE may cover one
 + network, several networks, or a subset of a network.  It is important
 + to realize that transport systems (or IPCEs) are not one-to-one with
 + networks.  A process can communicate directly with another process
 + through any mutually known IPCE.  Mail is an application or use of
 + interprocess communication.  Mail can be communicated between
 + processes in different IPCEs by relaying through a process connected
 + to two (or more) IPCEs.  More specifically, mail can be relayed
 + between hosts on different transport systems by a host on both
 + transport systems.
 +/
class SMTP : Protocol {
  public:
    static SMTP opCall(inout JSONValue val) {
  		return new SMTP(val);
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

    override @property inout string name() { return "SMTP"; };
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
      SMTP packet = new SMTP("test");
      JSONValue json = [
        "name": JSONValue("SMTP"),
        "body_": JSONValue("test")
      ];
      assert(packet.toJson == json);
    }

    override ubyte[] toBytes() const {
      return cast(ubyte[])(_body.dup);
    }

	///
    unittest {
      SMTP packet = new SMTP("test");
      assert(packet.toBytes == cast(ubyte[])("test"));
    }

    override string toIndentedString(uint idt = 0) const {
  		OutBuffer buf = new OutBuffer();
  		string indent = join(repeat("\t", idt));
  		buf.writef("%s%s%s%s\n", indent, PROTOCOL_NAME, name, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "body_", RESET_SEQ, FIELD_VALUE, _body, RESET_SEQ);
      return buf.toString;
    }

    override string toString() const {
      return toIndentedString;
    }

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
  SMTP packet = cast(SMTP)to!SMTP(json);
  assert(packet.str == "test");
}

///
unittest {
  ubyte[] encoded = [116, 101, 115, 116];
  SMTP packet = cast(SMTP)encoded.to!SMTP();
  assert(packet.str == "test");
}
