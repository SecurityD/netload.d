module netload.protocols.arp.arp;

import netload.core.protocol;
import netload.core.conversion.json_array;
import std.conv;
import stdx.data.json;
import std.bitmanip;

/++
 + The Address Resolution Protocol (ARP) is a telecommunication protocol 
 + used for resolution of network layer addresses into link layer addresses, 
 + a critical function in multiple-access networks.
 +/
class ARP : Protocol {
public:
	static ARP opCall(inout JSONValue val) {
		return new ARP(val);
	}

	this() {}

	this(ushort hwType, ushort protocolType, ubyte hwAddrLen, ubyte protocolAddrLen, ushort opcode = 0) {
		_hwType = hwType;
		_protocolType = protocolType;
		_hwAddrLen = hwAddrLen;
		_protocolAddrLen = protocolAddrLen;
		_opcode = opcode;
		_senderHwAddr = new ubyte[_hwAddrLen];
		_targetHwAddr = new ubyte[_hwAddrLen];
		_senderProtocolAddr = new ubyte[_protocolAddrLen];
		_targetProtocolAddr = new ubyte[_protocolAddrLen];
	}

	this(JSONValue json) {
		this(json["hwType"].to!ushort, json["protocolType"].to!ushort, json["hwAddrLen"].to!ubyte, json["protocolAddrLen"].to!ubyte, json["opcode"].to!ushort);
		senderHwAddr = json["senderHwAddr"].toArrayOf!ubyte;
		targetHwAddr = json["targetHwAddr"].toArrayOf!ubyte;
		senderProtocolAddr = json["senderProtocolAddr"].toArrayOf!ubyte;
		targetProtocolAddr = json["targetProtocolAddr"].toArrayOf!ubyte;
		if ("data" in json && json["data"] != null)
			data = netload.protocols.conversion.protocolConversion[json["data"]["name"].get!string](json["data"]);
	}

	this(ubyte[] encoded) {
		this(encoded.read!ushort(), encoded.read!ushort(), encoded.read!ubyte(), encoded.read!ubyte(), encoded.read!ushort());
		ubyte pos1 = _hwAddrLen;
		ubyte pos2 = cast(ubyte)(pos1 + _protocolAddrLen);
		ubyte pos3 = cast(ubyte)(pos2 + _hwAddrLen);
		ubyte pos4 = cast(ubyte)(pos3 + _protocolAddrLen);
		_senderHwAddr[0..(_hwAddrLen)] = encoded[0..(pos1)];
		_senderProtocolAddr[0..(_protocolAddrLen)] = encoded[(pos1)..(pos2)];
		_targetHwAddr[0..(_hwAddrLen)] = encoded[(pos2)..(pos3)];
		_targetProtocolAddr[0..(_protocolAddrLen)] = encoded[(pos3)..(pos4)];
	}

	override @property Protocol data() { return _data; }
	override @property void data(Protocol p) { _data = p; }
	override @property inout string name() const { return "ARP"; }
	override @property int osiLayer() const { return 3; }

	override JSONValue toJson() const {
		JSONValue json = [
			"hwType": JSONValue(_hwType),
			"protocolType": JSONValue(_protocolType),
			"hwAddrLen": JSONValue(_hwAddrLen),
			"protocolAddrLen": JSONValue(_protocolAddrLen),
			"opcode": JSONValue(_opcode),
			"senderHwAddr": JSONValue(_senderHwAddr.toJsonArray),
			"targetHwAddr": JSONValue(_targetHwAddr.toJsonArray),
			"senderProtocolAddr": JSONValue(_senderProtocolAddr.toJsonArray),
			"targetProtocolAddr": JSONValue(_targetProtocolAddr.toJsonArray),
			"name": JSONValue(name)
		];
		if (_data is null)
			json["data"] = JSONValue(null);
		else
			json["data"] = _data.toJson;
		return json;
	}

