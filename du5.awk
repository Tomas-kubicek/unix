#!/usr/bin/awk -f
BEGIN {
	# nastavime separator zaznamov na znak <
	RS="<"
	IGNORECASE=1
	re="['\"]"
}
/^a/ {
	for (i = 2; i <= NF; ++i) {
		if ($i ~ /^href/) {
			if($i ~ ("^href=" re)){
				l=substr($i, 7)
				j = 0
				while(1==1){
					contains=match(l,re)
					if( contains == 0){
						gsub("&quot;", "\"", l)
						gsub("&lt;", "<", l)
						gsub("&gt;", ">", l)
						gsub("&amp;", "&", l)
						res= res " " l
						j++
						l=$(j+i)
					}else{
						l=substr(l,1,contains-1)	
						gsub("&quot;", "\"", l)
						gsub("&lt;", "<", l)
						gsub("&gt;", ">", l)
						gsub("&amp;", "&", l)
						res= res " " l
						break
					}
				}
				res = substr(res, 2)
				print res
			}else if ($i ~/^href=.+/){
				res = substr($i,6)
				contains = match(res,">")
				if(contains ==0){
					print res
				}else{
					print substr(res,1,contains-1)
				}
			}else if($i ~ /^href=$/){
				i++
				l=substr($i, 2)
				j = 0
				while(1==1){
					contains=match(l,re)
					if( contains == 0){
						gsub("&quot;", "\"", l)
						gsub("&lt;", "<", l)
						gsub("&gt;", ">", l)
						gsub("&amp;", "&", l)
						res= res " " l
						j++
						l=$(j+i)
					}else{
						l=substr(l,1,contains-1)	
						gsub("&quot;", "\"", l)
						gsub("&lt;", "<", l)
						gsub("&gt;", ">", l)
						gsub("&amp;", "&", l)
						res= res " " l
						break
					}
				}
				res = substr(res, 2)
				print res
			}else{
				i++
				if($i ~/^=$/){
					i++
					l=substr($i, 2)
					j = 0
					while(1==1){
						contains=match(l,re)
						if( contains == 0){
							gsub("&quot;", "\"", l)
							gsub("&lt;", "<", l)
							gsub("&gt;", ">", l)
							gsub("&amp;", "&", l)
							res= res " " l
							j++
							l=$(j+i)
						}else{
							l=substr(l,1,contains-1)	
							gsub("&quot;", "\"", l)
							gsub("&lt;", "<", l)
							gsub("&gt;", ">", l)
							gsub("&amp;", "&", l)
							res= res " " l
							break
						}
					}
					res = substr(res, 2)
					print res
				}else{
					if($i ~ ("^=" re)){
						l=substr($i, 3)
						j = 0
						while(1==1){
							contains=match(l,re)
							if( contains == 0){
								gsub("&quot;", "\"", l)
								gsub("&lt;", "<", l)
								gsub("&gt;", ">", l)
								gsub("&amp;", "&", l)
								res= res " " l
								j++
								l=$(j+i)
							}else{
								l=substr(l,1,contains-1)	
								gsub("&quot;", "\"", l)
								gsub("&lt;", "<", l)
								gsub("&gt;", ">", l)
								gsub("&amp;", "&", l)
								res= res " " l
								break
							}
						}
						res = substr(res, 2)
						print res
					}else{
						res = substr($i,2)
						contains = match(res,">")
						if(contains ==0){
							print res
						}else{
							print substr(res,1,contains-1)
						}
					}
				}
			}
		}
		res=""
		l=""
	}
	
}

