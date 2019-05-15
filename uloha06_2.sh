#!/bin/sh
sortedfile1=$(mktemp /tmp/du.XXX)
sortedfile2=$(mktemp /tmp/du.XXX)
awk 'BEGIN {FS=";"} NR > 1 {print $1 ";" $4}' ./kodyzemi_cz.csv | sort --field-separator=";" -n -k1 >"$sortedfile1"
awk 'BEGIN {FS=";"} NR > 1 {print $4 ";" $1}' ./countrycodes_en.csv | sort --field-separator=";" -n -k1 >"$sortedfile2"
join -t";" -1 1 -2 1 "$sortedfile1" "$sortedfile2" -o 1.2,2.2 | awk 'BEGIN{FS=";"} {if( $1==$2 ){ print $1}}' 


rm "$sortedfile1"
rm "$sortedfile2"
exit 0

