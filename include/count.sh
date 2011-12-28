counter_setup() {
	bin=$1
	proto=$2
	dir=$3
	ports=$4

	# construct the name of the chain
	chain=COUNT_$(echo $proto | tr '[:lower:]' '[:upper:]')_$dir
	
	# set vars depending on if this is IN our OUT
	if [ "$dir" = "IN" ]; then
		ifarg='-i'
		portarg='--dport'
		parchain='INPUT'
	elif [ "$dir" = "OUT" ]; then
		parchain='OUTPUT'
		portarg='--sport'
		ifarg='-o'
	fi
	
	# create and add chain
	$bin --new-chain $chain 
	$bin -I $parchain -p $proto -j $chain $ifarg $IFACE

	for port in $ports; do
		$bin -A $chain -p $proto $portarg $port 
	done
}

counter_create() {
	if [ -n "$COUNT_TCP_IN" ]; then
		counter_setup "$1" "tcp" "IN" "$COUNT_TCP_IN"
	fi

	if [ -n "$COUNT_UDP_IN" ]; then
		counter_setup "$1" "udp" "IN" "$COUNT_UDP_IN"
	fi

	if [ -n "$COUNT_TCP_OUT" ]; then
		counter_setup "$1" "tcp" "OUT" "$COUNT_TCP_OUT"
	fi

	if [ -n "$COUNT_UDP_OUT" ]; then
		counter_setup "$1" "udp" "OUT" "$COUNT_UDP_OUT"
	fi
}

count_traffic4() {
	echo "# Initialize traffic counters for IPv4"
	counter_create 'rule4'
}

count_traffic6() {
	echo "# Initialize traffic counters for IPv6"
	counter_create 'rule6'
}

# Count traffic on TCP/UDP, both in- and outgoing. Uses the evnironment
# variables COUNT_{TCP,UDP}_{IN,OUT} to construct chains with the same name that
# can be used for traffic counting, e.g. by a watchdog or munin plugin.
# The chains use the interface set by the environment variable INTERFACE.
count_traffic() {
	count_traffic4
	count_traffic6
}
