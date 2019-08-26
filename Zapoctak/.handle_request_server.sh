#!/bin/sh
function do_nothing {
	exec 3>/tmp/go.changes
	echo NOTHING >&3
	exec 3>&-
}

function kys {
	exec 3>/tmp/go.changes
	echo KYS >&3
	exec 3>&-
}
function failure {
	echo "FAILURE"
	echo "$1"
	end
	do_nothing
}

function end {
	echo "END"	
}

function resolve_move {
	result=`echo "$board" | awk -v x="$1" -v y="$2" -v player="$3" -v size="$size" -f ./.resolve_stone.awk`
	if [ $? -eq 1 ]; then
		failure "NON_EMPTY"
		return
	fi
	new_board=`echo "$result" | cut -d ':' -f 1 `
	if [ "$new_board" = "$prev_board" ]; then
		failure "KO"
	else
		prev_board=$board
		board=$new_board
		lost=`echo "$result" | cut -d ':' -f 2 | cut -d '=' -f 2`
		lost_white=$(( lost_white + lost))
		lost=`echo "$result" | cut -d ':' -f 3 | cut -d '=' -f 2`
		lost_black=$(( lost_black + lost))
		
		echo SUCCESS
		if [ $turn = "W" ]; then
			echo "B" 
		else
			echo "W" 
		fi
		echo $lost_black
		echo $lost_white
		echo 0
		echo "$prev_board"
		echo "$board"
		end

		exec 3>/tmp/go.changes
		echo SAVE >&3
		if [ $turn = "W" ]; then
			echo "B" >&3
		else
			echo "W" >&3
		fi
		echo $lost_black >&3
		echo $lost_white >&3
		echo 0 >&3
		echo "$prev_board" >&3
		echo "$board" >&3
		exec 3>&-
	fi
} 
function handle_pass {
	if [ $pass_number -eq 0 ]; then
		echo OK
		echo 1
		if [ $turn = "W" ]; then
			echo "B" 
		else
			echo "W"
		fi
		end
		exec 3>/tmp/go.changes
		echo PASS >&3
		echo 1 >&3
		if [ $turn = "W" ]; then
			echo "B" >&3
		else
			echo "W" >&3
		fi
		exec 3>&-
	else
		result=`echo "$board" | awk -v size="$size" -f ./.resolve_points.awk`
		black_p=$(($(echo $result| cut -d ';' -f 1 | cut -d '=' -f 2 ) + lost_white))
		white_p=$(($(echo $result| cut -d ';' -f 2 | cut -d '=' -f 2 ) + lost_black+4))
		echo GAMEEND
		if (( black_p <= white_p )); then
			echo White won. Black points: ${black_p}.White point ${white_p}
		else
			echo Black won. Black points: ${black_p}.White point ${white_p}
		fi
		end
		exec 3>/tmp/go.changes
		echo GAMEEND >&3
		if (( black_p < white_p )); then
			echo White won. Black points: ${black_p}.White point ${white_p} >&3
		else
			echo Black won. Black points: ${black_p}.White point ${white_p} >&3
		fi

		exec 3>&-
	fi
}

#read state from model
exec 3</tmp/go.model
read turn <&3
read size <&3
read lost_black <&3
read lost_white <&3
read pass_number <&3
read prev_board <&3
read board <&3
exec 3<&-

read type
case $type in 
	STONE) 
		read player
		if [ $player != $turn ]; then
			failure NOT_PLAYER_TURN
			exit 0:
		fi
		IFS=, read x y
		resolve_move $x $y $player 
		;;
	KYS) 
		echo OK
		end
		kys
		;;
	CONNECT) 
		read IP
		read PORT
		read color
		echo ACK
		exec 3>/tmp/go.changes
                echo "CONNECT" >&3
                echo $IP >&3
                echo $PORT >&3
                echo $color >&3
                exec 3>&-
		end
		;;
	PASS) 
		handle_pass
		;;
esac
exit 0
