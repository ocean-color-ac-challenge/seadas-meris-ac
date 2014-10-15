#!/bin/bash

# source the ciop functions (e.g. ciop-log)

source ${ciop_job_include}
export LC_ALL="en_US.UTF-8"

# define the exit codes
SUCCESS=0
ERR_NOINPUT=1

# add a trap to exit gracefully
function cleanExit ()
{
	local retval=$?
	local msg=""
	case "$retval" in
		$SUCCESS) 	msg="Processing successfully concluded";;
		$ERR_NOINPUT)	msg="Input not retrieved to local node";;
		$ERR_SEADAS)	msg="SEADAS l2gen returned an error";;
		*)		msg="Unknown error";;
	esac

	[ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"

	exit $retval
}

trap cleanExit EXIT

ciop-log "DEBUG" "Running on display $DISPLAY"

export PATH_TO_SEADAS=/usr/local/seadas6.4/ #seadas installation
source $PATH_TO_SEADAS/config/seadas.env #seadas installation

myInput="$TMPDIR/input"
myOutput="$TMPDIR/output"
mkdir -p $myInput $myOutput

while read input
do
	#getting the input
	ciop-log "INFO" "Working with file $input"
	file=`ciop-copy -o $myInput $input`
	
	[ $? != 0 ] && exit $ERR_NOINPUT
	
	ciop-log "DEBUG" "ciop-copy output is $file"

	cp $file /tmp/

	#preparing the processor run
	basefile=`basename $file`

	n1input="$file"
	l2output="$myOutput/`echo "$basefile" | sed 's#\.N1$#.L2#g'`"

	ciop-log "INFO" "Starting seadas processor"
	/usr/local/seadas6.4/run/bin/linux_64/l2gen ifile=$n1input ofile=$l2output

	[ $? != 0 ] && exit $ERR_SEADAS

	#publishing the output
	ciop-log "INFO" "Publishing output"
	ciop-publish -m $myOutput/*.L2

	rm -rf $TMPDIR/input/*
	rm -rf $TMPDIR/output/*
done
