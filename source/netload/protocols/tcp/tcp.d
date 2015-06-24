module netload.protocols.tcp;

import netload.core.protocol;
import vibe.data.json;
import std.bitmanip;

union FlagsAndOffset {
  mixin(bitfields!(
    bool, "fin", 1,
    bool, "syn", 1,
    bool, "rst", 1,
    bool, "psh", 1,
    bool, "ack", 1,
    bool, "urg", 1,
    ubyte, "reserved", 6,
    ubyte, "offset", 4,
    ));
  ushort flagsAndOffset;
}

class TCP : Protocol {
  public:

    this() {

    }

    this(ushort sourcePort, ushort destinationPort) {
      _srcPort = sourcePort;
      _destPort = destinationPort;
    }

    @property Protocol data() {
      return _data;
    }

    void prepare() {

    }

    Json toJson() {
      Json json = Json.emptyObject;
      json.src_port = srcPort;
      json.dest_port = destPort;
      json.sequence_number = sequenceNumber;
      json.ack_number = ackNumber;
      json.fin = fin;
      json.syn = syn;
      json.rst = rst;
      json.psh = psh;
      json.ack = ack;
      json.urg = urg;
      json.reserved = reserved;
      json.offset = offset;
      json.window = window;
      json.checksum = checksum;
      json.urgent_ptr = urgPtr;
      return json;
    }

    unittest {
      TCP packet = new TCP(8000, 7000);
      assert(packet.toJson().src_port == 8000);
      assert(packet.toJson().dest_port == 7000);
    }

    ubyte[] toBytes() {
      ubyte[] packet = new ubyte[20];
      packet.write!ushort(srcPort, 0);
      packet.write!ushort(destPort, 2);
      packet.write!uint(sequenceNumber, 4);
      packet.write!uint(ackNumber, 8);
      packet.write!ushort(_flagsAndOffset.flagsAndOffset, 12);
      packet.write!ushort(window, 14);
      packet.write!ushort(checksum, 16);
      packet.write!ushort(urgPtr, 18);
      return packet;
    }

    unittest {
      import std.stdio;
      TCP packet = new TCP(8000, 7000);
      writeln(packet.toBytes);
    }

    override string toString() {
      return toJson().toString;
    }

    unittest {
      TCP packet = new TCP(8000, 7000);
      assert(packet.toString == `{"ack_number":0,"ack":false,"checksum":0,"psh":false,"syn":false,"urg":false,"rst":false,"sequence_number":0,"reserved":0,"dest_port":7000,"urgent_ptr":0,"src_port":8000,"fin":false,"offset":0,"window":8192}`);
    }

    @property ushort srcPort() { return _srcPort; }
    @property void srcPort(ushort port) { _srcPort = port; }
    @property ushort destPort() { return _destPort; }
    @property void destPort(ushort port) { _destPort = port; }
    @property uint sequenceNumber() { return _sequenceNumber; }
    @property void sequenceNumber(uint number) { _sequenceNumber = number; }
    @property uint ackNumber() { return _ackNumber; }
    @property void ackNumber(uint number) { _ackNumber = number; }

    @property bool fin() { return _flagsAndOffset.fin; }
    @property void fin(bool value) { _flagsAndOffset.fin = value; }
    @property bool syn() { return _flagsAndOffset.syn; }
    @property void syn(bool value) { _flagsAndOffset.syn = value; }
    @property bool rst() { return _flagsAndOffset.rst; }
    @property void rst(bool value) { _flagsAndOffset.rst = value; }
    @property bool psh() { return _flagsAndOffset.psh; }
    @property void psh(bool value) { _flagsAndOffset.psh = value; }
    @property bool ack() { return _flagsAndOffset.ack; }
    @property void ack(bool value) { _flagsAndOffset.ack = value; }
    @property bool urg() { return _flagsAndOffset.urg; }
    @property void urg(bool value) { _flagsAndOffset.urg = value; }
    @property ubyte reserved() { return _flagsAndOffset.reserved; }
    @property void reserved(ubyte value) { _flagsAndOffset.reserved = value; }
    @property ubyte offset() { return _flagsAndOffset.offset; }
    @property void offset(ubyte off) { _flagsAndOffset.offset = off; }

    @property ushort window() { return _window; }
    @property void window(ushort size) { _window = size; }
    @property ushort checksum() { return _checksum; }
    @property void checksum(ushort hash) { _checksum = hash; }
    @property ushort urgPtr() { return _urgPtr; }
    @property void urgPtr(ushort ptr) { _urgPtr = ptr; }

  private:
    Protocol _data;
    ushort _srcPort = 0;
    ushort _destPort = 0;
    uint _sequenceNumber = 0;
    uint _ackNumber = 0;
    FlagsAndOffset _flagsAndOffset;
    ushort _window = 8192;
    ushort _checksum = 0;
    ushort _urgPtr = 0;
}

TCP toTCP(ubyte[] encoded) {
  TCP packet = new TCP();
  packet.srcPort = encoded.read!ushort();
  packet.destPort = encoded.read!ushort();
  packet.sequenceNumber = encoded.read!uint();
  packet.ackNumber = encoded.read!uint();
  FlagsAndOffset fo;
  fo.flagsAndOffset = encoded.read!ushort();
  packet.fin = fo.fin;
  packet.syn = fo.syn;
  packet.rst = fo.rst;
  packet.psh = fo.psh;
  packet.ack = fo.ack;
  packet.urg = fo.urg;
  packet.reserved = fo.reserved;
  packet.offset = fo.offset;
  packet.window = encoded.read!ushort();
  packet.checksum = encoded.read!ushort();
  packet.urgPtr = encoded.read!ushort();
  return packet;
}

unittest {

}

TCP toTCP(Json json) {
  TCP packet = new TCP();
  packet.srcPort = json.src_port.get!ushort;
  packet.destPort = json.dest_port.get!ushort;
  packet.sequenceNumber = json.sequence_number.get!uint;
  packet.ackNumber = json.ack_number.get!uint;
  packet.fin = json.fin.get!bool;
  packet.syn = json.syn.get!bool;
  packet.rst = json.rst.get!bool;
  packet.psh = json.psh.get!bool;
  packet.ack = json.ack.get!bool;
  packet.urg = json.urg.get!bool;
  packet.reserved = json.reserved.get!ubyte;
  packet.offset = json.offset.get!ubyte;
  packet.window = json.window.get!ushort;
  packet.checksum = json.checksum.get!ushort;
  packet.urgPtr = json.urgent_ptr.get!ushort;
  return packet;
}

unittest {
  Json json = Json.emptyObject;
  json.src_port = 8000;
  json.dest_port = 7000;
  json.sequence_number = 0;
  json.ack_number = 0;
  json.fin = false;
  json.syn = true;
  json.rst = false;
  json.psh = false;
  json.ack = true;
  json.urg = false;
  json.reserved = 0;
  json.offset = 0;
  json.window = 0;
  json.checksum = 0;
  json.urgent_ptr = 0;
  TCP packet = toTCP(json);
  assert(packet.srcPort == json.src_port.get!ushort);
  assert(packet.destPort == json.dest_port.get!ushort);
}
