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
		zgrep -o 'Accepted publickey for.*' $2 | cut -d " " -f 4 | uniq
		echo "Le nombre d'utilisateurs qui ont reussi à se connecter est: $(zgrep -o 'Accepted publickey for.*' $2 | cut -d " " -f 4 | uniq | wc -l)"
	fi

fi
