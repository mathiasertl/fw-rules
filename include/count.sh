counter_setup() {
	bin=$1
	proto=$2
	dir=$3
	ports=$4

	chain=COUNT_$(echo $proto | tr '[:lower:]' '[:upper:]')_$dir

	# create chain
	$bin --new-chain $chain
	
	# add chain to parent chain:
	if [ "$dir" = "IN" ]; then
		$bin -I INPUT -j $chain

		arg='--dport'
	elif [ "$dir" = "OUT" ]; then
		$bin -I OUTPUT -p $proto -j $chain

		arg='--sport'
	fi

	for port in $ports; do
		$bin -A $chain $arg $port 
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

count_traffic() {
	count_traffic4
	count_traffic6
}
