#!/bin/bash
# Script to analyse a log file
# param1: option
# param2: file to be analysed

if [ $# -eq 0 ]
then
	echo "Pas de paramètre"
else
	echo "$# paramètres :"
	if [ $1 == "-u" ]
	then
		echo "Les utilisateurs qui ont reussi à se connecter sont:"
		zgrep -o 'Accepted publickey for.*' $2 | cut -d " " -f 4 | sort -u
		echo "Le nombre d'utilisateurs qui ont reussi à se connecter est: $(zgrep -o 'Accepted publickey for.*' $2 | cut -d " " -f 4 | sort -u | wc -l)"
	elif [ $1 == "-U" ]
	then
		echo "Les utilisateurs qui ont été rejetés sont:"
		zgrep -o 'Invalid user.*' $2 | cut -d " " -f 3 | sort -u
		echo "Le nombre d'utilisateurs qui ont été rejetés: $(zgrep -o 'Invalid user.*' $2 | cut -d " " -f 3 | sort -u | wc -l)"
	elif [ $1 == "-i" ]
	then
		echo "Les addresses IP qui ont reussi à se connecter sont:"
		zgrep -o 'Accepted publickey for.*' $2 | cut -d " " -f 6 | sort -u
	elif [ $1 == "-I" ]
	then
		echo "Les addresses IP qui ont été rejetés sont:"
		zgrep -o 'Invalid user.*' $2 | cut -d " " -f 5 | sort -u
	elif [ $1 == "-b" ]
	then
		echo "Les addresses IP bloquées sont:"
		IP_BLOQUEES=$(zgrep -o 'Blocking.*' $2 | cut -d "\"" -f 2 | sort -u)
		echo -e "${IP_BLOQUEES}"
		echo "Le nombre de addresses IP bloquées est: $(echo ${IP_BLOQUEES} | wc -w)"
	elif [ $1 == '-B'  ] 
	then
		echo "Les addresses IP bloquées sont:"
		zgrep -o 'Blocking.*' $2 | cut -d " " -f 2-5 | sort -u | tr -d "\""
	elif [ $1 == '-n' ]
	then
		echo "Les address IP bloquées sont:"
		zgrep -o 'Invalid user.*' $2 | cut -d " " -f 5 | sort -u > ip_rejetees
		zgrep -o 'Blocking.*' $2 | cut -d "\"" -f 2 | sort -u > ip_bloquees
		comm -23 ip_rejetees ip_bloquees
		rm ip_rejetees ip_bloquees
	fi

fi
