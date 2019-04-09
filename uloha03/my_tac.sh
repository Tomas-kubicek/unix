#!/bin/sh
ceil() {
    float_in=$1
    if [[ $float_in == *"."* ]]; then
        output=${float_in/.*}
        overflow=${float_in/*.}
        if  (( $overflow > 0 ))
        then
                output=$((output+1))
        fi
    else
        output=$float_in
    fi
    echo $output
}

argarray=("$@")
perLine=-1
input='-'
for (( i=0; i < $# ; i++ )); do
	if [ "${argarray[i]}" = '-n' ]; then
		perLine="${argarray[i+1]}"
		i=`expr $i+1`
	elif [ -f "${argarray[i]}" ]; then 
		input="${argarray[i]}"	
	fi
done
tfile=$(mktemp /tmp/middle.XXX)
cat "$input" >$tfile
NUMB=`wc -l <$tfile`
if ! [ $perLine -gt 0 ]; then
	perLine=1
fi
tmp=`echo "scale=2; $NUMB / $perLine " | bc -l`
tmp=`ceil $tmp`
N=$NUMB
M=`expr $N - $perLine + 1`
for ((i=$tmp ; i>0; i--)); do
	./middle.sh -l "${M}-$N" $tfile 
	N=`expr $N - $perLine`
	M=`expr $N - $perLine + 1`
done
rm -f $tfile
exit 0
