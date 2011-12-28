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
		if [ "$DRYRUN" = 'n' ]; then
			iptables ${@}
		fi
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
		if [ "$DRYRUN" = 'n' ]; then
			ip6tables ${@}
		fi
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

# Add a rule for each IP address found in $1. Each rule is constructed by all
# arguments following $1 appended by the respective host from $1.
# This function dynamically uses IPv4 or IPv6 depending on the type of address
# is found. 
#
# Note: Remember to always quote $1 so that it is used as list.
#
# Example usage:
#      rule_list "127.0.0.1 ::1" -A INPUT -i lo -j ACCEPT -s
# will execute:
#      iptables -A INPUT -i lo -j ACCEPT -s 127.0.0.1
#      ip6tables -A INPUT -i lo -j ACCEPT -s ::1
rule_list() {
	hosts=$1
	shift
	for host in $hosts; do
		echo $host | grep -q ':'
		if [ $? = 0 ]; then # found a ':' --> ipv6!
			rule6 $@ $host
		else
			rule4 $@ $host
		fi
	done
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
	rule6 -A INPUT -s ::1 -i lo -j ACCEPT
}

# set initial policies on IPv4 and IPv6
init() {
	init4
	init6
}

