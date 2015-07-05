import std.stdio;
import netload.d;

void main()
{
	PacketCapturer sniffer = new PacketCapturer("enp0s25");
	sniffer.initialize;
	ubyte[] packet = sniffer.nextPacket;
	writeln(packet);
	writeln(packet.toEthernet.toString);
}
