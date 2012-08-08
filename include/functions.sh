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

# Accept all connections in case of an error
reset4() {
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD DROP
	iptables -F
	iptables -X
}

reset6() {
	ip6tables -P INPUT ACCEPT
	ip6tables -P OUTPUT ACCEPT
	ip6tables -P FORWARD DROP
	ip6tables -F
	ip6tables -X
}
reset() {
	reset4
	reset6
}

# a rule just for IPv4
rule4() {
	if [ "$ENABLE_V4" != 'n' ]; then
		echo iptables ${@}
		if [ "$DRYRUN" = 'n' ]; then
			iptables ${@}
			if [ "${?}" -ne 0 ]; then
				echo "FAILED SETTING UP IPv4 FIREWALL. RESETTING TO SAFE DEFAULT STATE."
				reset4
				ENABLE_IPV4='n'
			fi
		fi
	fi

}

# a rule just for IPv6
rule6() {
	if [ "$ENABLE_V6" != 'n' ]; then
		echo ip6tables ${@}
		if [ "$DRYRUN" = 'n' ]; then
			ip6tables ${@}
			if [ "${?}" -ne 0 ]; then
				echo "FAILED SETTING UP IPv6 FIREWALL. RESETTING TO SAFE DEFAULT STATE."
				reset6
				ENABLE_IPV6='n'
			fi
		fi
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
	if [ "$ENABLE_V4" = 'n' ]; then
		return
	fi
	echo '# cleanup IPv4'
	rule4 -F
	rule4 -X
}

# cleanup IPv6 (e.g. on error)
cleanup6() {
	if [ "$ENABLE_V6" = 'n' ]; then
		return
	fi
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
	if [ "$ENABLE_V4" = 'n' ]; then
		return
	fi
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
	if [ "$ENABLE_V6" = 'n' ]; then
		return
	fi
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

