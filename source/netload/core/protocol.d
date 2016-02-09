module netload.core.protocol;
import stdx.data.json;
import std.string;
import std.file;
import netload.protocols;

interface Protocol {
  public:
    @property Protocol data();
    @property void data(Protocol p);
    @property int osiLayer() const;
    @property inout string name();

    final ProtocolType layer(ProtocolType : Protocol, this DerivedClass)() {
      if (name == typeid(ProtocolType).name.split(".")[$ - 1]) {
        return cast(ProtocolType)this;
      } else if (data is null) {
        throw new Exception("Layer doesn't exist");
      } else {
        return data.layer!ProtocolType;
      }
    }


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

    final ProtocolType add(ProtocolType : Protocol)() {
      if (data is null) {
        auto newLayer = new ProtocolType;
        data = newLayer;
        return newLayer;
      } else
        return data.add!ProtocolType;
    }

    unittest {
      import netload.protocols;
      auto packet = new IP;
      packet
        .add!TCP
        .add!HTTP;
      assert(packet.layer!HTTP);
    }

    JSONValue toJson() const;
    ubyte[] toBytes() const;
}

void write(Protocol packet, string filename) {
  std.file.write(filename, packet.toJson.toJSON);
}

Protocol read(string filename) {
  string data = cast(string)std.file.read(filename);
  JSONValue json = toJSONValue(data);
  return toProtocol(json);
}
