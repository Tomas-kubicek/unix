#!/bin/sh
sortedfile1=$(mktemp /tmp/du.XXX)
sortedfile2=$(mktemp /tmp/du.XXX)
sortedfile3=$(mktemp /tmp/du.XXX)
sortedfile4=$(mktemp /tmp/du.XXX)
sort "$1" >"$sortedfile1"
sort "$2" >"$sortedfile2"
sort "$3" >"$sortedfile3"

comm -12 "$sortedfile1" "$sortedfile2" >"$sortedfile4"
comm -12 "$sortedfile3" "$sortedfile4" 
rm "$sortedfile1"
rm "$sortedfile2"
rm "$sortedfile3"
rm "$sortedfile4"
exit 0
