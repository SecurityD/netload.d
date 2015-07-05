module netload.core.logger;

import netload.core.packet;
import std.algorithm.mutation;
import std.stdio;

Packet[] oldLoggedPackets = null;
Packet[] loggedPackets = new Packet[10];
uint packetNbr = 0;

void log(Packet packet) {
  if (packetNbr == 10) {
    copy(loggedPackets[1..10], loggedPackets[0..9]);
    loggedPackets[9] = packet;
  } else {
    loggedPackets[packetNbr] = packet;
    packetNbr += 1;
  }
}

void changeLoggedPacketNbr(uint nbr) {
  oldLoggedPackets = loggedPackets;
  loggedPackets = new Packet[nbr];
  if (packetNbr >= nbr) {
    loggedPackets[0..nbr] = oldLoggedPackets[(packetNbr - nbr)..packetNbr];
    packetNbr = nbr;
  } else {
    loggedPackets[0..packetNbr] = oldLoggedPackets[0..packetNbr];
  }
}

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
  assert(loggedPackets[packetNbr - 1].data.layer!TCP);
  assert(packetNbr == 6);
}

void showLoggedPackets() {
  writeln("---- LOGGED PACKET ----");
  foreach(packet; loggedPackets) {
    if (packet !is null)
    writeln(packet);
  }
  writeln("-----------------------");
}
