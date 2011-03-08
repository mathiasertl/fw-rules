# Accept all connections in case of an error
reset() {
	echo "Reset chains to safe default state!"
	set -x
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD DROP
	iptables -F
	iptables -X
	
	ip6tables -P INPUT ACCEPT
	ip6tables -P OUTPUT ACCEPT
	ip6tables -P FORWARD DROP
	ip6tables -F
	ip6tables -X
}

# a rule just for IPv4
rule4() {
	if [ "$ENABLE_V4" != 'n' ]; then
		echo iptables ${@}
	fi

	if [ "${?}" -ne 0 ]; then
		reset
		exit 1
	fi
}

# a rule just for IPv6
rule6() {
	if [ "$ENABLE_V6" != 'n' ]; then
		echo ip6tables ${@}
	fi

	if [ "${?}" -ne 0 ]; then
		reset
		exit 1
	fi
}

# create a rule for IPv4 and IPv6
rule() {
	rule4 ${@}
	rule6 ${@}
}

# cleanup IPv4 (e.g. on error)
cleanup4() {
	echo '# cleanup IPv4'
	rule4 -F
	rule4 -X
}

# cleanup IPv6 (e.g. on error)
cleanup6() {
	echo '# cleanup IPv6'
	rule6 -F
	rule6 -X
}

# cleanup IPv4 and IPv6 (e.g. on error)
cleanup() {
	cleanup4
	cleanup6
}

# set initial policies on IPv4
init4() {
	cleanup4

	echo '# Initialize IPv4'
	rule4 -P INPUT DROP
	rule4 -P FORWARD DROP
	rule4 -P OUTPUT ACCEPT

	# accept established connections right away:
	rule4 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	# accept anything from local
	rule4 -A INPUT -s 127.0.0.1 -i lo -j ACCEPT
}

# set initial policies on IPv6
init6() {
	cleanup6

	echo '# initialize IPv6'
	rule6 -P INPUT DROP
	rule6 -P FORWARD DROP
	rule6 -P OUTPUT ACCEPT
	
	# accept established connections right away:
	rule6 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	# accept anything from local
	rule6 -A INPUT -s 127.0.0.1 -i lo -j ACCEPT
}

# set initial policies on IPv4 and IPv6
init() {
	init4
	init6
}

