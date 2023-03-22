# Analyse Fichier Log Shell
Travail Pratique du cours de Shell. Analyse de fichier de log en utilisant shell scripts

Énoncé au lien suivant: https://serpaggi-cours.pages.emse.fr/bigdata-shell/TP-LOG.htm

Créer un script d’analyse de fichiers de logs d’un serveur. Ce qui intéresse votre client ce sont les tentatives de connexion à distance à l’aide du protocole SSH. Pour cela vous disposez d’un ensemble de fichiers que vous devez traiter en ne prenant en compte que les événements liés aux tentatives de connexions.

## Ne conserver que le principal:
Touver un moyen, le plus automatique possible, pour ne conserver que ce qui nous sera utile ensuite.

```bash
wget https://serpaggi-cours.pages.emse.fr/bigdata-shell/data/logs/auth.zip

unzip auth.zip
rm auth.zip
gunzip *.gz
cat * > ssh.log
rm *auth_log

FILESIZE=$(stat -f%z ssh.log)
echo "Taille du ficher : $FILESIZE bytes"

gzip ssh.log
```

La taille avant de compressé était 55681563 et la taille après la compression 4757551.


