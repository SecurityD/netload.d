module netload.core.protocol;
import vibe.data.json;

interface Protocol {
  public:
    @property Protocol data();
    void prepare();
    Json toJson();
    ubyte[] toBytes();
    string toString();
}
