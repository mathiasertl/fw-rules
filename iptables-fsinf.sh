#!/bin/sh

exec_dir=`dirname $(readlink -f $0)`
cd $exec_dir

[ -z $DRYRUN ]       && DRYRUN='n'

# base directories:
[ -z $CONFBASEDIR ]  && CONFBASEDIR='/etc/fw-rules'
[ -z $SHAREDIR ]     && SHAREDIR='/usr/share/fw-rules'

# important directories
[ -z $INCLUDEDIR ]   && INCLUDEDIR="$SHAREDIR/include/"
[ -z $CONFDIR ]      && CONFDIR="$CONFBASEDIR/conf.d"
[ -z $INITDIR ]      && INITDIR="$CONFBASEDIR/init.d"

# include functions
for file in $(find $INCLUDEDIR -type f -or -type l | sort | grep '.sh$')
do
	echo $file
	. $file
done

for file in $(find $CONFDIR -regex $CONFDIR'/[0-9][0-9].*' -and '(' -type f -or -type l ')' | sort)
do
	echo $file
	. $file
done

# initialize:
init

# add global ports:
global_ports

# execute additional rules the system has in $INITDIR
echo
echo "# Add rules found in $INITDIR"
#for file in $(find $INITDIR -type f -or -type l | sort | grep '/[0-9][0-9]')
for file in $(find $INITDIR -regex $INITDIR'/[0-9][0-9].*' -and '(' -type f -or -type l ')' | sort)
do
	echo $file
	. $file
done
echo "# Finished adding rules found in $INITDIR"
echo 

# COUNT, ICMP and BLOCKED chains are inserted last, but on top of our
# filter-rules.

# allow only some icmp
icmp

# block some hosts:
block_hosts

# count traffic:
count_traffic
