module netload.core.protocol;
import vibe.data.json;

interface Protocol {
  public:
    @property Protocol data();
    void prepare();
    Json toJson();
    void fromJson(Json json);
    ubyte[] toBytes();
    void fromBytes(ubyte[]);
    string toString();
}
