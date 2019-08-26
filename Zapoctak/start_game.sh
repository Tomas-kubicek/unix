#!/bin/sh
connect=false
file="./.maps/empty_9x9"
player="B"
while getopts "c:l:p:" opt; do
	case $opt in
		c)
			if [ $OPTIND -eq 3 ]; then
				connect=true
				connect_ip=`printf $OPTARG | cut -d: -f1`
				connect_port=`printf $OPTARG | cut -d: -f2`
			else
				cat ./.error_messages/c_not_first
				exit 1
			fi
			;;
		l)
			if $connect; then
				cat ./.error_messages/flag_not_allowed_connect
				exit 1
			fi
			if [ -f "$OPTARG" ]; then
				file="$OPTARG"
			else
				cat ./.error_messages/load_error
				exit 1
			fi
			;;
		p)	
			if $connect; then
				cat "./.error_messages/flag_not_allowed_connect"
				exit 1
			fi
			dummy=`printf "$OPTARG" | tr '[:lower:]' '[:upper:]'`
			if [ "$dummy" = "BLACK" -o "$dummy" = "WHITE" ]; then
				player=`printf $dummy | head -c 1`  			
			else
				cat ./.error_messages/player_error
				exit 1
			fi
			;;
		\?)
			cat "./.error_messages/help"
			exit 2
			;;
	esac
done

IP=`ip addr show dev eth0 | grep -oPe '(?<=inet )[0-9.]+'`
if $connect; then
	./.client.sh 2346 "$IP" "unknown"
else
	./.server.sh  "${IP}:2345" "$file" 1>/dev/null 2>/dev/null &
	echo "The other player can now connect on ${IP}:2345"
	./.client.sh 2347 "$IP" $player
fi
