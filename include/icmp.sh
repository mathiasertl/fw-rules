# handle icmp connections
icmp4() {
	echo '# set up ICMPv4 chain'
	rule4 --new-chain ICMP

	# accept only ECHO und DESTINATION/NETWORK/HOST UNREACHABLE
	rule4 -A icmp -p ICMP --icmp-type echo-reply -j ACCEPT
	rule4 -A icmp -p ICMP --icmp-type echo-request -j ACCEPT
	rule4 -A icmp -p ICMP --icmp-type destination-unreachable -j ACCEPT
	rule4 -A icmp -j DROP

	# insert chain:
	rule4 -I INPUT -p icmp -j ICMP
}

icmp6() {
	echo '# set up ICMPv6 chain'
	rule6 --new-chain ICMP
	rule6 -I INPUT -p icmpv6 -j ICMP
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

icmp() {
	icmp4
	icmp6
}
