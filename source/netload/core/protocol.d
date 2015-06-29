module netload.core.protocol;
import vibe.data.json;
import std.string;

interface Protocol {
  public:
    @property Protocol data();
    @property void data(Protocol p);
    @property int osiLayer() const;
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
      std.stdio.writeln("1");
      assert(packet.layer!(netload.protocols.udp.UDP)() is packet);
      std.stdio.writeln("2");
      assert(packet.layer!(netload.protocols.ip.IP)() is ip);
      try {
        std.stdio.writeln("3");
        packet.layer!(netload.protocols.tcp.TCP)();
        assert(false);
      } catch(Exception e) {
        assert(true);
      }
    }

    @property inout string name();
    Json toJson() const;
    ubyte[] toBytes() const;
    string toString() const;
}
