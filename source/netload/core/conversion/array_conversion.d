module netload.core.conversion.json_array;

import std.conv;
import stdx.data.json;

/// Converts to JSON array the given array of type `T`.
JSONValue toJsonArray(T)(inout T[] arg) {
	JSONValue[] ret = [];

	if (arg is null)
		return JSONValue(null);

	foreach(int i, T b ; arg) {
		ret ~= JSONValue(b);
	}

	return JSONValue(ret);
}

/// Converts to array of `T` the given JSON array.
T[] toArrayOf(T)(inout JSONValue json) {
	T[] ret = [];

	foreach (int i, JSONValue val ; json.to!(JSONValue[])) {
		static if (is(T == string))
			T c = val.get!T;
		else
			T c = val.to!T;
		ret ~= c;
	}

	return ret;
}
