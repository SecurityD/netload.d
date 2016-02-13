module netload.core.protocol;
import stdx.data.json;
import std.string;
import std.file;
import netload.protocols;

/++
 + Represents a packet's layer, such as TCP, Ethernet, ARP... All
 + supported protocols will implements this interface.
 +
 + It also contains a `data`, that is the next layer of the packet.
 + If it's `null`, it means that this is the last layer of the packet,
 + otherwise the layer on it's top is contained in the `data` field.
 + 
 + This also gives an helper to access to a layer, and one to add
 + a layer at the top of the packet.
 +
 + Examples:
 + ---
 + import netload.protocols;
 + 
 + UDP packet = new UDP(80, 80);
 + IP ip = new IP();
 + packet.data = ip;
 +
 + assert(packet.layer!(netload.protocols.udp.UDP)() is packet);
 + assert(packet.layer!(netload.protocols.ip.IP)() is ip);
 + ---
 + ---
 + import netload.protocols;
 +
 + auto packet = new IP;
 + packet
 +	   .add!TCP
 +	   .add!HTTP;
 + 
 + assert(packet.layer!HTTP);
 + ---
 +/
interface Protocol {
  public:
	/// The layer on top of this `Protocol`
    @property Protocol data();
	///ditto
    @property void data(Protocol p);

	/// The OSI model's layer numbre the protocol is on.
    @property int osiLayer() const;

	/// The name of the protocol.
    @property inout string name();

	/++
	 + A function that allows to access to a certain layer. It
	 + takes as template parameter the layer type and returns
	 + the first occurence of this type of protocol found.
	 +
	 + If there is no such layer in the packet, it throws an
	 + exception ("Layer doesn't exists").
	 +/
    final ProtocolType layer(ProtocolType : Protocol, this DerivedClass)() {
      if (name == typeid(ProtocolType).name.split(".")[$ - 1]) {
        return cast(ProtocolType)this;
      } else if (data is null) {
        throw new Exception("Layer doesn't exist");
      } else {
        return data.layer!ProtocolType;
      }
    }

	///
    unittest {
      netload.protocols.udp.UDP packet = new netload.protocols.udp.UDP(80, 80);
      netload.protocols.ip.IP ip = new netload.protocols.ip.IP();
      packet.data = ip;
      assert(packet.layer!(netload.protocols.udp.UDP)() is packet);
      assert(packet.layer!(netload.protocols.ip.IP)() is ip);
      try {
        packet.layer!(netload.protocols.tcp.TCP)();
        assert(false);
      } catch(Exception e) {
        assert(true);
      }
    }

	/++
	 + Adds a `Protocol` given as template parameter at the top 
	 + of the packet.
	 +/
    final ProtocolType add(ProtocolType : Protocol)() {
      if (data is null) {
        auto newLayer = new ProtocolType;
        data = newLayer;
        return newLayer;
      } else
        return data.add!ProtocolType;
    }

	///
    unittest {
      import netload.protocols;
      auto packet = new IP;
      packet
        .add!TCP
        .add!HTTP;
      assert(packet.layer!HTTP);
    }

    string toString() const;
    JSONValue toJson() const;
    ubyte[] toBytes() const;
}

/++
 + Writes a `Protocol` into a file. The file path must
 + be given as parameter.
 +/
void write(Protocol packet, string filename) {
  std.file.write(filename, packet.toJson.toJSON);
}

/++
 + Reads a `Protocol` from a file given as parameter.
 +/
Protocol read(string filename) {
  string data = cast(string)std.file.read(filename);
  JSONValue json = toJSONValue(data);
  return toProtocol(json);
}
