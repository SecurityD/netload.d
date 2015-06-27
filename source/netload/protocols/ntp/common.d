module netload.protocols.ntp.common;

package(netload.protocols.ntp) abstract class NTPCommon {
  public:
    @property {
      inout uint referenceClockIdentifier() { return _referenceClockIdentifier; }
      void referenceClockIdentifier(uint data) { _referenceClockIdentifier = data; }

      inout ulong referenceTimestamp() { return _referenceTimestamp; }
      void referenceTimestamp(ulong data) { _referenceTimestamp = data; }

      inout ulong originateTimestamp() { return _originateTimestamp; }
      void originateTimestamp(ulong data) { _originateTimestamp = data; }

      inout ulong receiveTimestamp() { return _receiveTimestamp; }
      void receiveTimestamp(ulong data) { _receiveTimestamp = data; }

      inout ulong transmitTimestamp() { return _transmitTimestamp; }
      void transmitTimestamp(ulong data) { _transmitTimestamp = data; }
    }

  private:
    uint _referenceClockIdentifier;
    ulong _referenceTimestamp;
    ulong _originateTimestamp;
    ulong _receiveTimestamp;
    ulong _transmitTimestamp;
}
