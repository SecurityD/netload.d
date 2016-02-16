module netload.protocols.dot11.dot11;

import netload.core.addr;
import netload.core.protocol;
import netload.core.conversion.json_array;
import stdx.data.json;
import std.bitmanip;
import std.conv;
import std.outbuffer;
import std.range;
import std.array;

union Bitfields {
  ubyte[2] raw;
  mixin(bitfields!(
    ubyte, "subtype", 4,
    ubyte, "type", 2,
    ubyte, "vers", 2,
    bool, "rsvd", 1,
    bool, "wep", 1,
    bool, "moreData", 1,
    bool, "power", 1,
    bool, "retry", 1,
    bool, "moreFrag", 1,
    bool, "fromDS", 1,
    bool, "toDS", 1
    ));
};

enum Dot11Type {
  MANAGEMENT = 0,
  CONTROL = 1,
  DATA = 2
};

/++
 + IEEE 802.11 This protocol implements wireless local area
 + network (WLAN) computer communication.
 +/
class Dot11 : Protocol {
  public:
    static Dot11 opCall(inout JSONValue val) {
  		return new Dot11(val);
  	}

    this() {
      _frameControl.raw[0] = 0;
      _frameControl.raw[1] = 0;
    }

    this(ubyte type, ubyte subtype, ubyte[6] addr1, ubyte[6] addr2, ubyte[6] addr3, ubyte[6] addr4 = [0, 0, 0, 0, 0, 0]) {
      _frameControl.raw[0] = 0;
      _frameControl.raw[1] = 0;
      _frameControl.type = type;
      _frameControl.subtype = subtype;
      _addr[0] = addr1;
      _addr[1] = addr2;
      _addr[2] = addr3;
      _addr[3] = addr4;
    }

    this(JSONValue json) {
      this();
      subtype = json["subtype"].to!ubyte;
      type = json["packet_type"].to!ubyte;
      vers = json["vers"].to!ubyte;
      rsvd = json["rsvd"].to!bool;
      wep = json["wep"].to!bool;
      moreData = json["more_data"].to!bool;
      power = json["power"].to!bool;
      retry = json["retry"].to!bool;
      moreFrag = json["more_frag"].to!bool;
      fromDS = json["from_DS"].to!bool;
      toDS = json["to_DS"].to!bool;
      _duration = json["duration"].to!ushort;
      addr1 = stringToMac(json["addr1"].get!string);
      addr2 = stringToMac(json["addr2"].get!string);
      addr3 = stringToMac(json["addr3"].get!string);
      addr4 = stringToMac(json["addr4"].get!string);
      _seq = json["seq"].to!ushort;
      _fcs = json["fcs"].to!uint;
      if ("data" in json && json["data"] != null)
  			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
    }

    this(ubyte[] encodedPacket) {
      this();
      _frameControl.raw[0] = encodedPacket.read!ubyte();
      _frameControl.raw[1] = encodedPacket.read!ubyte();
      _duration = encodedPacket.read!ushort();
      ubyte[6][4] arr;
      for (ubyte i = 0; i < 4; i++) {
        for (ubyte j = 0; j < 6; j++) {
          arr[i][j] = encodedPacket.read!ubyte();
        }
      }
      addr1 = arr[0];
      addr2 = arr[1];
      addr3 = arr[2];
      addr4 = arr[3];
      _seq = encodedPacket.read!ushort();
      _fcs = encodedPacket.read!uint();
    }

    override @property Protocol data() { return _data; }
    override @property void data(Protocol p) { _data = p; }
    override @property int osiLayer() const { return 2; }
    override @property inout string name() { return "Dot11"; }

    override JSONValue toJson() const {
      JSONValue json = [
        "duration": JSONValue(_duration),
        "seq": JSONValue(_seq),
        "fcs": JSONValue(_fcs),
        "addr1": JSONValue(macToString(_addr[0])),
        "addr2": JSONValue(macToString(_addr[1])),
        "addr3": JSONValue(macToString(_addr[2])),
        "addr4": JSONValue(macToString(_addr[3])),
        "subtype": JSONValue(_frameControl.subtype),
        "packet_type": JSONValue(_frameControl.type),
        "vers": JSONValue(_frameControl.vers),
        "rsvd": JSONValue(_frameControl.rsvd),
        "wep": JSONValue(_frameControl.wep),
        "more_data": JSONValue(_frameControl.moreData),
        "power": JSONValue(_frameControl.power),
        "retry": JSONValue(_frameControl.retry),
        "more_frag": JSONValue(_frameControl.moreFrag),
        "from_DS": JSONValue(_frameControl.fromDS),
        "to_DS": JSONValue(_frameControl.toDS),
        "name": JSONValue(name)
      ];
      if (_data is null)
  			json["data"] = JSONValue(null);
  		else
  			json["data"] = _data.toJson;
  		return json;
    }

