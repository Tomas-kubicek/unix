#!/bin/sh
if [ "$1" == "--help" ]; then 
	echo "Pouzitie: uloha02.sh [OPTION] [args]
  --normal	Vypise vsechny argumenty na vlastni radek.
  --reverse	Vypise vsechny argumenty na vlastni radek v opacnem poradi.
  --subst	Nahradí vsechny vyskyty druhého argumentu tretim argumentem v nasledujících argumentech a vypise je na vlastni radek. 
  --len 	skript vypíše na jeden riadok dĺžky všetkých argumentov, oddelený medzerami.
  --help	Vypise, jak se pouziva program"
elif [ "$1" == "--normal" ]; then
	for arg in "$@"; do
    		echo "$arg"
	done
elif [ "$1" == "--reverse" ]; then
	for (( i=$#;i>0;i-- )); do
        	echo "${!i}"
	done
elif [ "$1" == "--subst" ]; then
	expression="$2"
	newExpression="$3"
	shift 3
    	for arg in "$@"; do
    		echo "${arg//$expression/$newExpression}"
	done
elif [ "$1" == "--len" ]; then
	len="${#1}"
	shift
	for arg in "$@"; do
    		len="${len} ${#arg}"
	done
	echo $len
fi
exit 0
