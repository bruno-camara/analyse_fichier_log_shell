# Analyse Fichier Log Shell
Travail Pratique du cours de Shell. Analyse de fichier de log en utilisant shell scripts

Énoncé au lien suivant: https://serpaggi-cours.pages.emse.fr/bigdata-shell/TP-LOG.htm

Auteurs: Bruno Carneiro Camara et Thales Vinícius de Lima Uchoas

Créer un script d’analyse de fichiers de logs d’un serveur. Ce qui intéresse votre client ce sont les tentatives de connexion à distance à l’aide du protocole SSH. Pour cela vous disposez d’un ensemble de fichiers que vous devez traiter en ne prenant en compte que les événements liés aux tentatives de connexions.

## Ne conserver que le principal:
Touver un moyen, le plus automatique possible, pour ne conserver que ce qui nous sera utile ensuite.

```bash
wget https://serpaggi-cours.pages.emse.fr/bigdata-shell/data/logs/auth.zip -d src/

unzip auth.zip
rm auth.zip
zgrep ssh *log *.gz > ssh.log

FILESIZE=$(stat -f%z ssh.log)
echo "Taille du ficher : $FILESIZE bytes"

gzip -9 ssh.log
```

La taille avant de compressé était 55681563 et la taille après la compression 4757551.

## Respecter la vie privée
Proposer une méthode (sans la mettre en œuvre pour l’instant) permettant d’anonymiser[1] le fichier qui contient les données que vous traitez pour que les informations sensibles n’apparaissent pas clairement.

Étant donné que le nom d'utilisateur est "sacha" et le non du serveur est "miro", nous pouvons utiliser les commands suivantes:

```bash
less ssh.log.gz | sed s/sacha/*****/g | sed s/miro/****/g
```

## Analyser
Le travail qui vous est demandé a un objectif à long terme, vous décidez donc d’écrire un script qui pourra être lancé à la demande sans avoir à connaître toutes les commandes nécessaires à son fonctionnement.

Créez un script qui, à partir d’un fichier comme celui obtenu au dessus, affiche les informations suivantes en fonction des options qui lui sont passées :


-u: (†) identifiants des utilisateurs ayant réussi à se connecter et, à la fin, leur nombre total
> Pour identifier les utilisateurs qui ont réussi à se connecter nous utilisons la commande grep pour prendre la ligne qui montre une connection réussie et la commande cut pour prendre seulement le nom de l'utilisateur. La commande sort -u est utilisée pour éliminer les doublons. Pour compter le nombre d'utilisateurs nous avons utilisé wc -l.

-U: (†) identifiant des utilisateurs rejetés et, à la fin, leur nombre total
> Pareil au antérieur, sauf que la phrase pour prendre les utilisateurs est maintenant "Invalid user ..."

-i: (†) liste des adresses IP des utilisateurs ayant réussi à se connecter
> Pareil aux antérieurs. La différence est où nous avons coupé la ligne

-I: (†) liste des adresses IP des utilisateurs rejetés
> Idem -i

-b: (†) liste des adresses IP ayant été bloquées ainsi que, à la fin, leur nombre total
> Pour prendres les addresses IP bloquées, nous avons utilisé la commande grep avec le pattern "Blocking.\*" et le paramètre -o pour prendre seulement la partie de la ligne après le pattern. Puis, la commande cut pour couper la ligne et sort -u pour éliminer les doublons.

-B: (†) liste des adresses IP ayant été bloquées, chacune suivie de son temps de blocage total
> Pareil à -b, sauf que dans la commande cut est passé une intervalle de champs (dans notre cas 2-5)

-n: (†) liste des adresses IP dont les utilisateurs ont été rejetés mais qui n’ont pas été bloquées, ainsi que leur nombre total
> Pour verifier le contenu de 2 fichiers nous avons utilisé comm. Alors, nous avons crée 2 fichier, 1 avec les IP rejetées et autre avec les IP bloquées

-d: durée moyenne des blocages d’adresses IP
> Utilisation de la commande bc (basic calculator). Il faut, avant d'utiliser cette commande, préparer l'équation. Pour cela, nous avons pris les temps de blocage avec grep et cut et nous remplaçons le saut de ligne par un signe plus avec la commande tr. Puis, nous avons pris le nombre de résultats donné avec la command wc -l et nous concaténons tout en une seule expression pour pouvoir utiliser la commande bc.

-D [IP]: (†) les dates de début et de fin des attaques émanant de l’adresse IP
> grep avec "Attack from" et le IP passé comme paramètre. Nous avons utilisé la commande head et tail pour affichier la première et la dernière ligne. Avec cela, nous avons le début et le fin du attaque puisque le fichier base est trié par date déjà. Pour prendre seulemente la partie que nous intérèsse, la commande cut a été utilisée.

-f: fréquence hebdomadaire moyenne des connexions fructueuses
> grep avec "Accepted " pour avoir les connexions fructueuses et manipulations avec les commandes cut et sed pour prendre la date. Tout cela est garder dans un fichier qui est utilisé par la commande date afin d'obtenir la semaine de l'année à laquelle la date appartient. La commande uniq -c associée à la commande sort est utilisée pour obtenir les fréquences de chaque semaine. La commande awk a été utilisée pour calculer la moyenne.

-F: fréquence journalière moyenne des connexions infructueuses

-c: donne la liste des connexions fructueuses au format CSV[2] comportant les colonnes suivantes :

- **date:** date de l’événement (si l’année n’est pas précisée dans une entrée du fichier de log, c’est que c’est l’année en cours)

- **ts:** timestamp de l’événement (nombre de secondes depuis le 01/01/1970)

- **serveur:** nom de la machine concernée

- **ip:** adresse IP d’où émane la tentative de connexion

- **user:** nom d’utilisateur donné lors de la tentative de connexion

-C: idem que -c mais pour les tentatives de connexion infructueuses

## OBS: Utiliser getopts pour get the options from the script

## Other stuff
Get a list of user that appear in the logs
```bash
zgrep -o 'Invalid user.*' ssh.log.gz | cut -d " " -f 3 | uniq > users.txt
zgrep -o 'Connection closed by invalid user.*' ssh.log.gz | cut -d " " -f 6 | uniq >> users.txt
zgrep -o 'Accepted publickey for.*' ssh.log.gz | cut -d " " -f 4 | uniq >> users.txt
```

