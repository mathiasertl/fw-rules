# cleanup IPv4 (e.g. on error)
function cleanup4 {
	iptables -F
	iptables -X
}

# cleanup IPv6 (e.g. on error)
function cleanup6 {
	ip6tables -F
	ip6tables -X
}

# cleanup IPv4 and IPv6 (e.g. on error)
function cleanup {
	cleanup4
	cleanup6
}

# set initial policies on IPv4
function init4 {
	iptables -P INPUT DROP
	iptables -P FORWARD DROP
	iptables -P OUTPUT ACCEPT
}

# set initial policies on IPv6
function init6 {
	ip6tables -P INPUT DROP
	ip6tables -P FORWARD DROP
	ip6tables -P OUTPUT ACCEPT
}

# set initial policies on IPv4 and IPv6
function init {
	init4
	init6
}

# Accept all connections in case of an error
function reset {
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
function rule4 {
	iptables ${@}
	if [ "${?}" -ne 0 ]; then
		reset
		exit 1
	fi
}

# a rule just for IPv6
function rule6 {
	iptables ${@}
	if [ "${?}" -ne 0 ]; then
		reset
		exit 1
	fi
}

# create a rule for IPv4 and IPv6
function rule {
	rule4 ${@}
	rule6 ${@}
}
