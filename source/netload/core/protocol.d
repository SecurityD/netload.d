module netload.core.protocol;
import stdx.data.json;
import std.string;
import std.file;
import netload.protocols;

interface Protocol {
  public:
    @property Protocol data();
    @property void data(Protocol p);
    final ProtocolType add(ProtocolType : Protocol)() {
      if (data is null) {
        auto newLayer = new ProtocolType;
        data = newLayer;
        return newLayer;
      } else
        return data.add!ProtocolType;
    }

	//unittest {
	//  import netload.protocols;
	//  auto packet = new IP;
	//  packet
	//    .add!TCP
	//    .add!HTTP;
	//  assert(packet.layer!HTTP);
	//}

    @property inout string name();
	//JSONValue toJson() const;
    ubyte[] toBytes() const;
}

//void write(Protocol packet, string filename) {
//  std.file.write(filename, packet.toJson.toString);
//}
//
//Protocol read(string filename) {
//  string data = cast(string)std.file.read(filename);
//  Json json = parseJsonString(data);
//  return toProtocol(json);
//}
