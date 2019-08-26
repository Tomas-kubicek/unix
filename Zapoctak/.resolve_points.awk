#!/usr/bin/awk -f
BEGIN {
	identifier=1
}
{
	for (i = 1 ; i <= size ; i++){
		for (j = 1 ; j <= size ; j++){
			board[i "," j] = $( (i - 1) * size + j) 
		}
	}
}

function points(){
	for (i = 1 ; i <= size ; i++){
		for (j = 1 ; j <= size ; j++){
			if ( visited[i "," j] == "N" && board[i "," j] == "E"  ){
				black="false"
				white="false"
				mark( i  , j )
				if((black=="false" && white=="false") || (black=="true" && white=="true")){
					destroy("S")
				}else if(black=="true"){
					destroy("B")
				}else{
					destroy("W")
				}
			}	 
		}
	}
}

function mark(a,b,_color){
	visited[a "," b] = identifier
	_color="E"
	if((board[a+1 "," b] == "B") || (board[a-1 "," b] == "B") || (board[a "," b+1] == "B") || (board[a "," b-1] == "B")){
		black="true"
	}
	if((board[a+1 "," b] == "W") || (board[a-1 "," b] == "W") || (board[a "," b+1] == "W") || (board[a "," b-1] == "W")){
		white="true"
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

function destroy(color){
	for (k = 1 ; k <= size ; k++){
		for (l = 1 ; l <= size ; l++){
			if(visited[k "," l]==identifier){
				visited[k "," l] = color
			} 
		}
	}
}

function printPoints(){
	blackP=0
	whiteP=0
	for (i = 1 ; i <= size ; i++){
		for (j = 1 ; j <= size ; j++){
			if(visited[i "," j] == "W"){
				whiteP++
			}else if (visited[i "," j] == "B"){
				blackP++
			}
		}
	}
	printf "Black=%i;White=%i", blackP, whiteP
}
END {

	for (i = 1 ; i <= size ; i++){
		for (j = 1 ; j <= size ; j++){
			visited[i "," j] = "N" 
		}
	}
	points()
	printPoints()
}
