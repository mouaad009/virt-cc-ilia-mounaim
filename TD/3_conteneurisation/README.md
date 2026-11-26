# TD 3 · Conteneurisation

MOUNAIM Mouaad · ILIA · Polytech Dijon

[Énoncé du TD](https://github.com/JeromeMSD/module_virtualisation-et-cloud-computing/blob/main/tds/3_conteneurisation.md)

Les commandes s’exécutent depuis `TD/3_conteneurisation` avec Docker démarré. Chaque étape est conservée dans un commit.

## Consigne Teams

Le fichier `student.json` reste hors du dépôt et des contextes Docker. Le `.gitignore` exclut les identifiants et les clés. Chaque `.dockerignore` autorise uniquement les fichiers utiles à son image. La clé est réservée à l’authentification au registre Google.

## Frontend

### 1 · Créer la page

`frontend/index.html` contient le HTML et son CSS. Il peut être ouvert directement dans un navigateur.

### 2 · Choisir Nginx

`FROM nginx:latest` utilise la dernière image Nginx.

### 3 · Copier la page

`COPY index.html /usr/share/nginx/html/` enregistre la page dans l’image, dans le dossier servi par Nginx.

### 4–5 · Déclarer le port et sauvegarder

`EXPOSE 80` documente le port du conteneur. La publication sur l’hôte sera configurée par `-p`.

**Point d’entrée et commande de démarrage**

L’image officielle fournit `ENTRYPOINT ["/docker-entrypoint.sh"]` et `CMD ["nginx", "-g", "daemon off;"]`. Le script prépare la configuration et lance Nginx au premier plan. Notre Dockerfile hérite de ces valeurs.

```sh
docker image inspect nginx:latest --format '{{json .Config.Entrypoint}} {{json .Config.Cmd}}'
```

### 6 · Construire l’image

```sh
cd frontend
docker build . -t mon-frontend
cd ..
```

### 7–8 · Démarrer et ouvrir le site

```sh
docker run -d --name frontend-ctn -p 8080:80 mon-frontend
```

Ouvrir http://localhost:8080 dans le navigateur. Le port 8080 de l’hôte redirige vers le port 80 du conteneur.

### 9 · Modifier et redéployer

La page est passée de « Version 1 » à « Version 2 · Page mise à jour ».

```sh
docker stop frontend-ctn
docker rm frontend-ctn
docker build ./frontend -t mon-frontend
docker run -d --name frontend-ctn -p 8080:80 mon-frontend
```

**Observation attendue** — Modifier uniquement le fichier local conserve le contenu du conteneur existant. `COPY` a copié la page pendant la construction. Reconstruire l’image puis recréer le conteneur rend la nouvelle version disponible.

## Backend · Boîte à outils

### 1 · Choisir Debian

Le Dockerfile utilise `FROM debian:latest`.

### 2 · Installer les outils

`RUN` installe `bash`, `htop`, `vim` et `net-tools`. Le paquet `net-tools` fournit `netstat`.

### 3 · Définir OWNER et démarrer le conteneur

`ENV OWNER=Mouaad` définit mon prénom. `CMD ["sleep", "3600"]` garde le conteneur actif pendant une heure.

**Pourquoi aucun EXPOSE ?** La boîte à outils n’exécute aucun serveur réseau.

L’image Debian fournit habituellement `bash` par défaut. Un shell détaché sans entrée interactive peut se terminer immédiatement. Le `sleep 3600` du TD permet d’utiliser ensuite `docker exec`.

```sh
docker build ./backend -t toolbox
docker run -d --name toolbox-ctn toolbox
```

### Utiliser les outils et joindre le frontend

Dans un second terminal, avant l’étape `USER nonroot` suivante, se connecter au conteneur.

```sh
docker exec -it toolbox-ctn /bin/bash
echo "$OWNER"
bash --version
htop
vim
netstat -an
whoami
apt-get update
apt-get install -y curl
```

Quitter `htop` avec `q`. Quitter `vim` avec Échap, puis `:q!` et Entrée.

Dans un troisième terminal, démarrer le frontend s’il n’est pas déjà actif.

```sh
docker run -d --name frontend-ctn -p 8080:80 mon-frontend
```

Sur l’hôte Linux, `ip -4 addr show docker0` donne l’adresse de l’interface Docker. Sous Windows, utiliser `ipconfig`. Puis, dans la boîte à outils, remplacer `<IP-host>` par l’adresse relevée.

```sh
curl http://<IP-host>:8080
```

Sur Docker Desktop, `host.docker.internal` permet aussi de joindre l’hôte si l’interface Docker est interne à sa VM.

**Résultat attendu** — `curl` affiche le HTML servi par Nginx via le port 8080 de l’hôte.

### Gestion des droits utilisateur

Dans le premier conteneur, `whoami` renvoie `root` et l’installation de `curl` est permise. Le Dockerfile final ajoute `RUN useradd nonroot` puis `USER nonroot`.

```sh
exit
docker stop toolbox-ctn
docker rm toolbox-ctn
docker build ./backend -t toolbox
docker run -d --name toolbox-ctn toolbox
docker exec -it toolbox-ctn /bin/bash
whoami
apt install curl
exit
```

**Résultat attendu** — `whoami` renvoie `nonroot`. `apt install curl` échoue avec une erreur de permission. Installer les paquets dans le Dockerfile avant `USER` permet de préparer l’image avec les droits requis. L’installation interactive de `curl` dans l’ancien conteneur disparaît lorsque celui-ci est supprimé.

## Sauvegarder le frontend dans Artifact Registry

Installer [gcloud](https://docs.cloud.google.com/sdk/docs/install-sdk?hl=fr#latest-version) et exécuter toutes les commandes dans le même terminal. Conserver le JSON fourni par Teams dans un dossier privé extérieur au dépôt, puis adapter son chemin local.

```sh
gcloud auth activate-service-account student@polytech-dijon.iam.gserviceaccount.com --key-file="/chemin/prive/student.json"
gcloud config set project polytech-dijon
gcloud auth configure-docker europe-west1-docker.pkg.dev
docker tag mon-frontend europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/frontend-2026:mounaim
docker push europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/frontend-2026:mounaim
```

Répondre `Y` aux confirmations. Le tag `mounaim` correspond au travail individuel. La réussite du push se vérifie à partir du digest renvoyé par le registre. Les configurations Docker et gcloud restent à l’extérieur du dépôt.

Faire vérifier l’image par l’enseignant, comme demandé à la fin du TD.

## Bonus · RabbitMQ Hello World

Exemple adapté du [tutoriel officiel Python](https://www.rabbitmq.com/tutorials/tutorial-one-python).

Dans un premier terminal, démarrer le serveur avec la commande du TD.

```sh
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management
```

Dans un deuxième terminal, créer un environnement Python.

```sh
python -m venv rabbitmq/.venv
```

Sous Windows PowerShell, lancer `rabbitmq/.venv/Scripts/Activate.ps1`. Sous Linux, lancer `source rabbitmq/.venv/bin/activate`. Puis exécuter les commandes suivantes.

```sh
python -m pip install -r rabbitmq/requirements.txt
python rabbitmq/receive.py
```

Dans un troisième terminal avec le même environnement activé, lancer `python rabbitmq/send.py`.

Le producteur envoie `Hello World!` à la file `hello`. Le consommateur attend et affiche les messages. `auto_ack=True` reprend l’exemple introductif. L’interface de gestion se trouve sur http://localhost:15672 avec le compte local `guest`.