	///
    unittest {
      Dot11 packet = new Dot11(0, 8, [255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0], [1, 2, 3, 4, 5, 6]);
      assert(packet.toJson["packet_type"] == 0);
      assert(packet.toJson["subtype"] == 8);
      assert(packet.toJson["addr1"] == "ff:ff:ff:ff:ff:ff");
      assert(packet.toJson["addr2"] == "00:00:00:00:00:00");
      assert(packet.toJson["addr3"] == "01:02:03:04:05:06");
      assert(packet.toJson["addr4"] == "00:00:00:00:00:00");
      assert(packet.toJson["duration"] == 0);
      assert(packet.toJson["seq"] == 0);
      assert(packet.toJson["fcs"] == 0);
      assert(packet.toJson["vers"] == 0);
      assert(packet.toJson["rsvd"] == false);
      assert(packet.toJson["wep"] == false);
      assert(packet.toJson["more_data"] == false);
      assert(packet.toJson["power"] == false);
      assert(packet.toJson["retry"] == false);
      assert(packet.toJson["more_frag"] == false);
      assert(packet.toJson["from_DS"] == false);
      assert(packet.toJson["to_DS"] == false);
    }

	///
    unittest {
      import netload.protocols.udp;
      import netload.protocols.raw;
      Dot11 packet = new Dot11(0, 8, [255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0], [1, 2, 3, 4, 5, 6]);

      UDP udp = new UDP(8000, 7000);
      packet.data = udp;

      packet.data.data = new Raw([42, 21, 84]);

      JSONValue json = packet.toJson;
      assert(json["name"] == "Dot11");
      assert(json["packet_type"] == 0);
      assert(json["subtype"] == 8);
      assert(json["addr1"] == "ff:ff:ff:ff:ff:ff");
      assert(json["addr2"] == "00:00:00:00:00:00");
      assert(json["addr3"] == "01:02:03:04:05:06");
      assert(json["addr4"] == "00:00:00:00:00:00");
      assert(json["duration"] == 0);
      assert(json["seq"] == 0);
      assert(json["fcs"] == 0);
      assert(json["vers"] == 0);
      assert(json["rsvd"] == false);
      assert(json["wep"] == false);
      assert(json["more_data"] == false);
      assert(json["power"] == false);
      assert(json["retry"] == false);
      assert(json["more_frag"] == false);
      assert(json["from_DS"] == false);
      assert(json["to_DS"] == false);

      json = json["data"];
      assert(json["name"] == "UDP");
      assert(json["src_port"] == 8000);
      assert(json["dest_port"] == 7000);

      json = json["data"];
  		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
    }

    override ubyte[] toBytes() const {
      ubyte[] packet = new ubyte[30];
      packet.write!ubyte(_frameControl.raw[0], 0);
      packet.write!ubyte(_frameControl.raw[1], 1);
      packet.write!ushort(_duration, 2);
      for (ubyte i = 0; i < 4; i++) {
        for (ubyte j = 0; j < 6; j++) {
          packet.write!ubyte(_addr[i][j], 4 + i * 6 + j);
        }
      }
      packet.write!ushort(_seq, 28);
      if (_data !is null)
        packet ~= _data.toBytes;
      ubyte[] packetFcs = new ubyte[4];
      packetFcs.write!uint(_fcs, 0);
      packet ~= packetFcs;
      return packet;
    }

