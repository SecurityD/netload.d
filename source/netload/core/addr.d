module netload.core.addr;

import std.string;
import std.conv;
import std.bitmanip;

/++
 + Converts an IPv4 address expressed in an array of four bytes
 + into a string with format XX.XX.XX.XX.
 +/
string ipToString(ubyte[4] ip) {
  return format("%s.%s.%s.%s", ip[0], ip[1], ip[2], ip[3]);
}

///
unittest {
  assert(ipToString([127, 0, 0, 1]) == "127.0.0.1");
}

/++
 + Converts an IPv4 address from a string with format XX.XX.XX.XX
 + into an array of four bytes.
 +/
ubyte[4] stringToIp(string ip) {
  string[] arr = ip.split(".");
  if (arr.length != 4)
    throw new Exception("Invalid IP address : " ~ ip);
  ubyte[4] result;
  ubyte i = 0;
  foreach(member; arr) {
    result[i] = member.to!ubyte;
    i++;
  }
  return (result);
}

///
unittest {
  assert(stringToIp("127.0.0.1") == [127, 0, 0, 1]);
}

/++
 + Converts a MAC address expressed in an array of six bytes
 + into a string with format XX:XX:XX:XX:XX:XX.
 +/
string macToString(ubyte[6] mac) {
  return format("%02x:%02x:%02x:%02x:%02x:%02x", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
}

///
unittest {
  assert(macToString([255, 255, 255, 255, 255, 255]) == "ff:ff:ff:ff:ff:ff");
}

/++
 + Converts a MAC address from a string with format XX:XX:XX:XX:XX:XX
 + into an array of six bytes.
 +/
ubyte[6] stringToMac(string mac) {
  string[] arr = mac.split(":");
  if (arr.length != 6)
    throw new Exception("Invalid MAC address : " ~ mac);
  ubyte[6] result;
  ubyte i = 0;
  foreach(member; arr) {
    result[i] = member.to!ubyte(16);
    i++;
  }
  return (result);
}

///
unittest {
  assert(stringToMac("ff:ff:ff:ff:ff:ff") == [255, 255, 255, 255, 255, 255]);
}
