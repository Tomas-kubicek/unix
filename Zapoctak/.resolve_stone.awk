#!/usr/bin/awk -f
BEGIN {
	identifier=1
	lost["B"]=0
	lost["W"]=0
}
{
	for (i = 1 ; i <= size ; i++){
		for (j = 1 ; j <= size ; j++){
			board[i "," j] = $( (i - 1) * size + j) 
		}
	}
}

function print_board(){
	for (i = 1 ; i <= size ; i++){
		for (j = 1; j <= size; j++){
			printf "%s ", board[i "," j] 
		}
	}
}

function eliminate(color){
	for (i = 1 ; i <= size ; i++){
		for (j = 1 ; j <= size ; j++){
			if ( visited[i "," j] == "N" && board[i "," j] == color  ){
				freedom="false"
				mark( i  , j )
				if(freedom=="false"){
					destroy()
				}
				identifier++
			}	 
		}
	}
}

function mark(a,b,_color){
	_color= board[a "," b] 
	visited[a "," b] = identifier
	if((board[a+1 "," b] == "E") || (board[a-1 "," b] == "E") || (board[a "," b+1] == "E") || (board[a "," b-1] == "E")){
		freedom="true"
	}
	if (board[a+1 "," b] == _color && visited[a+1 "," b] == "N") {
		mark(a+1,b)
	}
	if (board[a-1 "," b] == _color && visited[a-1 "," b] == "N") {
		mark(a-1,b)
	}
	if (board[a "," b+1] == _color && visited[a "," b+1] == "N") {
		mark(a,b+1)
	}
	if (board[a "," b-1] == _color && visited[a "," b-1] == "N") {
		mark(a,b-1)
	}
}

function destroy(){
	for (k = 1 ; k <= size ; k++){
		for (l = 1 ; l <= size ; l++){
			if(visited[k "," l]==identifier){
				lost[board[k "," l]]++
				board[k "," l] = "E"
			} 
		}
	}
}
END {
	if (board[x "," y] != "E") {
		exit 1
	}

	for (i = 1 ; i <= size ; i++){
		for (j = 1 ; j <= size ; j++){
			visited[i "," j] = "N" 
		}
	}
	board[x "," y] = player
	other_player = (player == "W")? "B": "W"

	eliminate(other_player)
	eliminate(player)

	print_board()
	printf ":W=%d:B=%d", lost["W"], lost["B"]
}
