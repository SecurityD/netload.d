module netload.protocols.ntp.common;

package(netload.protocols.ntp) abstract class NTPCommon {
public:
    @property {
		/++
		 + 32-bit code identifying the particular server or reference clock. 
		 + The interpretation depends on the value in the stratum field. For 
		 + packet stratum 0 (unspecified or invalid), this is a four-character 
		 + ASCII [RFC1345] string, called the "kiss code", used for debugging 
		 + and monitoring purposes. For stratum 1 (reference clock), this is 
		 + a four-octet, left-justified, zero-padded ASCII string assigned to 
		 + the reference clock. The authoritative list of Reference Identifiers 
		 + is maintained by IANA; however, any string beginning with the ASCII 
		 + character "X" is reserved for unregistered experimentation and development. 
		 + The identifiers have been used as ASCII identifiers:
		 + <table>
		 +   <tr><td><b>Value</b></td><td><b>Meaning</b></td></tr>
		 +   <tr><td>GOES</td><td>GOES satellite clock (468 HMz)</td></tr>
		 +   <tr><td>GPS</td><td>Global Position System</td></tr>
		 +   <tr><td>GAL</td><td>Galileo Positioning System</td></tr>
		 +   <tr><td>PPS</td><td>Generic pulse-per-second</td></tr>
		 +   <tr><td>IRIG</td><td>Inter-Range Instrumentation Group</td></tr>
		 +   <tr><td>WWVB</td><td>WWVB radio clock (60 KHz)</td></tr>
		 +   <tr><td>DCF</td><td>LF Radio DCF77 Mainflingen, DE 77.5 kHz</td></tr>
		 +   <tr><td>HBG</td><td>LF Radio HBG Prangins, HB 75 kHz</td></tr>
		 +   <tr><td>MSF</td><td>LF Radio MSF Anthorn, UK 60 kHz</td></tr>
		 +   <tr><td>JJY</td><td>LF Radio JJY Fukushima, JP 40 kHz, Saga, JP 60 kHz</td></tr>
		 +   <tr><td>LORC</td><td>MF Radio LORAN C station, 100 kHz</td></tr>
		 +   <tr><td>TDF</td><td>MF Radio Allouis, FR 162 kHz</td></tr>
		 +   <tr><td>CHU</td><td>HF Radio CHU Ottawa, Ontario</td></tr>
		 +   <tr><td>WWV</td><td>WWV radio clock (2.5/5/10/15/20 MHz)</td></tr>
		 +   <tr><td>WWVH</td><td>HF Radio WWVH Kauai, HI</td></tr>
		 +   <tr><td>NIST</td><td>NIST telephone modem</td></tr>
		 +   <tr><td>ACTS</td><td>ACTS telephone modem</td></tr>
		 +   <tr><td>USNO</td><td>USNO telephone modem</td></tr>
		 +   <tr><td>PTB</td><td>European telephone modem</td></tr>
		 + </table>
		 + Above stratum 1 (secondary servers and clients): this is the reference identifier 
		 + of the server and can be used to detect timing loops. If using the IPv4 address 
		 + family, the identifier is the four- octet IPv4 address. If using the IPv6 address 
		 + family, it is the first four octets of the MD5 hash of the IPv6 address. Note that, 
		 + when using the IPv6 address family on an NTPv4 server with a NTPv3 client, the 
		 + Reference Identifier field appears to be a random value and a timing loop might 
		 + not be detected.
		 +/
		inout uint referenceClockIdentifier() { return _referenceClockIdentifier; }
		///ditto
		void referenceClockIdentifier(uint data) { _referenceClockIdentifier = data; }

		/++
		 + Local time at which the local clock was last set or corrected.
		 +/
		inout ulong referenceTimestamp() { return _referenceTimestamp; }
		///ditto
		void referenceTimestamp(ulong data) { _referenceTimestamp = data; }

		/++
		 + Local time at which the request departed the client host for the 
		 + service host.
		 +/
		inout ulong originateTimestamp() { return _originateTimestamp; }
		///ditto
		void originateTimestamp(ulong data) { _originateTimestamp = data; }

		/++
		 + Local time at which the request arrived at the service host.
		 +/
		inout ulong receiveTimestamp() { return _receiveTimestamp; }
		///ditto
		void receiveTimestamp(ulong data) { _receiveTimestamp = data; }

		/++
		 + Local time at which the reply departed the service host for 
		 + the client host.
		 +/
		inout ulong transmitTimestamp() { return _transmitTimestamp; }
		///ditto
		void transmitTimestamp(ulong data) { _transmitTimestamp = data; }
    }

private:
    uint _referenceClockIdentifier;
    ulong _referenceTimestamp;
    ulong _originateTimestamp;
    ulong _receiveTimestamp;
    ulong _transmitTimestamp;
}