	///
	unittest {
		ARP packet = new ARP(1, 1, 6, 4);
		packet.senderHwAddr = [128, 128, 128, 128, 128, 128];
		packet.targetHwAddr = [0, 0, 0, 0, 0, 0];
		packet.senderProtocolAddr = [127, 0, 0, 1];
		packet.targetProtocolAddr = [10, 14, 255, 255];

		assert(packet.toJson["hwType"].to!ushort == 1);
		assert(packet.toJson["protocolType"] == 1);
		assert(packet.toJson["hwAddrLen"] == 6);
		assert(packet.toJson["protocolAddrLen"] == 4);
		assert(packet.toJson["opcode"] == 0);
		assert(packet.toJson["senderHwAddr"].toArrayOf!ubyte == [128, 128, 128, 128, 128, 128]);
		assert(packet.toJson["targetHwAddr"].toArrayOf!ubyte == [0, 0, 0, 0, 0, 0]);
		assert(packet.toJson["senderProtocolAddr"].toArrayOf!ubyte == [127, 0, 0, 1]);
		assert(packet.toJson["targetProtocolAddr"].toArrayOf!ubyte == [10, 14, 255, 255]);
	}

	///
	unittest {
		import netload.protocols.raw;

		ARP packet = new ARP(1, 1, 6, 4);
		packet.senderHwAddr = [128, 128, 128, 128, 128, 128];
		packet.targetHwAddr = [0, 0, 0, 0, 0, 0];
		packet.senderProtocolAddr = [127, 0, 0, 1];
		packet.targetProtocolAddr = [10, 14, 255, 255];

		packet.data = new Raw([42, 21, 84]);

		JSONValue json = packet.toJson;
		assert(json["name"] == "ARP");
		assert(json["hwType"] == 1);
		assert(json["protocolType"] == 1);
		assert(json["hwAddrLen"] == 6);
		assert(json["protocolAddrLen"] == 4);
		assert(json["opcode"] == 0);
		assert(json["senderHwAddr"].toArrayOf!ubyte == [128, 128, 128, 128, 128, 128]);
		assert(json["targetHwAddr"].toArrayOf!ubyte == [0, 0, 0, 0, 0, 0]);
		assert(json["senderProtocolAddr"].toArrayOf!ubyte == [127, 0, 0, 1]);
		assert(json["targetProtocolAddr"].toArrayOf!ubyte == [10, 14, 255, 255]);

		json = json["data"];
		assert(json["bytes"].toArrayOf!ubyte == [42, 21, 84]);
	}

	override ubyte[] toBytes() const {
		ubyte[] packet = new ubyte[8];
		packet.write!ushort(_hwType, 0);
		packet.write!ushort(_protocolType, 2);
		packet.write!ubyte(_hwAddrLen, 4);
		packet.write!ubyte(_protocolAddrLen, 5);
		packet.write!ushort(_opcode, 6);
		packet ~= _senderHwAddr;
		packet ~= _senderProtocolAddr;
		packet ~= _targetHwAddr;
		packet ~= _targetProtocolAddr;
		if (_data !is null)
			packet ~= _data.toBytes;
		return packet;
	}

	///
	unittest {
		ARP packet = new ARP(1, 1, 6, 4);
		packet.senderHwAddr = [128, 128, 128, 128, 128, 128];
		packet.targetHwAddr = [0, 0, 0, 0, 0, 0];
		packet.senderProtocolAddr = [127, 0, 0, 1];
		packet.targetProtocolAddr = [10, 14, 255, 255];
		assert(packet.toBytes == [0, 1, 0, 1, 6, 4, 0, 0, 128, 128, 128, 128, 128, 128, 127, 0, 0, 1, 0, 0, 0, 0, 0, 0, 10, 14, 255, 255]);
	}

	///
	unittest {
		import netload.protocols.raw;

		ARP packet = new ARP(1, 1, 6, 4);
		packet.senderHwAddr = [128, 128, 128, 128, 128, 128];
		packet.targetHwAddr = [0, 0, 0, 0, 0, 0];
		packet.senderProtocolAddr = [127, 0, 0, 1];
		packet.targetProtocolAddr = [10, 14, 255, 255];

		packet.data = new Raw([42, 21, 84]);

		assert(packet.toBytes == [0, 1, 0, 1, 6, 4, 0, 0, 128, 128, 128, 128, 128, 128, 127, 0, 0, 1, 0, 0, 0, 0, 0, 0, 10, 14, 255, 255] ~ [42, 21, 84]);
	}

