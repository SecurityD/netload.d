module netload.core.protocol;
import vibe.data.json;

interface Protocol {
  public:
    @property Protocol data();
    @property int layer() const;
    T layer(T)();
    @property immutable string name(); 
    Json toJson() const;
    ubyte[] toBytes() const;
    string toString() const;
}
