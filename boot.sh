#!/bin/bash

script_name="$0"
host_name=""
platform_name=""

### Print usage.
function print_help
{
cat <<!EOF!
Usage:  $script_name
        -h                  - print usage
        -p <platform name>  - currently supported only <hood-phase0>
        -b <host name>      - host name <'zcu102[da7-prod]'>
!EOF!
}

### Checking that $host_name and $platform_name are specified.
function check_args
{
	if [ "$host_name" = "" ] || [ "$platform_name" = "" ]; then
		echo  "-p <platform name> and -b <host name> are mandatory options"
		print_help
		exit 1
	fi
}

### Checking command line arguments. 
#TODO: change to getopts
function parse_input_args
{
        while getopts "h:p:b:" opt; do
                case $opt in
                        h)
                        print_help
                        exit
                        ;;
                        p)
                        platform_name=$OPTARG
                        ;;
                        b)
                        host_name=$OPTARG
                        ;;
                        *)
                        print_help
                        exit
                        ;;
                esac
        done
        shift $((OPTIND-1))
        check_args
}

### Running the boot script (run.systest) on specified machine.
function run
{
        if [[ "$platform_name" == "hood-phase0" ]]
        then
                echo "run command:  $host_name "
        else
                echo "$platform_name is not supported"
                exit 1
        fi
}

### Main function.
function main
{       
         parse_input_args "$@"
         run 
}

main "$@"
