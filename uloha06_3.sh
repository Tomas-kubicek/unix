#!/bin/sh
awk 'BEGIN{FS=":"} 
{userCount=0; 
	if(length($4)==0){
		print $1 ":0"
	}else{
		l=$4
		while(1==1){
			contains=match(l,",")
			if(contains==0){
				print $1 ":" (userCount+1)
				break
			}else{
				userCount++
				l=substr(l,contains+1)
			}
		}
	}
}' /etc/group | sort -r -t":" -n -k2 | awk '
BEGIN{
	FS=":"
}
NR==1{
	maxUser=$2 
	print $1
}
NR>1{
	if($2==maxUser){
		print $1
	}else{
	exit
	}
}'
exit 0