	///
    unittest {
      Dot11 packet = new Dot11(0, 8, [255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0], [1, 2, 3, 4, 5, 6]);
      assert(packet.toBytes == [8, 0, 0, 0, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    }

	///
    unittest {
      import netload.protocols.raw;

      Dot11 packet = new Dot11(0, 8, [255, 255, 255, 255, 255, 255], [0, 0, 0, 0, 0, 0], [1, 2, 3, 4, 5, 6]);

      packet.data = new Raw([42, 21, 84]);

      assert(packet.toBytes == [8, 0, 0, 0, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0, 0, 0, 0] ~ [42, 21, 84] ~ [0, 0, 0, 0]);
    }

    override string toIndentedString(uint idt = 0) const {
  		OutBuffer buf = new OutBuffer();
  		string indent = join(repeat("\t", idt));
  		buf.writef("%s%s%s%s\n", indent, PROTOCOL_NAME, name, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "duration", RESET_SEQ, FIELD_VALUE, _duration, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "seq", RESET_SEQ, FIELD_VALUE, _seq, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "fcs", RESET_SEQ, FIELD_VALUE, _fcs, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "addr1", RESET_SEQ, FIELD_VALUE, macToString(_addr[0]), RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "addr2", RESET_SEQ, FIELD_VALUE, macToString(_addr[1]), RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "addr3", RESET_SEQ, FIELD_VALUE, macToString(_addr[2]), RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "addr4", RESET_SEQ, FIELD_VALUE, macToString(_addr[3]), RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "subtype", RESET_SEQ, FIELD_VALUE, _frameControl.subtype, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "packet_type", RESET_SEQ, FIELD_VALUE, _frameControl.type, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "vers", RESET_SEQ, FIELD_VALUE, _frameControl.vers, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "rsvd", RESET_SEQ, FIELD_VALUE, _frameControl.rsvd, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "wep", RESET_SEQ, FIELD_VALUE, _frameControl.wep, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "more_data", RESET_SEQ, FIELD_VALUE, _frameControl.moreData, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "power", RESET_SEQ, FIELD_VALUE, _frameControl.power, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "retry", RESET_SEQ, FIELD_VALUE, _frameControl.retry, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "more_frag", RESET_SEQ, FIELD_VALUE, _frameControl.moreFrag, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "from_DS", RESET_SEQ, FIELD_VALUE, _frameControl.fromDS, RESET_SEQ);
      buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "to_DS", RESET_SEQ, FIELD_VALUE, _frameControl.toDS, RESET_SEQ);
      if (_data is null)
  			buf.writef("%s%s%s%s : %s%s%s\n", indent, FIELD_NAME, "data", RESET_SEQ, FIELD_VALUE, _data, RESET_SEQ);
  		else
  			buf.writef("%s", _data.toIndentedString(idt + 1));
      return buf.toString;
    }

    override string toString() const {
      return toIndentedString;
    }

	/++
	 + Duration ID : 3 different purposes :
	 +  - Virtual carrier-sense
	 +  - Legacy power management
	 +  - Contention-free period
	 + In case of virtual carrier-sense, it represents the time, in
	 + microseconds, required to transmit the SIFS interval + ACK frame.
	 +/
    @property ushort duration() const { return _duration; }
	///ditto
    @property void duration(ushort duration) { _duration = duration; }

	/++
	 + MAC Layer addressing : The 802.11 frame can carry 4 different MAC
	 + addresses with 5 different meanings :
	 +  - Source Address(SA) : MAC address of the original sending frame.
	 +    Source an either be wired or wireless
	 +  - Destination Address(DA) : Final destination of the frame. Could
	 +    be wired or wireless
	 +  - Transmitter address(TA) : MAC address of the 802.11 radio that
	 +    is transmitting the frame onto the 802.11 medium
	 +  - Receiver address(RA) : The MAC address of the 802.11 radio that
	 +    receives the incoming transmission from the transmitting station
	 +  - Basic service set ID (BSSID) :
	 +     - The MAC address that is the L2 identification of the BSS
	 +     - It could either be just the MAC address of the AP, or a dynamically
	 +       generated MAC address in the case where there are multiple BSSs
	 +       in an AP.
	 +
	 + Based on the TO_DS and FROM_DS fields, the meanings change
	 +/
    @property ubyte[6] addr1() const { return _addr[0]; }
	///ditto
    @property void addr1(ubyte[6] addr1) { _addr[0] = addr1; }
	///ditto
    @property ubyte[6] addr2() const { return _addr[1]; }
	///ditto
    @property void addr2(ubyte[6] addr2) { _addr[1] = addr2; }
	///ditto
    @property ubyte[6] addr3() const { return _addr[2]; }
	///ditto
    @property void addr3(ubyte[6] addr3) { _addr[2] = addr3; }
	///ditto
    @property ubyte[6] addr4() const { return _addr[3]; }
	///ditto
    @property void addr4(ubyte[6] addr4) { _addr[3] = addr4; }

	/++
	 + Sequence Control : The sequence number is constant in all tranmissions
	 + and re transmissions of a frame. Also it's constant in all fragments
	 + of a frame.
	 +/
    @property ushort seq() const { return _seq; }
	///ditto
    @property void seq(ushort seq) { _seq = seq; }

	/++
	 + FCS is calculated over all the fields of the MAC header and the frame
	 + body fields.
	 +/
    @property uint fcs() const { return _fcs; }
	///ditto
    @property void fcs(uint fcs) { _fcs = fcs; }

	/++
	 + Frame Subtype: Identifies the function of the frame with Frame Type(TYPE).
	 +/
    @property ubyte subtype() const { return _frameControl.subtype; }
	///ditto
    @property void subtype(ubyte subtype) { _frameControl.subtype = subtype; }

	/++
	 + Frame Type:
	 + - Data
	 + - Management
	 + - Control
	 +/
    @property ubyte type() const { return _frameControl.type; }
	///ditto
    @property void type(ubyte type) { _frameControl.type = type; }

	/++
	 + Protocol Version: Zero for 802.11 standard
	 +/
    @property ubyte vers() const { return _frameControl.vers; }
	///ditto
    @property void vers(ubyte vers) { _frameControl.vers = vers; }

	/++
	 + Order : Indicates restrictions for transmission.
	 +/
    @property bool rsvd() const { return _frameControl.rsvd; }
	///ditto
    @property void rsvd(bool rsvd) { _frameControl.rsvd = rsvd; }

	/++
	 + WEP : Indicates that WEP protection is activated.
	 +/
    @property bool wep() const { return _frameControl.wep; }
	///ditto
    @property void wep(bool wep) { _frameControl.wep = wep; }

	/++
	 + More Data :When the client receives a frame with the more
	 + data field when it's awake,it knows that it cannot go to
	 + sleep and it sends out a PS-POLL message for getting that
	 + data.
	 +/
    @property bool moreData() const { return _frameControl.moreData; }
	///ditto
    @property void moreData(bool moreData) { _frameControl.moreData = moreData; }

	/++
	 + Power Management : Set when station go Power Safe mode.
	 +/
    @property bool power() const { return _frameControl.power; }
	///ditto
    @property void power(bool power) { _frameControl.power = power; }

	/++
	 + Retry : Set in case of retransmission frame.
	 +/
    @property bool retry() const { return _frameControl.retry; }
	///ditto
    @property void retry(bool retry) { _frameControl.retry = retry; }

	/++
	 + More Frag : Set when frame is followed by other fragment.
	 + Present in data or management frame.
	 +/
    @property bool moreFrag() const { return _frameControl.moreFrag; }
	///ditto
    @property void moreFrag(bool moreFrag) { _frameControl.moreFrag = moreFrag; }

	/++
	 + FromDS : Indicates that frame is coming from Distribution System.
	 +/
    @property bool fromDS() const { return _frameControl.fromDS; }
	///ditto
    @property void fromDS(bool fromDS) { _frameControl.fromDS = fromDS; }

	/++
	 + ToDS : Indicates that destination frame is for Distribution System.
	 +/
    @property bool toDS() const { return _frameControl.toDS; }
	///ditto
    @property void toDS(bool toDS) { _frameControl.toDS = toDS; }

  private:
      Protocol _data = null;
      Bitfields _frameControl;
      ushort _duration = 0;
      ubyte[6][4] _addr = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
      ushort _seq = 0;
      uint _fcs = 0;
}

///
unittest {
  JSONValue json = [
    "subtype": JSONValue(8),
    "packet_type": JSONValue(0),
    "vers": JSONValue(0),
    "rsvd": JSONValue(0),
    "wep": JSONValue(0),
    "more_data": JSONValue(0),
    "power": JSONValue(0),
    "retry": JSONValue(0),
    "more_frag": JSONValue(0),
    "from_DS": JSONValue(0),
    "to_DS": JSONValue(0),
    "duration": JSONValue(0),
    "addr1": JSONValue(macToString([255, 255, 255, 255, 255, 255])),
    "addr2": JSONValue(macToString([0, 0, 0, 0, 0, 0])),
    "addr3": JSONValue(macToString([1, 2, 3, 4, 5, 6])),
    "addr4": JSONValue(macToString([0, 0, 0, 0, 0, 0])),
    "seq": JSONValue(0),
    "fcs": JSONValue(0)
  ];
  Dot11 packet = Dot11(json);
  assert(packet.type == 0);
  assert(packet.subtype == 8);
  assert(packet.addr1 == [255,255,255,255,255,255]);
  assert(packet.addr2 == [0,0,0,0,0,0]);
  assert(packet.addr3 == [1,2,3,4,5,6]);
  assert(packet.addr4 == [0,0,0,0,0,0]);
  assert(packet.duration == 0);
  assert(packet.seq == 0);
  assert(packet.fcs == 0);
  assert(packet.vers == 0);
  assert(packet.rsvd == 0);
  assert(packet.wep == 0);
  assert(packet.moreData == 0);
  assert(packet.power == 0);
  assert(packet.retry == 0);
  assert(packet.moreFrag == 0);
  assert(packet.fromDS == 0);
  assert(packet.toDS == 0);
}

///
unittest  {
  import netload.protocols.raw;

  JSONValue json = [
    "name": JSONValue("Dot11"),
    "subtype": JSONValue(8),
    "packet_type": JSONValue(0),
    "vers": JSONValue(0),
    "rsvd": JSONValue(0),
    "wep": JSONValue(0),
    "more_data": JSONValue(0),
    "power": JSONValue(0),
    "retry": JSONValue(0),
    "more_frag": JSONValue(0),
    "from_DS": JSONValue(0),
    "to_DS": JSONValue(0),
    "duration": JSONValue(0),
    "addr1": JSONValue(macToString([255, 255, 255, 255, 255, 255])),
    "addr2": JSONValue(macToString([0, 0, 0, 0, 0, 0])),
    "addr3": JSONValue(macToString([1, 2, 3, 4, 5, 6])),
    "addr4": JSONValue(macToString([0, 0, 0, 0, 0, 0])),
    "seq": JSONValue(0),
    "fcs": JSONValue(0)
  ];

  json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": ((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

  Dot11 packet = cast(Dot11)to!Dot11(json);
  assert(packet.type == 0);
  assert(packet.subtype == 8);
  assert(packet.addr1 == [255,255,255,255,255,255]);
  assert(packet.addr2 == [0,0,0,0,0,0]);
  assert(packet.addr3 == [1,2,3,4,5,6]);
  assert(packet.addr4 == [0,0,0,0,0,0]);
  assert(packet.duration == 0);
  assert(packet.seq == 0);
  assert(packet.fcs == 0);
  assert(packet.vers == 0);
  assert(packet.rsvd == 0);
  assert(packet.wep == 0);
  assert(packet.moreData == 0);
  assert(packet.power == 0);
  assert(packet.retry == 0);
  assert(packet.moreFrag == 0);
  assert(packet.fromDS == 0);
  assert(packet.toDS == 0);
  assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
  ubyte[] encodedPacket = [8, 0, 0, 0, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  Dot11 packet = cast(Dot11)encodedPacket.to!Dot11;
  assert(packet.type == 0);
  assert(packet.subtype == 8);
  assert(packet.addr1 == [255,255,255,255,255,255]);
  assert(packet.addr2 == [0,0,0,0,0,0]);
  assert(packet.addr3 == [1,2,3,4,5,6]);
  assert(packet.addr4 == [0,0,0,0,0,0]);
  assert(packet.duration == 0);
  assert(packet.seq == 0);
  assert(packet.fcs == 0);
  assert(packet.vers == 0);
  assert(packet.rsvd == 0);
  assert(packet.wep == 0);
  assert(packet.moreData == 0);
  assert(packet.power == 0);
  assert(packet.retry == 0);
  assert(packet.moreFrag == 0);
  assert(packet.fromDS == 0);
  assert(packet.toDS == 0);
}
