# Analyse Fichier Log Shell
Travail Pratique du cours de Shell. Analyse de fichier de log en utilisant shell scripts

Énoncé au lien suivant: https://serpaggi-cours.pages.emse.fr/bigdata-shell/TP-LOG.htm

Créer un script d’analyse de fichiers de logs d’un serveur. Ce qui intéresse votre client ce sont les tentatives de connexion à distance à l’aide du protocole SSH. Pour cela vous disposez d’un ensemble de fichiers que vous devez traiter en ne prenant en compte que les événements liés aux tentatives de connexions.

## Ne conserver que le principal:
Touver un moyen, le plus automatique possible, pour ne conserver que ce qui nous sera utile ensuite.

```bash
wget https://serpaggi-cours.pages.emse.fr/bigdata-shell/data/logs/auth.zip -d src/
cd src
zgrep ssh *log *.gz > ssh.log
ll # Vérifier la taille du fichier
gzip -9 ssh.log
ll # Vérifier la taille du fichier résultant 
```

La taille avant de compressé était 55681563 et la taille après la compression 4757551.

## Respecter la vie privée
Proposer une méthode (sans la mettre en œuvre pour l’instant) permettant d’anonymiser[1] le fichier qui contient les données que vous traitez pour que les informations sensibles n’apparaissent pas clairement.

Étant donné que le nom d'utilisateur est "sacha" et le non du serveur est "miro", nous pouvons utiliser les commands suivantes:

```bash
less ssh.log.gz | sed s/sacha/*****/g
less ssh.log.gz | sed s/miro/****/g

# Wrong
tr 'sacha' '*****'
tr 'miro' '****'
```


## Other stuff
Get a list of user that appear in the logs
```bash
zgrep -o 'Invalid user.*' ssh.log.gz | cut -d " " -f 3 | uniq > users.txt
zgrep -o 'Connection closed by invalid user.*' ssh.log.gz | cut -d " " -f 6 | uniq >> users.txt
zgrep -o 'Accepted publickey for.*' ssh.log.gz | cut -d " " -f 4 | uniq >> users.txt
```

