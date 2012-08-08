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

block_hosts() {
	if [ -z "$BLOCKED_HOSTS" ]; then
		return
	fi

	echo "# Block hosts"

	rule --new-chain BLOCKED_IN
	rule -I INPUT -j BLOCKED_IN
	rule --new-chain BLOCKED_OUT
	rule -I OUTPUT -j BLOCKED_OUT

	rule_list "$BLOCKED_HOSTS" -A BLOCKED_IN -j DROP -s
	rule_list "$BLOCKED_HOSTS" -A BLOCKED_OUT -j DROP -d
}
