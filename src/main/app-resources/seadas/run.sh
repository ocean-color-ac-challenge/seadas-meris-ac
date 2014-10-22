#!/bin/bash

# source the ciop functions (e.g. ciop-log)

source ${ciop_job_include}
export LC_ALL="en_US.UTF-8"

# define the exit codes
SUCCESS=0
ERR_NOINPUT=5
ERR_SEADAS=10
ERR_PCONVERT=20
ERR_TAR=30

# add a trap to exit gracefully
function cleanExit ()
{
	local retval=$?
	local msg=""
	case "$retval" in
		$SUCCESS) 	msg="Processing successfully concluded";;
		$ERR_NOINPUT)	msg="Input not retrieved to local node";;
		$ERR_SEADAS)	msg="seaDAS l2gen returned an error";;
		$ERR_PCONVERT)	msg="Conversion to BEAM-DIMAP failed";;
		$ERR_TAR)	msg="Compression of BEAM-DIMAP failed";;
		*)		msg="Unknown error";;
	esac

	[ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"

	exit $retval
}

trap cleanExit EXIT

par=`ciop-getparam "par"`

ciop-log "DEBUG" "Running on display $DISPLAY"

export PATH_TO_SEADAS=/usr/local/seadas-7.1/
source $PATH_TO_SEADAS/ocssw/OCSSW_bash.env
export OCDATAROOT=$PATH_TO_SEADAS/ocssw/run/data/
export DISPLAY=:99

myInput="$TMPDIR/input"
myOutput="$TMPDIR/output"
mkdir -p $myInput $myOutput

while read input
do
	#getting the input
	ciop-log "INFO" "Working with MERIS product $input"

	n1input=`ciop-copy -o $myInput $input`
	[ $? != 0 ] && exit $ERR_NOINPUT
	
	#preparing the processor run
	l2output="$myOutput/`basename $n1input | sed 's#\.N1$#.L2#g'`"
	seadaspar="$myOutput/`basename $n1input | sed 's#\.N1$#.par#g'`"

cat >> $seadaspar << EOF
# PRIMARY INPUT OUTPUT FIELDS
ifile=$n1input
ofile=$l2output

$par
EOF
	
	ciop-log "INFO" "Starting seaDAS processor"
	$PATH_TO_SEADAS/ocssw/run/bin/l2gen par="$seadaspar"
	[ $? != 0 ] && exit $ERR_SEADAS

	ciop-log "INFO" "Conversion to BEAM-DIMAP format"
	$PATH_TO_SEADAS/bin/pconvert.sh --outdir $myOutput $l2output 
	[ $? != 0 ] && exit $ERR_PCONVERT

	ciop-log "INFO" "Compressing results"
	tar -C $myOutput -cvzf $myOutput/`basename $l2output`.tgz \
			`basename $l2output | sed 's#\.L2$#.dim#g'` \
			 `basename $l2output | sed 's#\.L2$#.data#g'`
	[ $? != 0 ] && exit $ERR_TAR	

	#publishing the output
	ciop-log "INFO" "Publishing `basename $l2output`.tgz"
	ciop-publish -m $myOutput/`basename $l2output`.tgz
	
	rm -rf $myInput/*
	rm -rf $myOutput/*
done