	override string toString() const { return toJson.toJSON; }

	/++
	 + This field specifies the type of hardware used for the local network 
	 + transmitting the ARP message; thus it also identifies the type of 
	 + addressing used.
	 +/
	@property ushort hwType() const { return _hwType; }
	///ditto
	@property void hwType(ushort hwType) { _hwType = hwType; }

	/++
	 + This field is the complement of the Hardware Type field, specifying 
	 + the type of layer three addresses used in the message.
	 +/
	@property ushort protocolType() const { return _protocolType; }
	///ditto
	@property void protocolType(ushort protocolType) { _protocolType = protocolType; }

	/++
	 + This field specifies how long hardware addresses are in this message.
	 +/
	@property ubyte hwAddrLen() const { return _hwAddrLen; }
	///ditto
	@property void hwAddrLen(ubyte hwAddrLen) { _hwAddrLen = hwAddrLen; }

	/++
	 + This fields is, again, the complement of the preceding field; it 
	 + specifies how long protocol (layer three) addresses are in this message.
	 +/
	@property ubyte protocolAddrLen() const { return _protocolAddrLen; }
	///ditto
	@property void protocolAddrLen(ubyte protocolAddrLen) { _protocolAddrLen = protocolAddrLen; }

	/++
	 + This field allows to know the function of the message and therefore its objective.
	 +
	 + <table style="width: 100%">
	 +   <tr><td><b>Opcode</b></td><td><b>ARP Message Type</b></td></tr>
	 +   <tr><td>1</td><td>ARP Request</td></tr>
	 +   <tr><td>2</td><td>ARP Reply</td></tr>
	 +   <tr><td>3</td><td>RARP Request</td></tr>
	 +   <tr><td>4</td><td>RARP Reply</td></tr>
	 +   <tr><td>5</td><td>DRARP Request</td></tr>
	 +   <tr><td>6</td><td>DRARP Reply</td></tr>
	 +   <tr><td>7</td><td>DRARP Error</td></tr>
	 +   <tr><td>8</td><td>InARP Request</td></tr>
	 +   <tr><td>9</td><td>InARP Reply</td></tr>
	 + </table>
	 +/
	@property ushort opcode() const { return _opcode; }
	///ditto
	@property void opcode(ushort opcode) { _opcode = opcode; }

	/++
	 + Size: variable (depending on the Hardware Address Length field)
	 + The hardware (layer two) address of the device sending this message.
	 +/
	@property const(ubyte[]) senderHwAddr() const { return _senderHwAddr; }
	///ditto
	@property void senderHwAddr(ubyte[] senderHwAddr) { _senderHwAddr = senderHwAddr; }

	/++
	 + Size: variable (depending on the Hardware Address Length field)
	 + The hardware (layer two) address of the device this message is being sent to.
	 +/
	@property const(ubyte[]) targetHwAddr() const { return _targetHwAddr; }
	///ditto
	@property void targetHwAddr(ubyte[] targetHwAddr) { _targetHwAddr = targetHwAddr; }

	/++
	 + Size: variable (depending on the Protocol Address Length field)
	 + The IP address of the device sending this message.
	 +/
	@property const(ubyte[]) senderProtocolAddr() const { return _senderProtocolAddr; }
	///ditto
	@property void senderProtocolAddr(ubyte[] senderProtocolAddr) { _senderProtocolAddr = senderProtocolAddr; }

	/++
	 + Size: variable (depending on the Protocol Address Length field)
	 + The IP address of the device this message is being sent to.
	 +/
	@property const(ubyte[]) targetProtocolAddr() const { return _targetProtocolAddr; }
	@property void targetProtocolAddr(ubyte[] targetProtocolAddr) { _targetProtocolAddr = targetProtocolAddr; }

private:
	Protocol _data = null;
	ushort _hwType = 0;
	ushort _protocolType = 0;
	ubyte _hwAddrLen = 0;
	ubyte _protocolAddrLen = 0;
	ushort _opcode = 0;
	ubyte[] _senderHwAddr;
	ubyte[] _senderProtocolAddr;
	ubyte[] _targetHwAddr;
	ubyte[] _targetProtocolAddr;
}

