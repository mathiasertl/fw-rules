# iptables-fsinf

A set of shell scripts to set up iptables/ip6tables rules. It is designed to be
easily extendable by configuration snippets shipped via package manager or
similar.

**NOTE:** Since meddling with your iptables rules can be really dangerous and
lock you out your system, iptables-fsinf by default does nothing until
configured (see below).

## Usage

iptables-fsinf is usually used via systemd. You initialize your iptables rules
by simply calling:

```
systemctl start iptables-fsinf
```

This will call `iptables-restore` on `/etc/iptables-fsinf/iptables.rules` and
`ip6tables-restore` on `/etc/ip6tables-fsinf/iptables.rules`. If the files do
not exist, they are recreated based on the configuration (see below).

To force reloading the configuration and recreating the files used by
iptables-restore, use restart:

```
systemctl restart iptables-fsinf
```

To reset the firewall to a save default state (all chains with the default
policy ACCEPT and no rules), stop the service:

```
systemctl stop iptables-fsinf
```

## Configuration

Configuration files are only used upon inital invocation (when the rules files
don't exist yet) or when the `restart` action is used (which recreates the
rules files). iptables-fsinf is a simple shell script that does, in order:

1. Include all files in `/etc/iptables-fsinf/conf.d/`, in alphabetical order.
2. Do some initialization (set the policy for the default chains, etc).
3. Include all files in `/etc/iptables-fsinf/init.d/`, again in alphabetical
   order.

For basic configuration (and configuration used by your snippets in the init.d
directory), simply add files to conf.d directory. The following variables are
available right away:

variabe | purpose
------- | -------
ENABELED | Unless set to `y`, this script will nothing. The default is `n`.
ENABLE_V4 | If set to `n`, do not configure IPv4.
ENABLE_V6 | If set to `n`, do not configure IPv6.
BLOCKED_HOSTS | If set, given addresses are blocked from all traffic.
GLOBAL_PORTS | If set, this machine will accept all traffic for a given port.
FORWARD_POLICY | The policy for the FORWARD chain. The default is `DROP`.
INPUT_POLICY | The policy for the INPUT chain. The default is `DROP`.
OUTPUT_POLICY | The policy for the OUTPUT chain. The default is `ACCEPT`.

Example:

```
ENABLED=y
GLOBAL_PORTS="$GLOBAL_PORTS 22 80 443"

# block example.com, for some reason
BLOCKED_HOSTS="$BLOCKED_HOSTS 93.184.216.34 2606:2800:220:1:248:1893:25c8:1946"
```

Note that the `{INPUT,FORWARD,OUTPUT}_POLICY` settings are used for both IPv4
and IPv6, if you want a different setting, you have to set it manually
somewhere in the `init.d` directory. 
