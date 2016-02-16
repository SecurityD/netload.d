module netload.core.logger;

import netload.core.packet;
import std.algorithm.mutation;
import std.stdio;

private Packet[] oldLoggedPackets = null;
private Packet[] loggedPackets = new Packet[10];
private uint packetNbr = 10;
private uint packetIdx = 0;

/++
 + Adds the given `Packet` to the logged packets working like a stack.
 +/
void log(Packet packet) {
  if (packetIdx == (packetNbr - 1)) {
    copy(loggedPackets[1..packetNbr], loggedPackets[0..(packetNbr - 1)]);
    loggedPackets[packetIdx] = packet;
  } else {
    loggedPackets[packetIdx] = packet;
    packetIdx += 1;
  }
}

/++
 + Changes the `loggedPackets` length by the given nbr.
 +/
void changeLoggedPacketNbr(uint nbr) {
  oldLoggedPackets = loggedPackets;
  loggedPackets = new Packet[nbr];
  if (packetNbr >= nbr) {
    if (packetIdx >= nbr) {
      loggedPackets[0..nbr] = oldLoggedPackets[(packetIdx - nbr + 1)..(packetIdx + 1)];
      packetIdx = nbr - 1;
    } else {
      loggedPackets[0..nbr] = oldLoggedPackets[0..nbr];
    }
  } else {
    loggedPackets[0..packetNbr] = oldLoggedPackets[0..packetNbr];
  }
  packetNbr = nbr;
  oldLoggedPackets = null;
}

///
unittest {
  import netload.protocols;
  log(new Packet(create!(TCP)()));
  log(new Packet(create!(TCP)));
  log(new Packet(create!(ARP)));
  log(new Packet(create!(IP)()));
  log(new Packet(create!(TCP)));
  log(new Packet(create!(ARP)));
  log(new Packet(create!(DHCP)()));
  log(new Packet(create!(TCP)));
  log(new Packet(create!(ARP)));
  log(new Packet(create!(Ethernet, IP)()));
  assert(loggedPackets[packetNbr - 1].data.layer!Ethernet);
  log(new Packet(create!(TCP)));
  assert(loggedPackets[packetNbr - 2].data.layer!Ethernet);
  changeLoggedPacketNbr(5);
  assert(packetNbr == 5);
  assert(loggedPackets[packetNbr - 2].data.layer!Ethernet);
  changeLoggedPacketNbr(10);
  log(new Packet(create!(TCP)));
  assert(loggedPackets[packetIdx - 1].data.layer!TCP);
  assert(packetIdx == 5);
}

/++
 + Prints `loggedPackets` to stdout.
 +/
void showLoggedPackets() {
  writeln("---- LOGGED PACKET ----");
  foreach(packet; loggedPackets) {
    if (packet !is null)
    writeln(packet);
  }
  writeln("-----------------------");
}
