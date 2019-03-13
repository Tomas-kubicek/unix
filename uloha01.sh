if [ "$1" == "--typ" ]; then
	shift 
	if [ -e "$1" ]; then
		if  [ -p "$1" ]; then
			echo pipe
		elif  [ -d "$1" ]; then
			echo adresar
		elif  [ -h "$1" ]; then
			echo "symbolicky link"
		elif  [ -b "$1" ]; then
			echo "blokove zarizeni"
		elif  [ -c "$1" ]; then
			echo "znakove zarizeni"
		elif  [ -s "$1" ]; then
			echo "socket"
		elif  [ -f "$1" ]; then
			echo "soubor"
		else
			echo "Tento typ souboru neznam"
			exit 1
		fi
	exit 0
	else
		echo soubor neexistije
		exit 1
	fi
elif [ "$1" == "--help"  ]; then
	echo " 
	Pouzitie: uloha01.sh [--typ|--help] [cesta_k_suboru]
  	--typ	Vypise  typ souboru na ktery ukazuje [cesta_k_suboru], podporuje subor, adresar, symbolicky link, znakove zariadenie, blokove zariadenie, soket, rura (fifo)
  	--help	Vypise navod, jak pouzivat tento skript

	Exit status:
  	0 program probehl uspesne 
  	1 Nastala chyba"
	exit 0
else
	echo Chybne parametry
	exit 1
fi
