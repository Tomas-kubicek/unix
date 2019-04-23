#!/bin/sed -Enf
:again
/[[:digit:]]+[[:space:]]*\+[[:space:]]*[[:digit:]]+/{
h; s/([[:digit:]]+)[[:space:]]*\+[[:space:]]*([[:digit:]]+)/\;\1 \2\;/ ; s/[^;]*\;// ;s/\;.*// ; 
s/.*/\,&/ ; 
: both
s/([[:digit:]]*),([[:digit:]]*)([[:digit:]])[[:space:]]([[:digit:]]*)([[:digit:]])/\1\3\5,\2 \4/ ; t both; 
: first
s/([[:digit:]]*),[[:space:]]([[:digit:]]*)([[:digit:]])/\10\3, \2/ ; t first;
: last
s/([[:digit:]]*),([[:digit:]]*)([[:digit:]])[[:space:]]/\1\30,\2 / ; t last;
s/,[[:space:]]// ; s/^([[:digit:]]{2})(.*)/,0\1:\2/
:xsubstitution
s/(,X*)0([[:digit:]]*:)/\1\2/ ;
s/(,X*)1([[:digit:]]*:)/\1X\2/ ;
s/(,X*)2([[:digit:]]*:)/\1XX\2/ ;
s/(,X*)3([[:digit:]]*:)/\1XXX\2/ ;
s/(,X*)4([[:digit:]]*:)/\1XXXX\2/ ;
s/(,X*)5([[:digit:]]*:)/\1XXXXX\2/ ;
s/(,X*)6([[:digit:]]*:)/\1XXXXXX\2/ ;
s/(,X*)7([[:digit:]]*:)/\1XXXXXXX\2/ ;
s/(,X*)8([[:digit:]]*:)/\1XXXXXXXX\2/ ;
s/(,X*)9([[:digit:]]*:)/\1XXXXXXXXX\2/ ; t xsubstitution ;
s/X{10}:/1:/ ;
t skip1 ;
s/:/0:/ ;
:skip1 ;
s/,([01])/,0\1/ ;
s/,X{1}([01])/,1\1/ ;
s/,X{2}([01])/,2\1/ ;
s/,X{3}([01])/,3\1/ ;
s/,X{4}([01])/,4\1/ ;
s/,X{5}([01])/,5\1/ ;
s/,X{6}([01])/,6\1/ ;
s/,X{7}([01])/,7\1/ ;
s/,X{8}([01])/,8\1/ ;
s/,X{9}([01])/,9\1/ ;
t inplace ;
:inplace ;
#in place jump so that I reset the bool of t/T
s/([[:digit:]]*),([[:digit:]])0:$/\2\1/ ;
s/([[:digit:]]*),([[:digit:]])1:$/1\2\1/ ; 
t skip2 ;
s/([[:digit:]]*),([[:digit:]])([[:digit:]]):([[:digit:]]{2})/\2\1,\3\4:/ ; 
b xsubstitution ;
:skip2 ;
s/$/,/ ; G ; 
#stejne jako nahore me nanapadlo lepsi reseni toho prohozeni, protoze posix nema lazy operatory
s/([[:digit:]]+)[[:space:]]*\+[[:space:]]*([[:digit:]]+)/,.,.,/ ; 
s/([[:digit:]]*),\n(.*)\,\.\,\.\,/\2\1/ ;
b again; }
p



