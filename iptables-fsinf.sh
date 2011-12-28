#!/bin/sh

exec_dir=`dirname $(readlink -f $0)`
cd $exec_dir

[ -z $DRYRUN ] && DRYRUN='n'
[ -z $INCLUDEDIR ] && INCLUDEDIR='include/'
[ -z $BASEDIR ] && BASEDIR='.'
CONFDIR="$BASEDIR/conf.d"
INITDIR="$BASEDIR/init.d"

# include functions
for file in $(find $INCLUDEDIR -type f -or -type l | sort | grep '.sh$')
do
	. $file
done

for file in $(find $CONFDIR -type f -or -type l | sort | grep '/[0-9][0-9]')
do
	. $file
done

# initialize:
init

# execute additional rules the system has in $INITDIR
echo
echo "# Add rules found in $INITDIR"
for file in $(find $INITDIR -type f -or -type l | sort | grep '/[0-9][0-9]')
do
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

# count traffic
count_traffic
