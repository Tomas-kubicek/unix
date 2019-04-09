#!/bin/sh
array=

parseInput(){
array=(${2//$1/ })
}

output=

floor() {
    float_in=$1
    output=${float_in/.*}
}

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
}

if [ "$1" = "-l" -o "$1" = "--lines" ]; then
	if (( $# <2 )); then
		echo "No M-N argument supplied"
		exit 1
	fi
	parseInput "-" $2
	M=${array[0]}
	N=${array[1]}
	if (( $M > $N )); then
		echo "In the second argument M-N, the M>N which cannot be."
		exit 1 
	fi
	[ -f "$3" ] && input="$3" || input='-'
	tfile=$(mktemp /tmp/middle.XXX)
	cat "$input" >$tfile
	if (( `wc -l <$tfile` < $N )); then
		N=`wc -l <$tfile` 
	fi
	if (( 0 >= $M )); then
		M=1 
	fi
	head -n $N $tfile | tail -n $(( $N - $M + 1))
elif [ "$1" = "-f" -o "$1" = "--fraction" ]; then
	if (( $# < 3 )); then
		echo "No A/B or C/D argument supplied"
		exit 1
	fi
	parseInput "/" $2
	A=${array[0]}
	B=${array[1]}
	parseInput "/" $3
	C=${array[0]}
	D=${array[1]}
	if (( $A > $B )) || (( $C > $D )); then
		echo "One of the fractions is greater than 1 which doesn't make sense."
		exit 1 
	fi
	[ -f "$4" ] && input="$4" || input='-'
	tfile=$(mktemp /tmp/middle.XXX)
	cat "$input" >$tfile
	lines=`wc -l <$tfile`
	floor `scale=5; echo "($A / $B) * $lines" |bc -l`
	M=$output
	ceil `scale=5; echo "($C / $D) * $lines" |bc -l`
	N=$output
	head -n $N $tfile | tail -n $(( $N - $M + 1))
elif [ "$1" = "-p" -o "$1" = "--part" ]; then
	if (( $# < 2 )); then
		echo "No A/B argument supplied"
		exit 1
	fi
	parseInput "/" $2
	A=${array[0]}
	B=${array[1]}
	if (( $A > $B )) ; then
		echo "A is greater than B, that doesn't make sense"
		exit 1 
	fi
	[ -f "$3" ] && input="$3" || input='-'
	tfile=$(mktemp /tmp/middle.XXX)
	cat "$input" >$tfile
	lines=`wc -l <$tfile`
	ceil `echo "scale=3; $lines / $B" |bc -l`
	NUMB=$output
	"$0" -l "$(( ($A-1)*${NUMB} + 1 ))-$(( ${A}*${NUMB} ))" "$tfile"
else
	echo "not a valid command"
	exit 1
fi

rm -f $tfile
exit 0
