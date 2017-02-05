# handle icmp connections
# This file is part of iptables-fsinf.
#
# iptables-fsinf is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# iptables-fsinf is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with iptables-fsinf.  If not, see <http://www.gnu.org/licenses/>.

icmp4_define() {
	if [ "$ENABLE_V4" = 'n' ]; then
		return
	fi
	echo '# set up ICMPv4 chain'

	# accept only ECHO und DESTINATION/NETWORK/HOST UNREACHABLE
	rule4 --new-chain ICMP
	rule4 -A ICMP -p icmp --icmp-type echo-reply -j ACCEPT
	rule4 -A ICMP -p icmp --icmp-type echo-request -j ACCEPT
	rule4 -A ICMP -p icmp --icmp-type destination-unreachable -j ACCEPT
	rule4 -A ICMP -j DROP
}

icmp4() {
    # add the ICMP chain to the INPUT chain
	rule4 -I INPUT -p icmp -j ICMP
}

icmp6_define() {
	if [ "$ENABLE_V6" = 'n' ]; then
		return
	fi
	echo '# set up ICMPv6 chain'
	rule6 --new-chain ICMP
	rule6 -A ICMP -p icmpv6 --icmpv6-type echo-reply -j ACCEPT
	rule6 -A ICMP -p icmpv6 --icmpv6-type echo-request -j ACCEPT
	rule6 -A ICMP -p icmpv6 --icmpv6-type destination-unreachable -j ACCEPT
	rule6 -A ICMP -p icmpv6 --icmpv6-type router-solicitation -j ACCEPT
	rule6 -A ICMP -p icmpv6 --icmpv6-type neighbour-advertisement -j ACCEPT
	rule6 -A ICMP -p icmpv6 --icmpv6-type neighbour-solicitation -j ACCEPT
	rule6 -A ICMP -p icmpv6 --icmpv6-type packet-too-big -j ACCEPT
	rule6 -A ICMP -p icmpv6 --icmpv6-type parameter-problem -j ACCEPT
	rule6 -A ICMP -j DROP
}

icmp6() {
    # add the ICMPv6 chain to the INPUT chain
	rule6 -I INPUT -p icmpv6 -j ICMP
}

icmp() {
	if [ "$ENABLE_ICMP" = 'n' ]; then
	    icmp4
	    icmp6
    fi
}
