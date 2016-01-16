module netload.core.conversion.ubyte_conversion;

import std.conv;
import stdx.data.json;

JSONValue toJson(inout ubyte[] arg) {
	JSONValue[] ret = [];

	if (arg is null)
		return JSONValue(null);

	foreach(int i, ubyte b ; arg) {
		ret ~= JSONValue(b);
	}

	return JSONValue(ret);
}

ubyte[] toUbyteArray(inout JSONValue json) {
	ubyte[] ret = [];

	foreach (int i, JSONValue val ; json.to!(JSONValue[])) {
		ubyte c = val.to!ubyte;
		ret ~= c;
	}

	return ret;
}
