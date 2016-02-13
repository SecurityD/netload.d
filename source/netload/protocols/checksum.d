module netload.protocols.checksum;

private union UshortBytes {
  ubyte[2] raw;
  ushort value;
};

/++
 + Determines the checksum of a series of bytes.
 +/
ushort getChecksum(const ubyte[] data)
{
  UshortBytes converter;
  ulong checksum = 0;
  ulong length = data.length;
  uint i = 0;

  while(length > 1)
  {
    converter.raw = [data[i + 1], data[i]];
    checksum += converter.value;
    length -= ushort.sizeof;
    i += 2;
  }

  if(length)
    checksum += data[i];
  checksum = (checksum >> 16) + (checksum & 0xffff);
  checksum = checksum + (checksum >> 16);
  return cast(ushort)(~checksum);
}

///
unittest {
  ubyte[] arr = [153, 18, 8, 105, 171, 2, 14, 10, 0, 17, 0, 15, 0x04, 0x3f, 0, 13, 0, 15, 0, 0, 'T', 'E', 'S', 'T', 'I', 'N', 'G', 0];
  assert(getChecksum(arr) == 0b0110100100010100);
}

///
unittest {
  ubyte[] arr = [10, 14, 59, 244, 10, 14, 255, 255, 0, 17, 0, 52, 0xe1, 0x15, 0xe1, 0x15, 0x00, 0x34, 0x00, 0x00, 0x53, 0x70, 0x6f, 0x74, 0x55, 0x64, 0x70, 0x30, 0x73, 0xcd, 0x6f, 0xf0, 0xc3, 0x32, 0x0d, 0x3d, 0x00, 0x01, 0x00, 0x04, 0x48, 0x95, 0xc2, 0x03, 0x7d, 0xfd, 0x25, 0xcf, 0x08, 0x73, 0xdb, 0x72, 0x3e, 0x6e, 0x5c, 0xc1, 0x3f, 0xc4, 0x56, 0x18, 0x28, 0xc3, 0x45, 0x00];
  assert(getChecksum(arr) == 0x7f83);
}
