import std.stdio;
import netload.d;

void main()
{
	Sniffer sniffer = new Sniffer("enp0s25", &toEthernet);
	sniffer.sniff(delegate(Packet packet) {
		static uint nbr = 0;
		if (true) {
			log(packet);
			++nbr;
			if (nbr == 3) {
				showLoggedPackets();
				return false;
			} else
				return true;
		} else {
			return true;
		}
	});
}