///
unittest {
	JSONValue json = [
		"hwType": JSONValue(1),
		"protocolType": JSONValue(1),
		"hwAddrLen": JSONValue(6),
		"protocolAddrLen": JSONValue(4),
		"opcode": JSONValue(0),
		"senderHwAddr": JSONValue((cast(ubyte[])([128, 128, 128, 128, 128, 128])).toJsonArray),
		"targetHwAddr": JSONValue((cast(ubyte[])([0, 0, 0, 0, 0, 0])).toJsonArray),
		"senderProtocolAddr": JSONValue((cast(ubyte[])([127, 0, 0, 1])).toJsonArray),
		"targetProtocolAddr": JSONValue((cast(ubyte[])([10, 14, 255, 255])).toJsonArray)
	];

	ARP packet = ARP(json);
	assert(packet.hwType == 1);
	assert(packet.protocolType == 1);
	assert(packet.hwAddrLen == 6);
	assert(packet.protocolAddrLen == 4);
	assert(packet.opcode == 0);
	assert(packet.senderHwAddr == [128, 128, 128, 128, 128, 128]);
	assert(packet.targetHwAddr == [0, 0, 0, 0, 0, 0]);
	assert(packet.senderProtocolAddr == [127, 0, 0, 1]);
	assert(packet.targetProtocolAddr == [10, 14, 255, 255]);
}

///
unittest  {
	import netload.protocols.raw;

	JSONValue json = [
		"name": JSONValue("ARP"),
		"hwType": JSONValue(1),
		"protocolType": JSONValue(1),
		"hwAddrLen": JSONValue(6),
		"protocolAddrLen": JSONValue(4),
		"opcode": JSONValue(0),
		"senderHwAddr": JSONValue((cast(ubyte[])([128, 128, 128, 128, 128, 128])).toJsonArray),
		"targetHwAddr": JSONValue((cast(ubyte[])([0, 0, 0, 0, 0, 0])).toJsonArray),
		"senderProtocolAddr": JSONValue((cast(ubyte[])([127, 0, 0, 1])).toJsonArray),
		"targetProtocolAddr": JSONValue((cast(ubyte[])([10, 14, 255, 255])).toJsonArray)
	];

	json["data"] = JSONValue([
		"name": JSONValue("Raw"),
		"bytes": JSONValue((cast(ubyte[])([42,21,84])).toJsonArray)
	]);

	ARP packet = ARP(json);
	assert(packet.senderHwAddr == [128, 128, 128, 128, 128, 128]);
	assert(packet.targetHwAddr == [0, 0, 0, 0, 0, 0]);
	assert(packet.senderProtocolAddr == [127, 0, 0, 1]);
	assert(packet.targetProtocolAddr == [10, 14, 255, 255]);
	assert((cast(Raw)packet.data).bytes == [42,21,84]);
}

///
unittest {
	ubyte[] encodedPacket = [0, 1, 0, 1, 6, 4, 0, 0, 128, 128, 128, 128, 128, 128, 127, 0, 0, 1, 0, 0, 0, 0, 0, 0, 10, 14, 255, 255];
	ARP packet = cast(ARP)encodedPacket.to!ARP;
	assert(packet.hwType == 1);
	assert(packet.protocolType == 1);
	assert(packet.hwAddrLen == 6);
	assert(packet.protocolAddrLen == 4);
	assert(packet.opcode == 0);
	assert(packet.senderHwAddr == [128, 128, 128, 128, 128, 128]);
	assert(packet.targetHwAddr == [0, 0, 0, 0, 0, 0]);
	assert(packet.senderProtocolAddr == [127, 0, 0, 1]);
	assert(packet.targetProtocolAddr == [10, 14, 255, 255]);
}
