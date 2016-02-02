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
not exist, they are recreated based on the configuration in in
`/etc/init.d/{conf,init}.d/`.

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
