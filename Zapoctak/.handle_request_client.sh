#!/bin/sh
function handle_start {
	read playercolor
	read turn
	read size
	read lost_black
	read lost_white
	read pass_number
	read prev_board
	read board
	echo START >&3
	echo $playercolor >&3
	echo $turn >&3
	echo $size >&3
	echo $lost_black >&3
	echo $lost_white >&3
	echo $pass_number >&3
	echo $prev_board >&3
	echo $board >&3
}

function handle_next {
	read turn
	read lost_black
	read lost_white
	read pass_number
	echo $pass_number
	read prev_board
	read board
	echo NEXT >&3
	echo $turn >&3
	echo $lost_black >&3
	echo $lost_white >&3
	echo $pass_number >&3
	echo $prev_board >&3
	echo $board >&3
}

function handle_kys {
	echo KYS >&3
}
function handle_game_end {
	echo GAMEEND >&3
	read winner
	echo $winner >&3
}

file="$1"
read type

exec 3>$file
case $type in 
	START) 
		handle_start
		;;
	NEXT)
		handle_next
		;;
	KYS)
		handle_kys
		;;
	GAMEEND)
		handle_game_end
		;;
esac
exec 3>&-
exit 0
