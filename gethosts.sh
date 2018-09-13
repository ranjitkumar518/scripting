#!/bin/sh

# foreach: run the specified command on each app server.

bindir=`dirname $0`
hier=`cd $bindir/.. && pwd`

hostsfile=$hier/conf/hosts.conf
get_cmd_opts () {
    while getopts "t:f:h" OPTION
    do
        case $OPTION in
            h)
                usage
                exit 1
                ;;
            t) type=$OPTARG
               host_type_list="$type $host_type_list"
               ;;
            f) hostsfile=$OPTARG ;;
            ?) usage ;;
        esac
    done

    # Verify we have required options, we can also do additional validation
    if ! [ -n "${type}" ]; then
      log "Error: required options not provided: -t"
      usage;
      exit 1
    fi
}


read_hosts_file () {
    if [ ! -r $hostsfile ]; then
        echo "Unable to locate hosts.conf, goodbye."
        exit 1
    else
        newhosts=`grep -v '^\s*#' $hostsfile | awk 'NF == 2 && $2 == hosttype { print $1}' hosttype=$1`
    fi
}

host_type_list=
host_list=
new_hosts=
get_cmd_opts $@
for host_type in $host_type_list; do
   read_hosts_file $host_type
   host_list="$newhosts $host_list"
done
echo $host_list
