#!/bin/bash
# Script to analyse a log file
# param1: option
# param2: file to be analysed

if [ $# -eq 0 ]
then
        echo "Pas de paramètre"
	exit 1
fi


while getopts ':u:U:i:I:b:B:n:d:D:f:F:c:C:' OPTION
do
	case "$OPTION" in
		u)
			echo "Les utilisateurs qui ont reussi à se connecter sont:"
			zgrep -o 'Accepted publickey for.*' $OPTARG | cut -d " " -f 4 | sort -u
			echo "Le nombre d'utilisateurs qui ont reussi à se connecter est: $(zgrep -o 'Accepted publickey for.*' $2 | cut -d " " -f 4 | sort -u | wc -l)"
			;;
		U)
			echo "Les utilisateurs qui ont été rejetés sont:"
			zgrep -o 'Invalid user.*' $OPTARG | cut -d " " -f 3 | sort -u
			echo "Le nombre d'utilisateurs qui ont été rejetés: $(zgrep -o 'Invalid user.*' $2 | cut -d " " -f 3 | sort -u | wc -l)"
			;;
		i)
			echo "Les addresses IP qui ont reussi à se connecter sont:"
			zgrep -o 'Accepted publickey for.*' $OPTARG | cut -d " " -f 6 | sort -u
			;;
		I)
			echo "Les addresses IP qui ont été rejetés sont:"
			zgrep -o 'Invalid user.*' $OPTARG | cut -d " " -f 5 | sort -u
			;;
		b)
			echo "Les addresses IP bloquées sont:"
			IP_BLOQUEES=$(zgrep -o 'Blocking.*' $OPTARG | cut -d "\"" -f 2 | sort -u)
			echo -e "${IP_BLOQUEES}"
			echo "Le nombre de addresses IP bloquées est: $(echo ${IP_BLOQUEES} | wc -w)"
			;;
		B) 
			echo "Les addresses IP bloquées sont:"
			zgrep -o 'Blocking.*' $OPTARG | cut -d " " -f 2-5 | sort -u | tr -d "\""
			;;
		n)
			echo "Les address IP rejetées mais pas bloquées sont:"
			zgrep -o 'Invalid user.*' $OPTARG | cut -d " " -f 5 | sort -u > ip_rejetees
			zgrep -o 'Blocking.*' $OPTARG | cut -d "\"" -f 2 | sort -u > ip_bloquees
			VAR=$(comm -23 ip_rejetees ip_bloquees)
			rm ip_rejetees ip_bloquees
			echo "$VAR"
			echo "Le nombre de addresses IP rejetées mais pas bloquées est: $(echo "${VAR}" | wc -l)"
			;;
		d)
			IP=$(zgrep -o 'Blocking.*' $OPTARG | cut -d " " -f 4)
			OPERATION="($(echo "${IP}" | tr "\n" "+" | sed 's/.$//'))/$(echo "${IP}" | wc -l)"
			echo "La durée moyenne des blocages d'addresses IP est: $(echo ${OPERATION} | bc) sec"
			;;
		D)
			if [[ $2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
	       		then
				PATTERN="Attack from \"$2\""
				START=$(zgrep "$PATTERN" $3 | head -1 | sed 's/  / /g' | cut -d " " -f 3-5 | cut -d ":" -f 2-4)
				END=$(zgrep "$PATTERN" $3 | tail -1 | sed 's/  / /g' | cut -d " " -f 3-5 | cut -d ":" -f 2-4)
				echo "La date de début d'attaque est $START et la date de fin est $END"
			else
				echo "L'adresse IP passée n'est pas valide"
			fi
			;;
		f)
			zgrep 'Accepted publickey for' $OPTARG | sed 's/  / /g' | cut -d " " -f 3-5 | cut -d ":" -f 2-4 | cut -d " " -f 1-2 > date_connections
			echo "La fréquence hebdomadaire moyenne des connexions fractueuses est $(date -f date_connections "+%U" | sort | uniq -c | awk '{ total += $1; count++ } END { print total/count }')"
			rm date_connections
			;;
		F)
			zgrep 'Accepted publickey for' $OPTARG | sed 's/  / /g' | cut -d " " -f 3-5 | cut -d ":" -f 2-4 | cut -d " " -f 1-2 > date_connections
			echo "La fréquence journalière moyenne des connexions infructueuses est $(date -f date_connections "+%j" | sort | uniq -c | awk '{ total += $1; count++ } END { print total/count }')"
			rm date_connections
			;;
		c)
			zgrep 'Accepted publickey for' $OPTARG | sed 's/  / /g' | cut -d " " -f 3-5 | cut -d ":" -f 2-4 > date_connections
			date -f date_connections "+%s" > date_ts
			date -f date_connections "+%Y-%m-%d %H:%M:%S" > date_formated
			zgrep 'Accepted publickey for' $OPTARG | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'> serveur	
			zgrep 'Accepted publickey for' $OPTARG | sed 's/  / /g' | cut -d " " -f 11 > users
			echo 'date,ts,serveur,ip,user' > connexions_fructueuses.csv
			paste date_formated date_ts serveur users -d "," >> connexions_fructueuses.csv
			rm date_connections date_ts date_formated serveur users
			;;
		C)
			zgrep 'Invalid user' $OPTARG | sed 's/  / /g' | cut -d " " -f 3-5 | cut -d ":" -f 2-4 > date_connections
	                date -f date_connections "+%s" > date_ts
        	        date -f date_connections "+%Y-%m-%d %H:%M:%S" > date_formated
                	zgrep 'Invalid user' $OPTARG | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'> serveur
	                zgrep 'Invalid user' $OPTARG | sed 's/  / /g' | cut -d " " -f 10 > users
        	        echo 'date,ts,serveur,ip,user' > connexions_infructueuses.csv
                	paste date_formated date_ts serveur users -d "," | sort -u >> connexions_infructueuses.csv
	                rm date_connections date_ts date_formated serveur users
			;;
		?)
			echo "Invalid parameter"
			exit 1
			;;
	esac
done
