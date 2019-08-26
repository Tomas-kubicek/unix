#!/bin/sh
function init_model {
	exec 3<"$1"
	read turn <&3
	read size <&3
	read lost_black <&3
	read lost_white <&3
	read pass_number <&3
	read prev_board <&3
	read board <&3
	exec 3<&-
	cp "$1" "$model"
}

function save_and_next_turn {
	read turn <&3
	read lost_black <&3
	read lost_white <&3
	read pass_number <&3
	read prev_board <&3
	read board <&3
	echo $turn > $model
	echo $size >> $model
	echo $lost_black >> $model
	echo $lost_white >> $model
	echo $pass_number >> $model
	echo $prev_board >> $model
	echo $board >> $model
	delete_changes
	if [ $turn = $player1color ]; then
		printf "NEXT\n${turn}\n${lost_black}\n${lost_white}\n${pass_number}\n${prev_board}\n${board}\n" | nc "${player1ip}" "${player1port}"
	else
		printf "NEXT\n${turn}\n${lost_black}\n${lost_white}\n${pass_number}\n${prev_board}\n${board}\n" | nc "${player2ip}" "${player2port}"
	fi
}

function end {
	rm "$model" 2>/dev/null
	rm "$changes" 2>/dev/null
	carry_on=false
	( printf "KYS\n" | nc "${player1ip}" "${player1port}" ) 2>/dev/null
	( printf "KYS\n" | nc "${player2ip}" "${player2port}" ) 2>/dev/null
	kill -9 $PID 2>/dev/null 1>/dev/null
}

function init {
	touch /tmp/go.model
	touch /tmp/go.changes
	model="/tmp/go.model"
	changes="/tmp/go.changes"
	minutes_time_out=5
	time_outed=0
	carry_on=true
	started=false
	player1ready=false
	player2ready=false
}

function connect {
	if ! ${player1ready} ; then
		read player1ip <&3
		read player1port <&3
		read player1color <&3
		player1ready=true
	elif ! ${player2ready} ; then
		read player2ip <&3
		read player2port <&3
		if [ $player1color = "B" ]; then
			player2color="W"
		else
			player2color="B"
		fi
		player2ready=true
		started=true
		send_start_game_info
	fi
	delete_changes
}

function send_start_game_info {
	printf "START\n${player1color}\n${turn}\n${size}\n${lost_black}\n${lost_white}\n${pass_number}\n${prev_board}\n${board}\n" | nc "${player1ip}" "${player1port}"
	printf "START\n${player2color}\n${turn}\n${size}\n${lost_black}\n${lost_white}\n${pass_number}\n${prev_board}\n${board}\n" | nc "${player2ip}" "${player2port}"
}

function delete_changes {
	: > $changes
}

function handle_pass {
	read pass_number <&3
	read turn <&3
	echo $turn > $model
	echo $size >> $model
	echo $lost_black >> $model
	echo $lost_white >> $model
	echo $pass_number >> $model
	echo $prev_board >> $model
	echo $board >> $model
	if [ $turn = $player1color ]; then
		printf "NEXT\n${turn}\n${lost_black}\n${lost_white}\n${pass_number}\n${prev_board}\n${board}\n" | nc "${player1ip}" "${player1port}"
	else
		printf "NEXT\n${turn}\n${lost_black}\n${lost_white}\n${pass_number}\n${prev_board}\n${board}\n" | nc "${player2ip}" "${player2port}"
	fi
}

trap end 1 2 3 15 EXIT
init
init_model "$2"


IP=`printf "$1" | cut -d : -f 1`
PORT=`printf "$1" | cut -d : -f 2`
while $carry_on; do
	if ! nc -w 60 -l -s "$IP" -p "$PORT" -c "./.handle_request_server.sh $model" 2>/dev/null; then
		time_outed=$((time_outed + 1 ))
		if [ $time_outed -eq $minutes_time_out ]; then 
			exit 0
		fi
	else
		time_outed=0
		exec 3<$changes
		read command <&3
		case "$command" in
			SAVE)
				if $started ; then
					save_and_next_turn
				else
					delete_changes
				fi
				;;
			NOTHING)
				delete_changes 
				;;
			KYS)
				exit 0
				;;
			CONNECT)
				if ! $started ; then 
					connect	
				else
					delete_changes
				fi
				;;
			PASS)
				handle_pass	
				;;
			GAMEEND)
				read winner <&3
				if [ $turn = $player2color ]; then
					printf "GAMEEND\n${winner}\n" | nc "${player1ip}" "${player1port}"
				else
					printf "GAMEEND\n${winner}\n" | nc "${player2ip}" "${player2port}"
				fi
				;;
			*)
				exit 1
				;;
		esac
		exec 3<&-
	fi
done
