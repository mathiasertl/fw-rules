block_hosts() {
	rule --new-chain BLOCKED_IN
	rule -I INPUT -j BLOCKED_IN
	rule --new-chain BLOCKED_OUT
	rule -I OUTPUT -j BLOCKED_OUT

	rule_list "$BLOCKED_HOSTS" -A BLOCKED_IN -j DROP -s
	rule_list "$BLOCKED_HOSTS" -A BLOCKED_OUT -j DROP -d
}
