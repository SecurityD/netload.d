module netload.core.pcap.binding;

import core.stdc.config;
import core.stdc.stdlib;
import core.stdc.stdio;
import std.conv;

nothrow extern(C) {
  alias time_t = c_long;
  alias suseconds_t = c_long;

  struct timeval {
    time_t tv_sec;
    suseconds_t tv_usec;
  }
}

nothrow extern (C) {
  alias bpf_u_int32 = uint;
  enum PCAP_ERRBUF_SIZE = 256;
  enum swapped_type_t {
    NOT_SWAPPED,
    SWAPPED,
    MAYBE_SWAPPED
  };

  struct pcap_sf {
    FILE* rfile;
    int swapped;
    int hdrsize;
    swapped_type_t lengths_swapped;
    int version_major;
    int version_minor;
    ubyte* base;
  }

  struct pcap_md {
    int use_bpf;
    uint TotPkts;
    uint TotAccepted;
    uint TotDrops;
    int TotMissed;
    int OrigMissed;
    int* device;
    int timeout;
    int  must_clear;
    pcap* next;
  }

  struct bpf_insn {
    ushort code;
    ubyte jt;
    ubyte jf;
    bpf_u_int32 k;
  }

  struct bpf_program {
    uint bf_len;
    bpf_insn* bf_insns;
  }

  struct pcap_pkthdr {
    timeval ts;
    bpf_u_int32 caplen;
    bpf_u_int32 len;
  }

  struct pcap {
    int linktype;
    int linktype_ext;
    int tzoff;
    int offset;
    int activated;
    int oldstyle;
    int break_loop;
    pcap_pkthdr pcap_header;
  }

  struct pcap_t {
    int fd;
    int snapshot;
    int linktype;
    int tzoff;      /* timezone offset */
    int offset;     /* offset for proper alignment */
    pcap_sf sf;
    pcap_md md;
    /*
     * Read buffer.
     */
    int bufsize;
    ubyte *buffer;
    ubyte *bp;
    int cc;
    /*
     * Place holder for pcap_next().
     */
    ubyte *pkt;
    /*
     * Placeholder for filter code if bpf not in kernel.
     */
    bpf_program fcode;
    char[PCAP_ERRBUF_SIZE] errbuf;
  }

  char *pcap_lookupdev(char* errbuf);
  pcap_t *pcap_open_live(const char* device,
                          int snaplen,
                          bool isPromisc,
                          int to_ms,
                          char* errbuf);
  ubyte* pcap_next(pcap_t* p, pcap_pkthdr* h);

  int pcap_inject(pcap_t*, const ubyte*, size_t);

  void pcap_perror(pcap_t*, const char*);
  char* pcap_geterr(pcap_t*);
}

import std.string;

T[] toArrayOf(T)(T* ptr, uint size) {
  T[] array;
  for (uint i = 0; i < size; ++i) {
    array ~= ptr[i];
  }
  return array;
}

/++
 + The PacketCaptureException represents an exception caused by the (mis)use of
 + the libpcap library.
 +/
class PacketCaptureException : Exception {
  public:
    this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
      super(message, file, line, next);
    }
}

/++
 + The PacketCapturer class represents a device open for capturing.
 + Its construction shall fail if no device was found.
 +/
class PacketCapturer {
  public:
    /++
     + Constructs a PacketCapturer with the default capturing interface.
     +
     + Throws: PacketCaptureException if the default device is unavailable or non-existent.
     +/
    this() {
      lookupDevice();
    }

    /++
     + Constructs a PacketCapturer with the default capturing interface and promiscuous mode enabled if the argument is `true`.
     +/
    this(bool enablePromisc) {
      _promisc = enablePromisc;
      lookupDevice();
    }

    /++
     + Constructs a PacketCapturer with the interface named `deviceName` and promiscuous mode enabled if the second argument is `true`. Promiscuous mode defaults to `false`.
     +/
    this(string deviceName, bool enablePromisc = false) {
      _dev = deviceName;
      _promisc = enablePromisc;
    }

    /++
     + Opens the device for capture.
     +
     + Throws: PacketCaptureException on failure.
     +/
    void initialize() {
      _header = new pcap_pkthdr;
      _cap = pcap_open_live(_dev.toStringz, 1518, _promisc, 0, cast(char*)_errbuf);
      if (_cap == null) {
        throw new PacketCaptureException(cast(string)fromStringz(_errbuf.toStringz));
      }
    }

    /++
     + Obtains the next captured packet for this interface, using `pcap_next`. However the required copy of the
     + packet data is handled by this function. This function may block if no packet has been captured yet.
     +
     + Throws: PacketCaptureException on failure.
     +/
    ubyte[] nextPacket() {
      ubyte* bytes = pcap_next(_cap, _header);
      if (bytes is null) {
        throw new PacketCaptureException(cast(string)_cap.errbuf);
      }
      return bytes.toArrayOf(_header.caplen);
    }

    /++
     + Injects an arbitrary packet into the capture device.
     +
     + Throws: PacketCaptureException on failure.
     +/
    void inject(ubyte[] packet) {
      if (pcap_inject(_cap, packet.ptr, packet.length) == -1) {
        string error = to!string(pcap_geterr(_cap));
        throw new PacketCaptureException(error);
      }
    }

  private:
    void lookupDevice() {
      char* dev = pcap_lookupdev(null);
      if (dev == null) {
        throw new PacketCaptureException("Cannot find any device : " ~ (cast(string)fromStringz(cast(char *)_errbuf)));
      }
      _dev = cast(string)fromStringz(dev);
    }

    bool _promisc = false;
    string _dev;
    pcap_t *_cap;
    char[PCAP_ERRBUF_SIZE] _errbuf;
    pcap_pkthdr* _header;
}

unittest {
  PacketCapturer pc = new PacketCapturer();
  //                                                                   EtherType
  //                     <--source MAC-->  <--dest MAC---->  <802.1TAG>  <"">  <--payload--->  <-----CRC32---->
  ubyte[] etherPacket = [1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 7, 0, 0, 0, 0, 0, 8, 42, 42, 42, 42, 43, 145, 141, 23 ];
  pc.initialize;
  pc.inject(etherPacket);
  ubyte[] p1 = pc.nextPacket;
}
