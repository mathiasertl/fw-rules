global_ports() {
	for port in $GLOBAL_PORTS; do
		rule -A INPUT -p tcp --dport $port -j ACCEPT
	done
}
