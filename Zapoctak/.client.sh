#!/bin/sh
function end {
	playing=false
        rm "$file" 2>/dev/null
        ( printf "KYS\n" | nc "$server_ip" ${server_port} ) 2>/dev/null
	printf "\e[?12l\e[?25h"  # Turn on cursor
	stty "$_STTY"            # reinitialize terminal settings
	tput sgr0
	tput clear
}

function set_turn {
	if [ $turn = $color ]; then
		my_turn=true
	else 
		my_turn=false
	fi
}

function init {
	client_ip=`ip addr show dev eth0 | grep -oPe '(?<=inet )[0-9.]+'`
	client_port="$1"
	server_ip="$2"
	server_port=2345
	file="/tmp/go.client.$client_port"
	touch $file
	playing=true
	first_render=true
}

function init_state {
	exec 3<$file
	read start <&3
	read color <&3
	read turn <&3
	read size <&3
	read black_lost <&3
	read white_lost <&3
	read pass_number <&3
	read prev_board <&3
	read board_dummy <&3
	exec 3<&-
	set_board "${board_dummy}"
	set_turn
	empty_file
}

function set_board {
	board="$1"
	render=true
}

function empty_file {
	: > "$file"
}

function prepare_playing  {
	_STTY=$(stty -g)      # Save current terminal setup
	printf "\e[?25l"
	clear
}

function render_game {
	local x y
	printf "\e[30;44m"
	if ${first_render} ; then 
		printf "\e[1;1f "
		for ((x=1;x<=$size;x++))
		do
			printf "\e[1;$((x+1))f${x}"
		done
		for ((y=1;y<=$size;y++))
		do
			printf "\e[$((y+1));1f${y}"
		done
	fi
	render_board
}

function render_board {
	set -- $board
	local x y o
	for ((x=1;x<=$size;x++))
	do
		for ((y=1;y<=$size;y++))
	        do
			if [ "$1" = "W" ]; then
				o="\e[37m\xE2\x8F\xBA\e[30m"
			elif [ "$1" = "B" ]; then
				o="\xE2\x8F\xBA"
			elif [ "$1" = "E" ]; then
				o=$(get_empty_character $x $y)
			else
				exit 1
			fi
			printf "\e[$((1+x));$((1+y))f${o}"
			shift
		done
	done
}

function get_empty_character {
	local x=$2 y=$1
	if [ $x -eq 1 ]; then
		if [ $y -eq 1 ]; then
			printf '\xE2\x94\x8F'
		elif [ $y -eq $size ]; then
			printf '\xE2\x94\x97'
		else
			printf '\xE2\x94\xA3'
		fi
	elif [ $x -eq $size ]; then
		if [ $y -eq 1 ]; then
			printf '\xE2\x94\x93'
		elif [ $y -eq $size ]; then
			printf '\xE2\x94\x9B'
		else
			printf '\xE2\x94\xAB'
		fi
	elif [ $y -eq 1 ]; then 
		printf '\xE2\x94\xB3'
	elif [ $y -eq $size ]; then
		printf '\xE2\x94\xBB'
	else
		printf '\xE2\x95\x8B'
	fi
}

function handle_move {
			if  ${my_turn} ; then
				printf "\e[37;40m\e[$((size+2));1fCoordinates:"
				IFS=, read x y
				printf "STONE\n${color}\n${x},${y}\n" | nc "$server_ip" ${server_port} 1>"$file"
				exec 3<$file		
				read response <&3
				if [ $response = "SUCCESS" ]; then
					read turn <&3
					set_turn
					read lost_black <&3
					read lost_white <&3
					read pass_number <&3
					read prev_board <&3
					read dummy <&3
					set_board "${dummy}"
					read <&3 
				else
					read reason <&3
					printf "\e[37;40m\e[$((size+2));1f\e[K${reason}"
					read <&3
					sleep 5
				fi
				exec 3<&-
			else
				printf "\e[37;40m\e[$((size+2));1fNot your turn."
				sleep 5
			fi
}

function handle_next {
	read turn <&3
	set_turn
	read lost_black <&3
	read lost_white <&3
	read pass_number <&3
	read prev_board <&3
	read dummy <&3
	set_board "${dummy}"
}

function handle_save {
	read save_name
	save_name=./saves/"${save_name}"
	touch "${save_name}"
	echo $turn > "$save_name"
	echo $size >> "$save_name"
	echo $lost_black >> "$save_name"
	echo $lost_white >> "$save_name"
	echo $pass_number >> "$save_name"
	echo $prev_board >> "$save_name"
	echo $board >> "$save_name"
}

function handle_pass {
	exec 3<$file
	read option <&3
	case $option in
		OK)
			read pass_number <&3
			read turn <&3
			set_turn
			;;
		GAMEEND)
			read winner <&3
			printf "\e[37;40m\e[$((size+2));1f\e[K${winner}"
			sleep 10
			exit 0
			;;	
	esac
	exec 3<&-
}


init $@


sleep "0.5"
( printf "CONNECT\n${client_ip}\n${client_port}\n${3}\n" | nc "${server_ip}" "${server_port}" ) 1>/dev/null 2>/dev/null
trap end 1 2 3 15 EXIT

if nc -w 300 -l -s "$client_ip" -p "$client_port" -c "./.handle_request_client.sh $file" 2>/dev/null ; then
	init_state
else
        echo "No response from the server in 5 minutes"
        exit 1
fi

prepare_playing

while $playing ; do
	if $render ; then 
		render_game
		render=false
	fi
	printf "\e[37;40m\e[$((size+2));1f\e[K"
	if ${my_turn}; then
		printf "\e[37;40m\e[$((size+2));1f\e[KCommand:"
		read command
		case $command in
			move)	
				handle_move
				;;
			pass)
				printf "PASS\n" | nc "$server_ip" ${server_port} 1>"$file"
				handle_pass
				;;
			save)
				handle_save
				;;
			exit)
				exit 0
				;;

		esac
	else
		stty -echo
		if nc -w 300 -l -s "$client_ip" -p "$client_port" -c "./.handle_request_client.sh $file" 2>/dev/null ; then
			exec 3<$file
			read type <&3
			case $type in
				NEXT)
					handle_next
					;;
				KYS)
					exit 0
					;;
				GAMEEND)
					read winner <&3
					printf "\e[37;40m\e[$((size+2));1f\e[K${winner}"
					sleep 10
					exit 0
					;;
			esac
			exec 3<&-
		else
        		echo "No response from the server in 5 minutes"
        		exit 1
		fi
		stty "echo"
	fi
	printf "\e[37;40m\e[$((size+2));1f\e[K"
	empty_file
done
