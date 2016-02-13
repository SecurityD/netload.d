module netload.core.packet;

import netload.core;
import std.datetime;

/++
 + A wrapper for packets. Containts some metadata that could
 + be useful, like the packet creation time or an annotation.
 +
 + A `Packet` contains a `Protocol`, that is the first layer
 + of the packet. The contained `Protocol` then contains itself
 + the next packet layer and so on.
 +
 + This also define some tools to create the packet: you can
 + use the `create` templated function to create a full packet.
 +
 + Examples:
 + ---
 + import netload.core;
 + import netload.protocols;
 + 
 + // Creating the packet:
 + Packet packet = new Packet(create!(Ethernet, IP, TCP)());
 + packet.annotation = "A TCP/IP/Ethernet packet.";
 + 
 + // Accessing different layers to configure them:
 + packet.layer!TCP.srcPort = 80;
 + packet.layer!IP.srcIpAddress = stringToIp("127.0.0.1");
 + 
 + // Printing the result:
 + std.stdio.write(packet.toString);
 + ---
 +/
class Packet {
public:
	/++
	 + Create a `Packet` by specifying it's data.
	 +/
    this(Protocol packetData) {
      _time = Clock.currTime;
      _data = packetData;
    }

	/++
	 + Create a `Packet` by specifying it's data and it's
	 + creation time.
	 +/
    this(Protocol packetData, SysTime packetTime) {
      _data = packetData;
      _time = packetTime;
    }

	///
    override string toString() {
      string str = "--- Packet ---\n";
      str ~= "Time : " ~ _time.toString ~ "\n";
      str ~= "Annotation : " ~ _annotation ~ "\n";
      str ~= "[Data]" ~ "\n" ~ data.toString ~ "\n";
      str ~= "--------------\n";
      return str;
    }

	/// The packet data. Contains the first layer `Protocol`.
    @property Protocol data() { return _data; }

	/// The packet creation time.
    @property SysTime time() { return _time; }

	/// The packet annotation, that can be anything that helps
	/// to remember what the packet is about.
    @property string annotation() { return _annotation; }
	///ditto
    @property void annotation(string comment) { _annotation = comment; }

private:
    Protocol _data;
    SysTime _time;
    string _annotation;
}

///
unittest {
  Packet p = new Packet(new netload.protocols.raw.Raw());
  p.annotation = "malicious packet";
  assert(p.annotation == "malicious packet");
}

/++
 + A function template that eases the creation of packet.
 +
 + It takes as template parameters a succession of `Protocol`
 + representing the different packet's layers.
 +/
Protocol create()() {
  return null;
}

///ditto
FirstProtocol create(FirstProtocol : Protocol, OthersProtocol...)() {
  FirstProtocol header = new FirstProtocol;
  header.data = create!(OthersProtocol)();
  return header;
}

///
unittest {
  import netload.protocols;
  Ethernet packet = create!(Ethernet, IP, TCP)();
  packet.layer!TCP.srcPort = 80;
  assert(packet.layer!TCP.srcPort == 80);
}
